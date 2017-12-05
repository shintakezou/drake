with Ada.Exceptions;
with Ada.Interrupts.Names;
with Ada.Unchecked_Conversion;
with System.Formatting;
with System.Long_Long_Integer_Types;
with System.Unwind.Occurrences;
with C.signal;
package body System.Native_Interrupts.Vector is
   use type Ada.Interrupts.Parameterless_Handler;
   use type C.signed_int;
   use type C.unsigned_int;
   use type C.signal.p_sig_fn_t;

   subtype Word_Unsigned is Long_Long_Integer_Types.Word_Unsigned;

   procedure Report (
      Interrupt : Interrupt_Id;
      X : Ada.Exceptions.Exception_Occurrence);
   procedure Report (
      Interrupt : Interrupt_Id;
      X : Ada.Exceptions.Exception_Occurrence)
   is
      function Cast is
         new Ada.Unchecked_Conversion (
            Ada.Exceptions.Exception_Occurrence,
            Unwind.Exception_Occurrence);
      Name_Prefix : constant String := "Interrupt ";
      Name : String (1 .. Name_Prefix'Length + Interrupt_Id'Width);
      Name_Last : Natural;
      Error : Boolean;
   begin
      Name (1 .. Name_Prefix'Length) := Name_Prefix;
      Formatting.Image (
         Word_Unsigned (Interrupt),
         Name (Name_Prefix'Length + 1 .. Name'Last),
         Name_Last,
         Error => Error);
      Unwind.Occurrences.Report (Cast (X), Name (1 .. Name_Last));
   end Report;

   type Signal_Rec is record
      Installed_Handler : Parameterless_Handler;
      Saved : aliased C.signal.p_sig_fn_t;
   end record;
   pragma Suppress_Initialization (Signal_Rec);

   type Signal_Vec is
      array (
            C.signed_int range
               C.signed_int (Ada.Interrupts.Names.First_Interrupt_Id) ..
               C.signed_int (Ada.Interrupts.Names.Last_Interrupt_Id)) of
         Signal_Rec;
   pragma Suppress_Initialization (Signal_Vec);

   Table : Signal_Vec;

   procedure Handler (Signal_Number : C.signed_int)
      with Convention => C;

   procedure Handler (Signal_Number : C.signed_int) is
   begin
      Table (Signal_Number).Installed_Handler.all;
   exception -- CXC3004, an exception propagated from a handler has no effect
      when E : others =>
         Report (Interrupt_Id (Signal_Number), E);
   end Handler;

   --  implementation

   function Current_Handler (Interrupt : Interrupt_Id)
      return Parameterless_Handler is
   begin
      return Table (Interrupt).Installed_Handler;
   end Current_Handler;

   procedure Exchange_Handler (
      Old_Handler : out Parameterless_Handler;
      New_Handler : Parameterless_Handler;
      Interrupt : Interrupt_Id)
   is
      Item : Signal_Rec
         renames Table (Interrupt);
   begin
      Old_Handler := Item.Installed_Handler;
      if Old_Handler = null and then New_Handler /= null then
         Item.Saved := C.signal.signal (
            C.signed_int (Interrupt),
            Handler'Access);
      elsif Old_Handler /= null and then New_Handler = null then
         declare
            Old_Action : C.signal.p_sig_fn_t;
         begin
            Old_Action := C.signal.signal (
               C.signed_int (Interrupt),
               Item.Saved);
            if Old_Action = C.signal.SIG_ERR then
               raise Program_Error;
            end if;
         end;
      end if;
      Item.Installed_Handler := New_Handler;
   end Exchange_Handler;

end System.Native_Interrupts.Vector;
