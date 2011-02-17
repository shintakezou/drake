pragma License (Unrestricted);
--  implementation package
package Ada.Characters.Inside is
   pragma Pure;

   --  alternative conversions functions raising exception
   --  instead of using substitute.

   function To_Character (Item : Wide_Wide_Character)
      return Character;
   function To_Wide_Wide_Character (Item : Character)
      return Wide_Wide_Character;

   function To_Wide_Character (Item : Wide_Wide_Character)
      return Wide_Character;
   function To_Wide_Wide_Character (Item : Wide_Character)
      return Wide_Wide_Character;

   --  string conversions functions

   function To_String (Item : Wide_Wide_String)
      return String;
   function To_Wide_Wide_String (Item : String)
      return Wide_Wide_String;

   function To_Wide_String (Item : Wide_Wide_String)
      return Wide_String;
   function To_Wide_Wide_String (Item : Wide_String)
      return Wide_Wide_String;

end Ada.Characters.Inside;
