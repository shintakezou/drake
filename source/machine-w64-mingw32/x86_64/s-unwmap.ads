pragma License (Unrestricted);
--  overridable runtime unit specialized for Windows (x86_64)
with System.Unwind.Representation;
with C.winnt;
package System.Unwind.Mapping is
   pragma Preelaborate;

   --  signal alt stack
   type Signal_Stack_Type is private;

   --  register signal handler (init.c/seh_init.c)
   procedure Install_Exception_Handler (SEH : Address) is null;
   pragma Export (Ada, Install_Exception_Handler,
      "__drake_install_exception_handler");

   procedure Install_Task_Exception_Handler (
      SEH : Address;
      Signal_Stack : not null access Signal_Stack_Type) is null;
   pragma Export (Ada, Install_Task_Exception_Handler,
      "__drake_install_task_exception_handler");

   procedure Reinstall_Exception_Handler is null;
   pragma Export (Ada, Reinstall_Exception_Handler,
      "__drake_reinstall_exception_handler");

   --  equivalent to __gnat_map_SEH (seh_init.c)
   --    and Create_Machine_Occurrence_From_Signal_Handler (a-except-2005.adb)
   function New_Machine_Occurrence_From_SEH (
      Exception_Record : C.winnt.struct_EXCEPTION_RECORD_ptr)
      return Representation.Machine_Occurrence_Access;
   pragma Export (Ada, New_Machine_Occurrence_From_SEH,
      "__drake_new_machine_occurrence_from_seh");

private

   type Signal_Stack_Type is null record;
   pragma Suppress_Initialization (Signal_Stack_Type);

   --  for weak linking,
   --  this symbol will be linked other symbols are used
   Install_Exception_Handler_Ref : constant
      not null access procedure (SEH : Address) :=
      Install_Exception_Handler'Access;
   pragma Export (Ada, Install_Exception_Handler_Ref,
      "__drake_ref_install_exception_handler");

end System.Unwind.Mapping;
