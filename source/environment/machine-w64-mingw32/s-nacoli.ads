pragma License (Unrestricted);
--  implementation unit specialized for Windows
package System.Native_Command_Line is
   pragma Preelaborate;

   function Argument_Count return Natural;
   pragma Inline (Argument_Count);

   --  Number => 0 means Command_Name
   function Argument (Number : Natural) return String;

end System.Native_Command_Line;