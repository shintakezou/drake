pragma License (Unrestricted);
with Ada.Strings.Bounded_Strings.Functions.Maps;
with Ada.Strings.Maps;
package Ada.Strings.Bounded is
   pragma Preelaborate;

   generic
      Max : Positive; -- Maximum length of a Bounded_String
   package Generic_Bounded_Length is

      --  for renaming
      package Bounded_Strings is
         new Strings.Bounded_Strings.Generic_Bounded_Length (Max);
      package Functions is
         new Strings.Bounded_Strings.Functions.Generic_Bounded_Length (
            Bounded_Strings);
      package Maps is
         new Strings.Bounded_Strings.Functions.Maps.Generic_Bounded_Length (
            Bounded_Strings);

--    Max_Length : constant Positive := Max;
      Max_Length : Positive
         renames Bounded_Strings.Max_Length;

--    type Bounded_String is private;
      subtype Bounded_String is Bounded_Strings.Bounded_String;

      --  modified
--    Null_Bounded_String : constant Bounded_String;
      function Null_Bounded_String return Bounded_String
         renames Bounded_Strings.Null_Bounded_String;

--    subtype Length_Range is Natural range 0 .. Max_Length;
      subtype Length_Range is Bounded_Strings.Length_Range;

      function Length (Source : Bounded_String) return Length_Range
         renames Bounded_Strings.Length;

      --  Conversion, Concatenation, and Selection functions

      function To_Bounded_String (Source : String; Drop : Truncation := Error)
         return Bounded_String
         renames Bounded_Strings.To_Bounded_String;

      function To_String (Source : Bounded_String) return String
         renames Bounded_Strings.To_String;

      procedure Set_Bounded_String (
         Target : out Bounded_String;
         Source : String;
         Drop : Truncation := Error)
         renames Bounded_Strings.Set_Bounded_String;

      function Append (
         Left, Right : Bounded_String;
         Drop : Truncation := Error)
         return Bounded_String
         renames Bounded_Strings.Append;

      function Append (
         Left : Bounded_String;
         Right : String;
         Drop : Truncation := Error)
         return Bounded_String
         renames Bounded_Strings.Append;

      function Append (
         Left : String;
         Right : Bounded_String;
         Drop : Truncation := Error)
         return Bounded_String
         renames Bounded_Strings.Append;

      function Append (
         Left : Bounded_String;
         Right : Character;
         Drop : Truncation := Error)
         return Bounded_String
         renames Bounded_Strings.Append_Element;

      function Append (
         Left : Character;
         Right : Bounded_String;
         Drop : Truncation := Error)
         return Bounded_String
         renames Bounded_Strings.Append_Element;

      procedure Append (
         Source : in out Bounded_String;
         New_Item : Bounded_String;
         Drop : Truncation := Error)
         renames Bounded_Strings.Append;

      procedure Append (
         Source : in out Bounded_String;
         New_Item : String;
         Drop : Truncation := Error)
         renames Bounded_Strings.Append;

      procedure Append (
         Source : in out Bounded_String;
         New_Item : Character;
         Drop : Truncation := Error)
         renames Bounded_Strings.Append_Element;

      function "&" (Left, Right : Bounded_String)
         return Bounded_String
         renames Bounded_Strings."&";

      function "&" (Left : Bounded_String; Right : String)
         return Bounded_String
         renames Bounded_Strings."&";

      function "&" (Left : String; Right : Bounded_String)
         return Bounded_String
         renames Bounded_Strings."&";

      function "&" (Left : Bounded_String; Right : Character)
         return Bounded_String
         renames Bounded_Strings."&";

      function "&" (Left : Character; Right : Bounded_String)
         return Bounded_String
         renames Bounded_Strings."&";

      function Element (
         Source : Bounded_String;
         Index : Positive)
         return Character
         renames Bounded_Strings.Element;

      procedure Replace_Element (
         Source : in out Bounded_String;
         Index : Positive;
         By : Character)
         renames Bounded_Strings.Replace_Element;

      function Slice (
         Source : Bounded_String;
         Low : Positive;
         High : Natural)
         return String
         renames Bounded_Strings.Slice;

      function Bounded_Slice (
         Source : Bounded_String;
         Low : Positive;
         High : Natural)
         return Bounded_String
         renames Bounded_Strings.Bounded_Slice;

      procedure Bounded_Slice (
         Source : Bounded_String;
         Target : out Bounded_String;
         Low : Positive;
         High : Natural)
         renames Bounded_Strings.Bounded_Slice;

      function "=" (Left, Right : Bounded_String) return Boolean
         renames Bounded_Strings."=";
         --  In CXA4028, "=" is conflicted with itself by "use" and "use type",
         --    but CXA5011 requires that "=" should be primitive.
      function "=" (Left : Bounded_String; Right : String) return Boolean
         renames Bounded_Strings."=";

      function "=" (Left : String; Right : Bounded_String) return Boolean
         renames Bounded_Strings."=";

      function "<" (Left, Right : Bounded_String) return Boolean
         renames Bounded_Strings."<";

      function "<" (Left : Bounded_String; Right : String) return Boolean
         renames Bounded_Strings."<";

      function "<" (Left : String; Right : Bounded_String) return Boolean
         renames Bounded_Strings."<";

      function "<=" (Left, Right : Bounded_String) return Boolean
         renames Bounded_Strings."<=";

      function "<=" (Left : Bounded_String; Right : String) return Boolean
         renames Bounded_Strings."<=";

      function "<=" (Left : String; Right : Bounded_String) return Boolean
         renames Bounded_Strings."<=";

      function ">" (Left, Right : Bounded_String) return Boolean
         renames Bounded_Strings.">";

      function ">" (Left : Bounded_String; Right : String) return Boolean
         renames Bounded_Strings.">";

      function ">" (Left : String; Right : Bounded_String) return Boolean
         renames Bounded_Strings.">";

      function ">=" (Left, Right : Bounded_String) return Boolean
         renames Bounded_Strings.">=";

      function ">=" (Left : Bounded_String; Right : String) return Boolean
         renames Bounded_Strings.">=";

      function ">=" (Left : String; Right : Bounded_String) return Boolean
         renames Bounded_Strings.">=";

      --  Search subprograms

      --  modified
