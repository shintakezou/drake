pragma License (Unrestricted);
--  implementation unit required by compiler
with System.Exponentiations;
with System.Unsigned_Types;
package System.Exp_LLU is
   pragma Pure;

   --  required for "**" by compiler (s-expllu.ads)
   --  Modular types do not raise the exceptions.
   function Exp_Long_Long_Unsigned is
      new Exponentiations.Generic_Exp_Unsigned (
         Unsigned_Types.Long_Long_Unsigned,
         Shift_Left => Unsigned_Types.Shift_Left);

end System.Exp_LLU;
