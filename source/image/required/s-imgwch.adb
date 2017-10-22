with System.Formatting;
with System.Img_Char;
with System.Long_Long_Integer_Types;
package body System.Img_WChar is

   subtype Word_Unsigned is Long_Long_Integer_Types.Word_Unsigned;

   --  implementation

   procedure Image_Wide_Character (
      V : Wide_Character;
      S : in out String;
      P : out Natural;
      Ada_2005 : Boolean)
   is
      pragma Unreferenced (Ada_2005);
   begin
      case V is
         when Wide_Character'Val (0) .. Wide_Character'Val (16#7f#) =>
            Img_Char.Image_Character_05 (
               Character'Val (Wide_Character'Pos (V)),
               S,
               P);
         when Wide_Character'Val (16#ad#) =>
            pragma Assert (S'Length >= Image_ad'Length);
            P := S'First - 1 + Image_ad'Length;
            S (S'First .. P) := Image_ad;
         when others =>
            pragma Assert (S'Length >= Img_Char.Hex_Prefix'Length);
            S (S'First .. S'First - 1 + Img_Char.Hex_Prefix'Length) :=
               Img_Char.Hex_Prefix;
            declare
               Error : Boolean;
            begin
               Formatting.Image (
                  Word_Unsigned'(Wide_Character'Pos (V)),
                  S (S'First + Img_Char.Hex_Prefix'Length .. S'Last),
                  P,
                  Base => 16,
                  Width => 4,
                  Error => Error);
               pragma Assert (not Error);
            end;
      end case;
   end Image_Wide_Character;

   procedure Image_Wide_Wide_Character (
      V : Wide_Wide_Character;
      S : in out String;
      P : out Natural)
   is
      subtype WWC is Wide_Wide_Character; -- for the case statement
   begin
      case V is
         when WWC'Val (0) .. WWC'Val (16#7f#) =>
            Img_Char.Image_Character_05 (
               Character'Val (Wide_Wide_Character'Pos (V)),
               S,
               P);
         when WWC'Val (16#ad#) =>
            Image_Wide_Character (
               Wide_Character'Val (Wide_Wide_Character'Pos (V)),
               S,
               P,
               Ada_2005 => True);
         when others =>
            pragma Assert (S'Length >= Img_Char.Hex_Prefix'Length);
            S (S'First .. S'First - 1 + Img_Char.Hex_Prefix'Length) :=
               Img_Char.Hex_Prefix;
            declare
               Error : Boolean;
            begin
               Formatting.Image (
                  Word_Unsigned'(Wide_Wide_Character'Pos (V)),
                  S (S'First + Img_Char.Hex_Prefix'Length .. S'Last),
                  P,
                  Base => 16,
                  Width => 8,
                  Error => Error);
               pragma Assert (not Error);
            end;
      end case;
   end Image_Wide_Wide_Character;

end System.Img_WChar;