--    function Index (
--       Source : Bounded_String;
--       Pattern : String;
--       From : Positive;
--       Going : Direction := Forward;
--       Mapping : Maps.Character_Mapping := Maps.Identity)
--       return Natural;
      function Index (
         Source : Bounded_String;
         Pattern : String;
         From : Positive;
         Going : Direction := Forward)
         return Natural
         renames Functions.Index;
      function Index (
         Source : Bounded_String;
         Pattern : String;
         From : Positive;
         Going : Direction := Forward;
         Mapping : Strings.Maps.Character_Mapping)
         return Natural
         renames Maps.Index;

      --  modified
--    function Index (
--       Source : Bounded_String;
--       Pattern : String;
--       From : Positive;
--       Going : Direction := Forward;
--       Mapping : Maps.Character_Mapping_Function)
--       return Natural;
      function Index (
         Source : Bounded_String;
         Pattern : String;
         From : Positive;
         Going : Direction := Forward;
         Mapping : not null access function (From : Character)
            return Character)
         return Natural
         renames Maps.Index_Element;
      function Index (
         Source : Bounded_String;
         Pattern : String;
         From : Positive;
         Going : Direction := Forward;
         Mapping : not null access function (From : Wide_Wide_Character)
            return Wide_Wide_Character)
         return Natural
         renames Maps.Index;

      --  modified
--    function Index (
--       Source : Bounded_String;
--       Pattern : String;
--       Going : Direction := Forward;
--       Mapping : Maps.Character_Mapping := Maps.Identity)
--       return Natural;
      function Index (
         Source : Bounded_String;
         Pattern : String;
         Going : Direction := Forward)
         return Natural
         renames Functions.Index;
      function Index (
         Source : Bounded_String;
         Pattern : String;
         Going : Direction := Forward;
         Mapping : Strings.Maps.Character_Mapping)
         return Natural
         renames Maps.Index;

      --  modified
