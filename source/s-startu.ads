pragma License (Unrestricted);
--  runtime unit
package System.Startup is
   pragma Preelaborate;

   --  command arguments (initialize.c)

   argc : Integer
      with Export, Convention => C, External_Name => "gnat_argc";

   argv : Address
      with Export, Convention => C, External_Name => "gnat_argv";

   envp : Address
      with Export, Convention => C, External_Name => "gnat_envp";

   --  command status (exit.c)

   Exit_Status : Integer := 0
      with Export, Convention => C, External_Name => "gnat_exit_status";

   --  initialize system (initialize.c)

   procedure Initialize (SEH : Address)
      with Export, Convention => C, External_Name => "__gnat_initialize";

   --  filled by gnatbind (init.c)

   Main_Priority : Integer := -1
      with Export, Convention => C, External_Name => "__gl_main_priority";
   Main_CPU : Integer := -1
      with Export, Convention => C, External_Name => "__gl_main_cpu";
   Time_Slice_Value : Integer := -1
      with Export, Convention => C, External_Name => "__gl_time_slice_val";
   WC_Encoding : Character := 'n'
      with Export, Convention => C, External_Name => "__gl_wc_encoding";
   Locking_Policy : Character := ' '
      with Export, Convention => C, External_Name => "__gl_locking_policy";
   Queuing_Policy : Character := ' '
      with Export, Convention => C, External_Name => "__gl_queuing_policy";
   Task_Dispatching_Policy : Character := ' '
      with Export,
         Convention => C, External_Name => "__gl_task_dispatching_policy";
   Priority_Specific_Dispatching : Address := Null_Address
      with Export,
         Convention => C,
         External_Name => "__gl_priority_specific_dispatching";
   Num_Specific_Dispatching : Integer := 0
      with Export,
         Convention => C, External_Name => "__gl_num_specific_dispatching";
   Interrupt_States : Address := Null_Address
      with Export, Convention => C, External_Name => "__gl_interrupt_states";
   Num_Interrupt_States : Integer := 0
      with Export,
         Convention => C, External_Name => "__gl_num_interrupt_states";
   Unreserve_All_Interrupts : Integer := 0
      with Export,
         Convention => C, External_Name => "__gl_unreserve_all_interrupts";
   Detect_Blocking : Integer := 0
      with Export, Convention => C, External_Name => "__gl_detect_blocking";
   Default_Stack_Size : Integer := -1
      with Export, Convention => C, External_Name => "__gl_default_stack_size";
   Leap_Seconds_Support : Integer := 0
      with Export,
         Convention => C, External_Name => "__gl_leap_seconds_support";
   Bind_Env_Addr : Address := Null_Address
      with Export, Convention => C, External_Name => "__gl_bind_env_addr";

   --  initialize Ada runtime (rtinit.c)

   procedure Runtime_Initialize (Install_Handler : Integer) is null
      with Export,
         Convention => C, External_Name => "__gnat_runtime_initialize";

   --  finalize Ada runtime 1 (rtfinal.c)

   procedure Runtime_Finalize is null
      with Export, Convention => C, External_Name => "__gnat_runtime_finalize";

   --  finalize Ada runtime 2 (s-stalib.adb)

   procedure AdaFinal is null
      with Export,
         Convention => C,
         External_Name => "system__standard_library__adafinal";

   --  finalize system (final.c)

   procedure Finalize is null
      with Export, Convention => C, External_Name => "__gnat_finalize";

   --  finalize library-level controlled objects (s-soflin.ads)

   type Finalize_Library_Objects_Handler is access procedure;
   pragma Suppress (Access_Check, Finalize_Library_Objects_Handler);

   Finalize_Library_Objects : Finalize_Library_Objects_Handler
      with Export,
         Convention => Ada, External_Name => "__gnat_finalize_library_objects";
   pragma Suppress (Access_Check, Finalize_Library_Objects);

end System.Startup;
