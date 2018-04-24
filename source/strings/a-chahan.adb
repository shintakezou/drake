with Ada.Strings.Naked_Maps.Canonical_Composites;
with Ada.Strings.Naked_Maps.Case_Folding;
with Ada.Strings.Naked_Maps.Case_Mapping;
with Ada.Strings.Naked_Maps.General_Category;
with Ada.Strings.Naked_Maps.Set_Constants;
package body Ada.Characters.Handling is

   function Overloaded_Is_Basic (Item : Wide_Character) return Boolean is
   begin
      return Strings.Naked_Maps.Is_In (
         Strings.Naked_Maps.To_Wide_Wide_Character (Item),
         Strings.Naked_Maps.Canonical_Composites.Base_Set.all);
   end Overloaded_Is_Basic;

   function Overloaded_Is_Basic (Item : Wide_Wide_Character) return Boolean is
   begin
      return Strings.Naked_Maps.Is_In (
         Item,
         Strings.Naked_Maps.Canonical_Composites.Base_Set.all);
   end Overloaded_Is_Basic;

   function Overloaded_Is_Control (Item : Character) return Boolean is
   begin
      return Strings.Naked_Maps.Is_In (
         Strings.Naked_Maps.To_Wide_Wide_Character (Item),
         Strings.Naked_Maps.General_Category.Control.all);
   end Overloaded_Is_Control;

   function Overloaded_Is_Control (Item : Wide_Character) return Boolean is
   begin
      return Strings.Naked_Maps.Is_In (
         Strings.Naked_Maps.To_Wide_Wide_Character (Item),
         Strings.Naked_Maps.General_Category.Control.all);
   end Overloaded_Is_Control;

   function Overloaded_Is_Control (Item : Wide_Wide_Character)
      return Boolean is
   begin
      return Strings.Naked_Maps.Is_In (
         Item,
         Strings.Naked_Maps.General_Category.Control.all);
   end Overloaded_Is_Control;

   function Overloaded_Is_Graphic (Item : Character) return Boolean is
   begin
      return Strings.Naked_Maps.Is_In (
         Strings.Naked_Maps.To_Wide_Wide_Character (Item),
         Strings.Naked_Maps.Set_Constants.Graphic_Set.all);
   end Overloaded_Is_Graphic;

   function Overloaded_Is_Graphic (Item : Wide_Character) return Boolean is
   begin
      return Strings.Naked_Maps.Is_In (
         Strings.Naked_Maps.To_Wide_Wide_Character (Item),
         Strings.Naked_Maps.Set_Constants.Graphic_Set.all);
   end Overloaded_Is_Graphic;

   function Overloaded_Is_Graphic (Item : Wide_Wide_Character)
      return Boolean is
   begin
      return Strings.Naked_Maps.Is_In (
         Item,
         Strings.Naked_Maps.Set_Constants.Graphic_Set.all);
   end Overloaded_Is_Graphic;

   function Overloaded_Is_Letter (Item : Character) return Boolean is
   begin
      return Strings.Naked_Maps.Is_In (
         Strings.Naked_Maps.To_Wide_Wide_Character (Item),
         Strings.Naked_Maps.Set_Constants.Letter_Set.all);
   end Overloaded_Is_Letter;

   function Overloaded_Is_Letter (Item : Wide_Character) return Boolean is
   begin
      return Strings.Naked_Maps.Is_In (
         Strings.Naked_Maps.To_Wide_Wide_Character (Item),
         Strings.Naked_Maps.Set_Constants.Letter_Set.all);
   end Overloaded_Is_Letter;

   function Overloaded_Is_Letter (Item : Wide_Wide_Character) return Boolean is
   begin
      return Strings.Naked_Maps.Is_In (
         Item,
         Strings.Naked_Maps.Set_Constants.Letter_Set.all);
   end Overloaded_Is_Letter;

   function Overloaded_Is_Lower (Item : Character) return Boolean is
   begin
      return Strings.Naked_Maps.Is_In (
         Strings.Naked_Maps.To_Wide_Wide_Character (Item),
         Strings.Naked_Maps.General_Category.Lowercase_Letter.all);
   end Overloaded_Is_Lower;

   function Overloaded_Is_Lower (Item : Wide_Character) return Boolean is
   begin
      return Strings.Naked_Maps.Is_In (
         Strings.Naked_Maps.To_Wide_Wide_Character (Item),
         Strings.Naked_Maps.General_Category.Lowercase_Letter.all);
   end Overloaded_Is_Lower;

   function Overloaded_Is_Lower (Item : Wide_Wide_Character) return Boolean is
   begin
      return Strings.Naked_Maps.Is_In (
         Item,
         Strings.Naked_Maps.General_Category.Lowercase_Letter.all);
   end Overloaded_Is_Lower;

   function Overloaded_Is_Upper (Item : Character) return Boolean is
   begin
      return Strings.Naked_Maps.Is_In (
         Strings.Naked_Maps.To_Wide_Wide_Character (Item),
         Strings.Naked_Maps.General_Category.Uppercase_Letter.all);
   end Overloaded_Is_Upper;

   function Overloaded_Is_Upper (Item : Wide_Character) return Boolean is
   begin
      return Strings.Naked_Maps.Is_In (
         Strings.Naked_Maps.To_Wide_Wide_Character (Item),
         Strings.Naked_Maps.General_Category.Uppercase_Letter.all);
   end Overloaded_Is_Upper;

   function Overloaded_Is_Upper (Item : Wide_Wide_Character) return Boolean is
   begin
      return Strings.Naked_Maps.Is_In (
         Item,
         Strings.Naked_Maps.General_Category.Uppercase_Letter.all);
   end Overloaded_Is_Upper;

   function Overloaded_Is_Digit (Item : Character) return Boolean is
   begin
      return Strings.Naked_Maps.Is_In (
         Strings.Naked_Maps.To_Wide_Wide_Character (Item),
         Strings.Naked_Maps.Set_Constants.Decimal_Digit_Set.all);
   end Overloaded_Is_Digit;

   function Overloaded_Is_Digit (Item : Wide_Character) return Boolean is
   begin
      return Strings.Naked_Maps.Is_In (
         Strings.Naked_Maps.To_Wide_Wide_Character (Item),
         Strings.Naked_Maps.Set_Constants.Decimal_Digit_Set.all);
   end Overloaded_Is_Digit;

   function Overloaded_Is_Digit (Item : Wide_Wide_Character) return Boolean is
   begin
      return Strings.Naked_Maps.Is_In (
         Item,
         Strings.Naked_Maps.Set_Constants.Decimal_Digit_Set.all);
   end Overloaded_Is_Digit;

   function Overloaded_Is_Hexadecimal_Digit (Item : Character)
      return Boolean is
   begin
      return Strings.Naked_Maps.Is_In (
         Strings.Naked_Maps.To_Wide_Wide_Character (Item),
         Strings.Naked_Maps.Set_Constants.Hexadecimal_Digit_Set.all);
   end Overloaded_Is_Hexadecimal_Digit;

   function Overloaded_Is_Hexadecimal_Digit (Item : Wide_Character)
      return Boolean is
   begin
      return Strings.Naked_Maps.Is_In (
         Strings.Naked_Maps.To_Wide_Wide_Character (Item),
         Strings.Naked_Maps.Set_Constants.Hexadecimal_Digit_Set.all);
   end Overloaded_Is_Hexadecimal_Digit;

   function Overloaded_Is_Hexadecimal_Digit (Item : Wide_Wide_Character)
      return Boolean is
   begin
      return Strings.Naked_Maps.Is_In (
         Item,
         Strings.Naked_Maps.Set_Constants.Hexadecimal_Digit_Set.all);
   end Overloaded_Is_Hexadecimal_Digit;

   function Overloaded_Is_Alphanumeric (Item : Character) return Boolean is
   begin
      return Strings.Naked_Maps.Is_In (
         Strings.Naked_Maps.To_Wide_Wide_Character (Item),
         Strings.Naked_Maps.Set_Constants.Alphanumeric_Set.all);
   end Overloaded_Is_Alphanumeric;

   function Overloaded_Is_Alphanumeric (Item : Wide_Character)
      return Boolean is
   begin
      return Strings.Naked_Maps.Is_In (
         Strings.Naked_Maps.To_Wide_Wide_Character (Item),
         Strings.Naked_Maps.Set_Constants.Alphanumeric_Set.all);
   end Overloaded_Is_Alphanumeric;

   function Overloaded_Is_Alphanumeric (Item : Wide_Wide_Character)
      return Boolean is
   begin
      return Strings.Naked_Maps.Is_In (
         Item,
         Strings.Naked_Maps.Set_Constants.Alphanumeric_Set.all);
   end Overloaded_Is_Alphanumeric;

   function Overloaded_Is_Special (Item : Character) return Boolean is
   begin
      return Strings.Naked_Maps.Is_In (
         Strings.Naked_Maps.To_Wide_Wide_Character (Item),
         Strings.Naked_Maps.Set_Constants.Special_Set.all);
   end Overloaded_Is_Special;

   function Overloaded_Is_Special (Item : Wide_Character) return Boolean is
   begin
      return Strings.Naked_Maps.Is_In (
         Strings.Naked_Maps.To_Wide_Wide_Character (Item),
         Strings.Naked_Maps.Set_Constants.Special_Set.all);
   end Overloaded_Is_Special;

   function Overloaded_Is_Special (Item : Wide_Wide_Character)
      return Boolean is
   begin
      return Strings.Naked_Maps.Is_In (
         Item,
         Strings.Naked_Maps.Set_Constants.Special_Set.all);
   end Overloaded_Is_Special;

   function Overloaded_To_Lower (Item : Character) return Character is
   begin
      return Strings.Naked_Maps.To_Character (
         Strings.Naked_Maps.Value (
            Strings.Naked_Maps.Case_Mapping.Lower_Case_Map.all,
            Strings.Naked_Maps.To_Wide_Wide_Character (Item)));
   end Overloaded_To_Lower;

   function Overloaded_To_Lower (Item : Wide_Character)
      return Wide_Character is
   begin
      return Strings.Naked_Maps.To_Wide_Character (
         Strings.Naked_Maps.Value (
            Strings.Naked_Maps.Case_Mapping.Lower_Case_Map.all,
            Strings.Naked_Maps.To_Wide_Wide_Character (Item)));
   end Overloaded_To_Lower;

   function Overloaded_To_Lower (Item : Wide_Wide_Character)
      return Wide_Wide_Character is
   begin
      return Strings.Naked_Maps.Value (
         Strings.Naked_Maps.Case_Mapping.Lower_Case_Map.all,
         Item);
   end Overloaded_To_Lower;

   function Overloaded_To_Upper (Item : Character) return Character is
   begin
      return Strings.Naked_Maps.To_Character (
         Strings.Naked_Maps.Value (
            Strings.Naked_Maps.Case_Mapping.Upper_Case_Map.all,
            Strings.Naked_Maps.To_Wide_Wide_Character (Item)));
   end Overloaded_To_Upper;

   function Overloaded_To_Upper (Item : Wide_Character)
      return Wide_Character is
   begin
      return Strings.Naked_Maps.To_Wide_Character (
         Strings.Naked_Maps.Value (
            Strings.Naked_Maps.Case_Mapping.Upper_Case_Map.all,
            Strings.Naked_Maps.To_Wide_Wide_Character (Item)));
   end Overloaded_To_Upper;

   function Overloaded_To_Upper (Item : Wide_Wide_Character)
      return Wide_Wide_Character is
   begin
      return Strings.Naked_Maps.Value (
         Strings.Naked_Maps.Case_Mapping.Upper_Case_Map.all,
         Item);
   end Overloaded_To_Upper;

   function Overloaded_To_Basic (Item : Character) return Character is
   begin
      return Item; -- all letters are "basic" in ASCII
   end Overloaded_To_Basic;

   function Overloaded_To_Basic (Item : Wide_Character)
      return Wide_Character is
   begin
      return Strings.Naked_Maps.To_Wide_Character (
         Strings.Naked_Maps.Value (
            Strings.Naked_Maps.Canonical_Composites.Basic_Map.all,
            Strings.Naked_Maps.To_Wide_Wide_Character (Item)));
   end Overloaded_To_Basic;

   function Overloaded_To_Basic (Item : Wide_Wide_Character)
      return Wide_Wide_Character is
   begin
      return Strings.Naked_Maps.Value (
         Strings.Naked_Maps.Canonical_Composites.Basic_Map.all,
         Item);
   end Overloaded_To_Basic;

   function Overloaded_To_Lower (Item : String) return String is
   begin
      return Strings.Naked_Maps.Translate (
         Item,
         Strings.Naked_Maps.Case_Mapping.Lower_Case_Map.all);
   end Overloaded_To_Lower;

   function Overloaded_To_Lower (Item : Wide_String) return Wide_String is
   begin
      return Strings.Naked_Maps.Translate (
         Item,
         Strings.Naked_Maps.Case_Mapping.Lower_Case_Map.all);
   end Overloaded_To_Lower;

   function Overloaded_To_Lower (Item : Wide_Wide_String)
      return Wide_Wide_String is
   begin
      return Strings.Naked_Maps.Translate (
         Item,
         Strings.Naked_Maps.Case_Mapping.Lower_Case_Map.all);
   end Overloaded_To_Lower;

   function Overloaded_To_Upper (Item : String) return String is
   begin
      return Strings.Naked_Maps.Translate (
         Item,
         Strings.Naked_Maps.Case_Mapping.Upper_Case_Map.all);
   end Overloaded_To_Upper;

   function Overloaded_To_Upper (Item : Wide_String) return Wide_String is
   begin
      return Strings.Naked_Maps.Translate (
         Item,
         Strings.Naked_Maps.Case_Mapping.Upper_Case_Map.all);
   end Overloaded_To_Upper;

   function Overloaded_To_Upper (Item : Wide_Wide_String)
      return Wide_Wide_String is
   begin
      return Strings.Naked_Maps.Translate (
         Item,
         Strings.Naked_Maps.Case_Mapping.Upper_Case_Map.all);
   end Overloaded_To_Upper;

   function Overloaded_To_Basic (Item : String) return String is
   begin
      return Strings.Naked_Maps.Translate (
         Item,
         Strings.Naked_Maps.Canonical_Composites.Basic_Map.all);
   end Overloaded_To_Basic;

   function Overloaded_To_Basic (Item : Wide_String) return Wide_String is
   begin
      return Strings.Naked_Maps.Translate (
         Item,
         Strings.Naked_Maps.Canonical_Composites.Basic_Map.all);
   end Overloaded_To_Basic;

   function Overloaded_To_Basic (Item : Wide_Wide_String)
      return Wide_Wide_String is
   begin
      return Strings.Naked_Maps.Translate (
         Item,
         Strings.Naked_Maps.Canonical_Composites.Basic_Map.all);
   end Overloaded_To_Basic;

   function To_Case_Folding (Item : String) return String is
   begin
      return Strings.Naked_Maps.Translate (
         Item,
         Strings.Naked_Maps.Case_Folding.Case_Folding_Map.all);
   end To_Case_Folding;

   function Is_ISO_646 (Item : Character) return Boolean is
   begin
      return Item in ISO_646;
   end Is_ISO_646;

   function Is_ISO_646 (Item : String) return Boolean is
   begin
      for I in Item'Range loop
         if Item (I) not in ISO_646 then
            return False;
         end if;
      end loop;
      return True;
   end Is_ISO_646;

   function To_ISO_646 (Item : Character; Substitute : ISO_646 := ' ')
      return ISO_646 is
   begin
      if Is_ISO_646 (Item) then
         return Item;
      else
         return Substitute;
      end if;
   end To_ISO_646;

   function To_ISO_646 (Item : String; Substitute : ISO_646 := ' ')
      return String
   is
      Wide_Wide_Substitute : constant Wide_Wide_Character :=
         Wide_Wide_Character'Val (Character'Pos (Substitute));
      Result : String (1 .. Item'Length);
      Last : Natural := 0;
      I : Natural := Item'First - 1;
   begin
      while I < Item'Last loop
         declare
            Item_Last : Natural;
            C : Wide_Wide_Character;
         begin
            Conversions.Get (Item (I + 1 .. Item'Last), Item_Last, C,
               Substitute => Wide_Wide_Substitute);
            if Wide_Wide_Character'Pos (C) > Character'Pos (ISO_646'Last) then
               C := Wide_Wide_Substitute;
            end if;
            Last := Last + 1;
            Result (Last) := Character'Val (Wide_Wide_Character'Pos (C));
            I := Item_Last;
         end;
      end loop;
      return Result (1 .. Last);
   end To_ISO_646;

end Ada.Characters.Handling;
