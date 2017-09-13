--  for ZCX (or SjLj, or Win64 SEH)
pragma Check_Policy (Trace => Ignore);
with System.System_Allocators;
with C.unwind;
separate (System.Unwind.Occurrences)
package body Separated is
   pragma Suppress (All_Checks);
   use type C.signed_int;

   procedure memset (
      b : Address;
      c : Integer;
      n : Storage_Elements.Storage_Count)
      with Import,
         Convention => Intrinsic, External_Name => "__builtin_memset";

   package Unwind_Exception_ptr_Conv is
      new Address_To_Named_Access_Conversions (
         C.unwind.struct_Unwind_Exception,
         C.unwind.struct_Unwind_Exception_ptr);

   package MOA_Conv is
      new Address_To_Named_Access_Conversions (
         Representation.Machine_Occurrence,
         Representation.Machine_Occurrence_Access);

   --  equivalent to GNAT_GCC_Exception_Cleanup (a-exexpr-gcc.adb)
   procedure Cleanup (
      Reason : C.unwind.Unwind_Reason_Code;
      Exception_Object : access C.unwind.struct_Unwind_Exception)
      with Convention => C;

   procedure Cleanup (
      Reason : C.unwind.Unwind_Reason_Code;
      Exception_Object : access C.unwind.struct_Unwind_Exception)
   is
      pragma Unreferenced (Reason);
   begin
      pragma Check (Trace, Ada.Debug.Put ("enter"));
      System_Allocators.Free (
         Unwind_Exception_ptr_Conv.To_Address (Exception_Object));
      pragma Check (Trace, Ada.Debug.Put ("leave"));
   end Cleanup;

   --  implementation

   function New_Machine_Occurrence
      return not null Representation.Machine_Occurrence_Access
   is
      Result : Representation.Machine_Occurrence_Access;
   begin
      Result := MOA_Conv.To_Pointer (
         System_Allocators.Allocate (
            Representation.Machine_Occurrence'Size / Standard'Storage_Unit));
      if Result = null then
         declare -- fallback for the heap is exhausted
            TLS : constant
                  not null Runtime_Context.Task_Local_Storage_Access :=
               Runtime_Context.Get_Task_Local_Storage;
         begin
            Result := TLS.Secondary_Occurrence'Access;
         end;
         Result.Header.exception_cleanup := null; -- statically allocated
      else
         Result.Header.exception_cleanup := Cleanup'Access;
      end if;
      Result.Header.exception_class := Representation.GNAT_Exception_Class;
      --  fill 0 to private area
      pragma Compile_Time_Error (
         C.unwind.Unwind_Exception_Class'Size rem Standard'Word_Size /= 0,
         "unaligned Unwind_Exception_Class'Size");
      pragma Compile_Time_Error (
         C.unwind.Unwind_Exception_Cleanup_Fn'Size rem Standard'Word_Size /= 0,
         "unaligned Unwind_Exception_Cleanup_Fn'Size");
      memset (
         Result.Header.exception_cleanup'Address
            + Storage_Elements.Storage_Offset'(
               C.unwind.Unwind_Exception_Cleanup_Fn'Size
                  / Standard'Storage_Unit),
         0,
         C.unwind.struct_Unwind_Exception'Size / Standard'Storage_Unit
            - Storage_Elements.Storage_Offset'(
               C.unwind.Unwind_Exception_Class'Size
                  / Standard'Storage_Unit
               + C.unwind.Unwind_Exception_Cleanup_Fn'Size
                  / Standard'Storage_Unit));
      return Result;
   end New_Machine_Occurrence;

   procedure Free (
      Machine_Occurrence : Representation.Machine_Occurrence_Access) is
   begin
      C.unwind.Unwind_DeleteException (Machine_Occurrence.Header'Access);
   end Free;

end Separated;