--    function Index (
--       Source : Bounded_String;
--       Pattern : String;
--       Going : Direction := Forward;
--       Mapping : Maps.Character_Mapping_Function)
--       return Natural;
      function Index (
         Source : Bounded_String;
         Pattern : String;
         Going : Direction := Forward;
         Mapping : not null access function (From : Character)
            return Character)
         return Natural
         renames Maps.Index_Element;
      function Index (
         Source : Bounded_String;
         Pattern : String;
         Going : Direction := Forward;
         Mapping : not null access function (From : Wide_Wide_Character)
            return Wide_Wide_Character)
         return Natural
         renames Maps.Index;

      function Index (
         Source : Bounded_String;
         Set : Strings.Maps.Character_Set;
         From : Positive;
         Test : Membership := Inside;
         Going : Direction := Forward)
         return Natural
         renames Maps.Index;

      function Index (
         Source : Bounded_String;
         Set : Strings.Maps.Character_Set;
         Test : Membership := Inside;
         Going : Direction := Forward)
         return Natural
         renames Maps.Index;

      function Index_Non_Blank (
         Source : Bounded_String;
         From : Positive;
         Going : Direction := Forward)
         return Natural
         renames Functions.Index_Non_Blank;

      function Index_Non_Blank (
         Source : Bounded_String;
         Going : Direction := Forward)
         return Natural
         renames Functions.Index_Non_Blank;

      --  modified
--    function Count (
--       Source : Bounded_String;
--       Pattern : String;
--       Mapping : Maps.Character_Mapping := Maps.Identity)
--       return Natural;
      function Count (
         Source : Bounded_String;
         Pattern : String)
         return Natural
         renames Functions.Count;
      function Count (
         Source : Bounded_String;
         Pattern : String;
         Mapping : Strings.Maps.Character_Mapping)
         return Natural
         renames Maps.Count;

      --  modified
--    function Count (
--       Source : Bounded_String;
--       Pattern : String;
--       Mapping : Maps.Character_Mapping_Function)
--       return Natural;
      function Count (
         Source : Bounded_String;
         Pattern : String;
         Mapping : not null access function (From : Character)
            return Character)
         return Natural
         renames Maps.Count_Element;
      function Count (
         Source : Bounded_String;
         Pattern : String;
         Mapping : not null access function (From : Wide_Wide_Character)
            return Wide_Wide_Character)
         return Natural
         renames Maps.Count;

      function Count (
         Source : Bounded_String;
         Set : Strings.Maps.Character_Set)
         return Natural
         renames Maps.Count;

      procedure Find_Token (
         Source : Bounded_String;
         Set : Strings.Maps.Character_Set;
         From : Positive;
         Test : Membership;
         First : out Positive;
         Last : out Natural)
         renames Maps.Find_Token;

      procedure Find_Token (
         Source : Bounded_String;
         Set : Strings.Maps.Character_Set;
         Test : Membership;
         First : out Positive;
         Last : out Natural)
         renames Maps.Find_Token;

      --  String translation subprograms

      --  modified
      function Translate (
         Source : Bounded_String;
         Mapping : Strings.Maps.Character_Mapping;
         Drop : Truncation := Error) -- additional
         return Bounded_String
         renames Maps.Translate;

      --  modified
      procedure Translate (
         Source : in out Bounded_String;
         Mapping : Strings.Maps.Character_Mapping;
         Drop : Truncation := Error) -- additional
         renames Maps.Translate;

      --  modified
--    function Translate (
--       Source : Bounded_String;
--       Mapping : Maps.Character_Mapping_Function)
--       return Bounded_String;
      function Translate (
         Source : Bounded_String;
         Mapping : not null access function (From : Character)
            return Character)
         return Bounded_String
         renames Maps.Translate_Element;
      function Translate (
         Source : Bounded_String;
         Mapping : not null access function (From : Wide_Wide_Character)
            return Wide_Wide_Character;
         Drop : Truncation := Error)
         return Bounded_String
         renames Maps.Translate;

      --  modified
