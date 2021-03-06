pragma License (Unrestricted);
--  extended unit
package Ada.References.Wide_Strings is
   --  Returning access values to sliced Wide_String from functions.
   pragma Pure;

   type Constant_Reference_Type (
      Element : not null access constant Wide_String) is null record
      with Implicit_Dereference => Element;
   pragma Suppress_Initialization (Constant_Reference_Type);

   type Reference_Type (Element : not null access Wide_String) is null record
      with Implicit_Dereference => Element;
   pragma Suppress_Initialization (Reference_Type);

   package Slicing is
      new Generic_Slicing (Positive, Wide_Character, Wide_String);

end Ada.References.Wide_Strings;
