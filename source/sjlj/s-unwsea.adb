pragma Check_Policy (Trace => Ignore);
with Ada.Unchecked_Conversion;
with System.Address_To_Constant_Access_Conversions;
with System.Storage_Elements;
with System.Unwind.Representation;
with C.unwind_pe;
package body System.Unwind.Searching is
   pragma Suppress (All_Checks);
   use type Storage_Elements.Storage_Offset;
   use type C.ptrdiff_t;
   use type C.signed_int;
   use type C.size_t;
   use type C.unsigned_char;
   use type C.unsigned_char_const_ptr;
   use type C.unsigned_int; -- _Unwind_Ptr is unsigned int or unsigned long
   use type C.unsigned_long;
   use type C.unsigned_long_long;
   use type C.unwind.sleb128_t;

   Foreign_Exception : aliased Exception_Data
      with Import,
         Convention => Ada,
         External_Name => "system__exceptions__foreign_exception";

   package unsigned_char_const_ptr_Conv is
      new Address_To_Constant_Access_Conversions (
         C.unsigned_char,
         C.unsigned_char_const_ptr);

   function "+" (Left : C.unsigned_char_const_ptr; Right : C.ptrdiff_t)
      return C.unsigned_char_const_ptr
      with Convention => Intrinsic;
   pragma Inline_Always ("+");

   function "+" (Left : C.unsigned_char_const_ptr; Right : C.ptrdiff_t)
      return C.unsigned_char_const_ptr is
   begin
      return unsigned_char_const_ptr_Conv.To_Pointer (
         unsigned_char_const_ptr_Conv.To_Address (Left)
            + Storage_Elements.Storage_Offset (Right));
   end "+";

   --  implementation

   function Personality (
      ABI_Version : C.signed_int;
      Phases : C.unwind.Unwind_Action;
      Exception_Class : C.unwind.Unwind_Exception_Class;
      Exception_Object : access C.unwind.struct_Unwind_Exception;
      Context : access C.unwind.struct_Unwind_Context)
      return C.unwind.Unwind_Reason_Code
   is
      function To_GNAT is
         new Ada.Unchecked_Conversion (
            C.unwind.struct_Unwind_Exception_ptr,
            Representation.Machine_Occurrence_Access);
      function Cast is
         new Ada.Unchecked_Conversion (
            C.unwind.struct_Unwind_Exception_ptr,
            C.unwind.Unwind_Word);
      function Cast is
         new Ada.Unchecked_Conversion (
            Exception_Data_Access,
            C.unwind.Unwind_Ptr);
      function Cast is
         new Ada.Unchecked_Conversion (C.char_const_ptr, C.unwind.Unwind_Ptr);
      GCC_Exception : constant Representation.Machine_Occurrence_Access :=
         To_GNAT (Exception_Object);
      landing_pad : C.unwind.Unwind_Ptr;
      ttype_filter : C.unwind.Unwind_Sword; -- 0 => finally, others => handler
   begin
      pragma Check (Trace, Ada.Debug.Put ("enter"));
      if ABI_Version /= 1 then
         pragma Check (Trace, Ada.Debug.Put ("leave, ABI_Version /= 1"));
         return C.unwind.URC_FATAL_PHASE1_ERROR;
      end if;
      if Exception_Class = Representation.GNAT_Exception_Class
         and then C.unsigned_int (Phases) =
            (C.unwind.UA_CLEANUP_PHASE or C.unwind.UA_HANDLER_FRAME)
      then
         landing_pad := GCC_Exception.landing_pad;
         ttype_filter := GCC_Exception.ttype_filter;
         pragma Check (Trace, Ada.Debug.Put ("shortcut!"));
      else
         declare
            --  about region
            lsda : C.void_ptr;
            base : C.unwind.Unwind_Ptr;
            call_site_table : C.unsigned_char_const_ptr;
            lp_base : aliased C.unwind.Unwind_Ptr;
            action_table : C.unsigned_char_const_ptr;
            ttype_encoding : C.unsigned_char;
            ttype_table : C.unsigned_char_const_ptr;
            ttype_base : C.unwind.Unwind_Ptr;
            --  about action
            table_entry : C.unsigned_char_const_ptr;
         begin
            if Context = null then
               pragma Check (Trace, Ada.Debug.Put ("leave, Context = null"));
               return C.unwind.URC_CONTINUE_UNWIND;
            end if;
            lsda := C.unwind.Unwind_GetLanguageSpecificData (Context);
            if Address (lsda) = Null_Address then
               pragma Check (Trace, Ada.Debug.Put ("leave, lsda = null"));
               return C.unwind.URC_CONTINUE_UNWIND;
            end if;
            base := C.unwind.Unwind_GetRegionStart (Context);
            declare
               p : C.unsigned_char_const_ptr :=
                  unsigned_char_const_ptr_Conv.To_Pointer (Address (lsda));
               tmp : aliased C.unwind.uleb128_t;
               lpbase_encoding : C.unsigned_char;
            begin
               lpbase_encoding := p.all;
               p := p + 1;
               if lpbase_encoding /= C.unwind_pe.DW_EH_PE_omit then
                  p := C.unwind_pe.read_encoded_value (
                     Context,
                     lpbase_encoding,
                     p,
                     lp_base'Access);
               else
                  lp_base := base;
               end if;
               ttype_encoding := p.all;
               p := p + 1;
               if ttype_encoding /= C.unwind_pe.DW_EH_PE_omit then
                  p := C.unwind_pe.read_uleb128 (p, tmp'Access);
                  ttype_table := p + C.ptrdiff_t (tmp);
               else
                  pragma Check (Trace,
                     Check =>
                        Ada.Debug.Put ("ttype_encoding = DW_EH_PE_omit"));
                  ttype_table := null; -- be access violation ?
               end if;
               ttype_base :=
                  C.unwind_pe.base_of_encoded_value (ttype_encoding, Context);
               p := p + 1;
               call_site_table := C.unwind_pe.read_uleb128 (p, tmp'Access);
               action_table := call_site_table + C.ptrdiff_t (tmp);
            end;
            declare
               p : C.unsigned_char_const_ptr := call_site_table;
               ip_before_insn : aliased C.signed_int := 0;
               ip : C.unwind.Unwind_Ptr :=
                  C.unwind.Unwind_GetIPInfo (Context, ip_before_insn'Access);
               call_site : C.signed_int;
            begin
               if ip_before_insn = 0 then
                  pragma Check (Trace, Ada.Debug.Put ("ip_before_insn = 0"));
                  ip := ip - 1;
               end if;
               call_site := C.signed_int (ip);
               if call_site <= 0 then
                  pragma Check (Trace,
                     Check => Ada.Debug.Put ("leave, no action or terminate"));
                  return C.unwind.URC_CONTINUE_UNWIND;
               end if;
               loop
                  declare
                     cs_lp : aliased C.unwind.uleb128_t;
                     cs_action : aliased C.unwind.uleb128_t;
                  begin
                     p := C.unwind_pe.read_uleb128 (p, cs_lp'Access);
                     p := C.unwind_pe.read_uleb128 (p, cs_action'Access);
                     call_site := call_site - 1;
                     if call_site = 0 then
                        landing_pad := C.unwind.Unwind_Ptr (cs_lp + 1);
                        if cs_action /= 0 then
                           table_entry :=
                              action_table + C.ptrdiff_t (cs_action - 1);
                        else
                           table_entry := null;
                        end if;
                        exit;
                     end if;
                  end;
               end loop;
            end;
            --  landing_pad is found in here
            if table_entry = null then
               ttype_filter := 0;
            else
               declare
                  ttype_size : constant C.ptrdiff_t :=
                     C.ptrdiff_t (
                        C.unwind_pe.size_of_encoded_value (ttype_encoding));
                  p : C.unsigned_char_const_ptr := table_entry;
                  ar_filter, ar_disp : aliased C.unwind.sleb128_t;
               begin
                  loop
                     p := C.unwind_pe.read_sleb128 (p, ar_filter'Access);
                     declare
                        Dummy : C.unsigned_char_const_ptr;
                     begin
                        Dummy := C.unwind_pe.read_sleb128 (p, ar_disp'Access);
                     end;
                     if ar_filter = 0 then
                        ttype_filter := 0;
                        if ar_disp = 0 then
                           pragma Check (Trace, Ada.Debug.Put ("finally"));
                           exit;
                        end if;
                     elsif ar_filter > 0
                        and then (C.unsigned_int (Phases)
                           and C.unwind.UA_FORCE_UNWIND) = 0
                     then
                        declare
                           filter : constant C.ptrdiff_t :=
                              C.ptrdiff_t (ar_filter) * ttype_size;
                           choice : aliased C.unwind.Unwind_Ptr;
                           is_handled : Boolean;
                           Dummy : C.unsigned_char_const_ptr;
                        begin
                           Dummy := C.unwind_pe.read_encoded_value_with_base (
                              ttype_encoding,
                              ttype_base,
                              ttype_table + (-filter),
                              choice'Access);
                           if Exception_Class =
                              Representation.GNAT_Exception_Class
                           then
                              is_handled :=
                                 choice = Cast (GCC_Exception.Occurrence.Id)
                                 or else (
                                    not GCC_Exception.Occurrence.Id
                                       .Not_Handled_By_Others
                                    and then choice =
                                       Cast (Others_Value'Access))
                                 or else choice =
                                    Cast (All_Others_Value'Access);
                           else
                              pragma Check (Trace,
                                 Check => Ada.Debug.Put ("foreign exception"));
                              is_handled :=
                                 choice = Cast (Foreign_Exception'Access)
                                 or else choice = Cast (Others_Value'Access)
                                 or else choice =
                                    Cast (All_Others_Value'Access);
                           end if;
                           if is_handled then
                              ttype_filter :=
                                 C.unwind.Unwind_Sword (ar_filter);
                              pragma Check (Trace,
                                 Check => Ada.Debug.Put ("handler is found"));
                              exit;
                           end if;
                        end;
                     else
                        pragma Check (Trace, Ada.Debug.Put ("ar_filter < 0"));
                        null;
                     end if;
                     if ar_disp = 0 then
                        pragma Check (Trace,
                           Check => Ada.Debug.Put ("leave, ar_disp = 0"));
                        return C.unwind.URC_CONTINUE_UNWIND;
                     end if;
                     p := p + C.ptrdiff_t (ar_disp);
                  end loop;
               end;
            end if;
            --  ttype_filter is found (or 0) in here
            if (C.unsigned_int (Phases) and C.unwind.UA_SEARCH_PHASE) /= 0 then
               if ttype_filter = 0 then -- cleanup
                  pragma Check (Trace,
                     Check =>
                        Ada.Debug.Put ("leave, UA_SEARCH_PHASE, cleanup"));
                  return C.unwind.URC_CONTINUE_UNWIND;
               else
                  --  Setup_Current_Excep (GCC_Exception);
                  null; -- exception tracing (a-exextr.adb) is not implementd.
                  --  shortcut for phase2
                  if Exception_Class = Representation.GNAT_Exception_Class then
                     pragma Check (Trace, Ada.Debug.Put ("save for shortcut"));
                     GCC_Exception.landing_pad := landing_pad;
                     GCC_Exception.ttype_filter := ttype_filter;
                  end if;
                  pragma Check (Trace,
                     Check =>
                        Ada.Debug.Put (
                           "leave, UA_SEARCH_PHASE, handler found"));
                  return C.unwind.URC_HANDLER_FOUND;
               end if;
            elsif Phases = C.unwind.UA_CLEANUP_PHASE then
               if ttype_filter = 0
                  and then Exception_Class =
                     Representation.GNAT_Exception_Class
                  and then GCC_Exception.Stack_Guard /= Null_Address
               then
                  declare
                     Stack_Pointer : constant C.unwind.Unwind_Word :=
                        C.unwind.Unwind_GetCFA (Context);
                  begin
                     if Stack_Pointer <
                        C.unwind.Unwind_Word (GCC_Exception.Stack_Guard)
                     then
                        pragma Check (Trace,
                           Check => Ada.Debug.Put ("leave, skip cleanup"));
                        return C.unwind.URC_CONTINUE_UNWIND;
                     end if;
                  end;
               end if;
               pragma Check (Trace,
                  Check =>
                     Ada.Debug.Put (
                        "UA_CLEANUP_PHASE without UA_HANDLER_FRAME"));
               null; -- ???
            else
               pragma Check (Trace, Ada.Debug.Put ("miscellany phase"));
               null; -- ???
            end if;
         end;
      end if;
      pragma Check (Trace, Ada.Debug.Put ("unwind!"));
      --  setup_to_install (raise-gcc.c)
      C.unwind.Unwind_SetGR (
         Context,
         0, -- builtin_eh_return_data_regno (0),
         Cast (C.unwind.struct_Unwind_Exception_ptr (Exception_Object)));
      C.unwind.Unwind_SetGR (
         Context,
         1, -- builtin_eh_return_data_regno (1),
         C.unwind.Unwind_Word'Mod (ttype_filter));
      C.unwind.Unwind_SetIP (Context, landing_pad);
      --  Setup_Current_Excep (GCC_Exception); -- moved to Begin_Handler
      pragma Check (Trace, Ada.Debug.Put ("leave"));
      return C.unwind.URC_INSTALL_CONTEXT;
   end Personality;

end System.Unwind.Searching;