--    procedure Translate (
--       Source : in out Bounded_String;
--       Mapping : Maps.Character_Mapping_Function);
      procedure Translate (
         Source : in out Bounded_String;
         Mapping : not null access function (From : Character)
            return Character)
         renames Maps.Translate_Element;
      procedure Translate (
         Source : in out Bounded_String;
         Mapping : not null access function (From : Wide_Wide_Character)
            return Wide_Wide_Character;
         Drop : Truncation := Error)
         renames Maps.Translate;

      --  String transformation subprograms

      function Replace_Slice (
         Source : Bounded_String;
         Low : Positive;
         High : Natural;
         By : String;
         Drop : Truncation := Error)
         return Bounded_String
         renames Functions.Replace_Slice;

      procedure Replace_Slice (
         Source : in out Bounded_String;
         Low : Positive;
         High : Natural;
         By : String;
         Drop : Truncation := Error)
         renames Functions.Replace_Slice;

      function Insert (
         Source : Bounded_String;
         Before : Positive;
         New_Item : String;
         Drop : Truncation := Error)
         return Bounded_String
         renames Functions.Insert;

      procedure Insert (
         Source : in out Bounded_String;
         Before : Positive;
         New_Item : String;
         Drop : Truncation := Error)
         renames Functions.Insert;

      function Overwrite (
         Source : Bounded_String;
         Position : Positive;
         New_Item : String;
         Drop : Truncation := Error)
         return Bounded_String
         renames Functions.Overwrite;

      procedure Overwrite (
         Source : in out Bounded_String;
         Position : Positive;
         New_Item : String;
         Drop : Truncation := Error)
         renames Functions.Overwrite;

      function Delete (
         Source : Bounded_String;
         From : Positive;
         Through : Natural)
         return Bounded_String
         renames Functions.Delete;

      procedure Delete (
         Source : in out Bounded_String;
         From : Positive;
         Through : Natural)
         renames Functions.Delete;

      --  String selector subprograms

      --  modified
      function Trim (
         Source : Bounded_String;
         Side : Trim_End;
         Blank : Character := Space) -- additional
         return Bounded_String
         renames Functions.Trim;
      procedure Trim (
         Source : in out Bounded_String;
         Side : Trim_End;
         Blank : Character := Space) -- additional
         renames Functions.Trim;

      function Trim (
         Source : Bounded_String;
         Left : Strings.Maps.Character_Set;
         Right : Strings.Maps.Character_Set)
         return Bounded_String
         renames Maps.Trim;

      procedure Trim (
         Source : in out Bounded_String;
         Left : Strings.Maps.Character_Set;
         Right : Strings.Maps.Character_Set)
         renames Maps.Trim;

      function Head (
         Source : Bounded_String;
         Count : Natural;
         Pad : Character := Space;
         Drop : Truncation := Error)
         return Bounded_String
         renames Functions.Head;

      procedure Head (
         Source : in out Bounded_String;
         Count : Natural;
         Pad : Character := Space;
         Drop : Truncation := Error)
         renames Functions.Head;

      function Tail (
         Source : Bounded_String;
         Count : Natural;
         Pad : Character := Space;
         Drop : Truncation := Error)
         return Bounded_String
         renames Functions.Tail;

      procedure Tail (
         Source : in out Bounded_String;
         Count : Natural;
         Pad : Character := Space;
         Drop : Truncation := Error)
         renames Functions.Tail;

      --  String constructor subprograms

      function "*" (Left : Natural; Right : Character)
         return Bounded_String
         renames Bounded_Strings."*";

      function "*" (Left : Natural; Right : String)
         return Bounded_String
         renames Bounded_Strings."*";

      function "*" (Left : Natural; Right : Bounded_String)
         return Bounded_String
         renames Bounded_Strings."*";

      function Replicate (
         Count : Natural;
         Item : Character;
         Drop : Truncation := Error)
         return Bounded_String
         renames Bounded_Strings.Replicate_Element;

      function Replicate (
         Count : Natural;
         Item : String;
         Drop : Truncation := Error)
         return Bounded_String
         renames Bounded_Strings.Replicate;

      function Replicate (
         Count : Natural;
         Item : Bounded_String;
         Drop : Truncation := Error)
         return Bounded_String
         renames Bounded_Strings.Replicate;

   end Generic_Bounded_Length;

end Ada.Strings.Bounded;
