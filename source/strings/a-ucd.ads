pragma License (Unrestricted);
--  implementation unit
private package Ada.UCD is
   --  This is the parent package of Unicode Character Database.
   pragma Pure;

   Version : constant String (1 .. 11) := "Unicode 6.1";

   --  difference between two code points
   type Difference_Base is range -(2 ** 31) .. 2 ** 31 - 1;
   for Difference_Base'Size use 32;
   subtype Difference_8 is Difference_Base range -(2 ** 7) .. 2 ** 7 - 1;
   subtype Difference_16 is Difference_Base range -(2 ** 15) .. 2 ** 15 - 1;
   subtype Difference_32 is Difference_Base;

   --  code point types

   type UCS_4 is mod 16#80000000#; -- same as System.UTF_Conversions.UCS_4

   type UCS_4_Array is array (Positive range <>) of UCS_4;
   for UCS_4_Array'Component_Size use 32;
   pragma Suppress_Initialization (UCS_4_Array);

   subtype UCS_2 is UCS_4 range 0 .. 16#ffff#;

   type UCS_2_Array is array (Positive range <>) of UCS_2;
   for UCS_2_Array'Component_Size use 16;
   pragma Suppress_Initialization (UCS_2_Array);

   type Combining_Class_Type is mod 2 ** 8;

   type East_Asian_Width_Type is (N, Na, H, A, W, F);
      --  same order as Ada.Strings.East_Asian_Width.Width_Kind
   pragma Discard_Names (East_Asian_Width_Type);

   --  set

   type Set_16_Item_Type is record
      Low : UCS_2;
      High : UCS_2;
   end record;
   pragma Suppress_Initialization (Set_16_Item_Type);
   for Set_16_Item_Type'Size use 32; -- 16 + 16
   for Set_16_Item_Type use record
      Low at 0 range 0 .. 15;
      High at 0 range 16 .. 31;
   end record;

   type Set_16_Type is array (Positive range <>) of Set_16_Item_Type;
   pragma Suppress_Initialization (Set_16_Type);
   for Set_16_Type'Component_Size use 32;

   type Set_32_Item_Type is record
      Low : UCS_4;
      High : UCS_4;
   end record;
   pragma Suppress_Initialization (Set_32_Item_Type);
   for Set_32_Item_Type'Size use 64; -- 32 + 32

   type Set_32_Type is array (Positive range <>) of Set_32_Item_Type;
   pragma Suppress_Initialization (Set_32_Type);
   for Set_32_Type'Component_Size use 64;

   --  map

   type Map_16x1_Item_Type is record
      Code : UCS_2;
      Mapping : UCS_2;
   end record;
   pragma Suppress_Initialization (Map_16x1_Item_Type);
   for Map_16x1_Item_Type'Size use 32; -- 16 + 16
   for Map_16x1_Item_Type use record
      Code at 0 range 0 .. 15;
      Mapping at 0 range 16 .. 31;
   end record;

   type Map_16x1_Type is array (Positive range <>) of Map_16x1_Item_Type;
   pragma Suppress_Initialization (Map_16x1_Type);
   for Map_16x1_Type'Component_Size use 32;

   type Map_32x1_Item_Type is record
      Code : UCS_4;
      Mapping : UCS_4;
   end record;
   pragma Suppress_Initialization (Map_32x1_Item_Type);
   for Map_32x1_Item_Type'Size use 64; -- 32 + 32

   type Map_32x1_Type is array (Positive range <>) of Map_32x1_Item_Type;
   pragma Suppress_Initialization (Map_32x1_Type);
   for Map_32x1_Type'Component_Size use 64;

   type Map_16x2_Item_Type is record
      Code : UCS_2;
      Mapping : UCS_2_Array (1 .. 2);
   end record;
   pragma Suppress_Initialization (Map_16x2_Item_Type);
   for Map_16x2_Item_Type'Size use 48; -- 16 + 16 * 2
   for Map_16x2_Item_Type use record
      Code at 0 range 0 .. 15;
      Mapping at 0 range 16 .. 47;
   end record;

   type Map_16x2_Type is array (Positive range <>) of Map_16x2_Item_Type;
   pragma Suppress_Initialization (Map_16x2_Type);
--  for Map_16x2_Type'Component_Size use 48;
      --  [gcc-6] can not initialize explicit 48bit array constants statically

   type Map_32x2_Item_Type is record
      Code : UCS_4;
      Mapping : UCS_4_Array (1 .. 2);
   end record;
   pragma Suppress_Initialization (Map_32x2_Item_Type);
   for Map_32x2_Item_Type'Size use 96; -- 16 + 16 * 2

   type Map_32x2_Type is array (Positive range <>) of Map_32x2_Item_Type;
   pragma Suppress_Initialization (Map_32x2_Type);
   for Map_32x2_Type'Component_Size use 96;

   type Map_16x3_Item_Type is record
      Code : UCS_2;
      Mapping : UCS_2_Array (1 .. 3);
   end record;
   pragma Suppress_Initialization (Map_16x3_Item_Type);
   for Map_16x3_Item_Type'Size use 64; -- 16 + 16 * 3
   for Map_16x3_Item_Type use record
      Code at 0 range 0 .. 15;
      Mapping at 0 range 16 .. 63;
   end record;

   type Map_16x3_Type is array (Positive range <>) of Map_16x3_Item_Type;
   pragma Suppress_Initialization (Map_16x3_Type);
   for Map_16x3_Type'Component_Size use 64;

   --  non-generated tables

   --  see http://www.unicode.org/reports/tr15/#Hangul
   package Hangul is
      SBase : constant := 16#AC00#;
      LBase : constant := 16#1100#;
      VBase : constant := 16#1161#;
      TBase : constant := 16#11A7#;
      LCount : constant := 19;
      VCount : constant := 21;
      TCount : constant := 28;
      NCount : constant := VCount * TCount; -- 588
      SCount : constant := LCount * NCount; -- 11172
   end Hangul;

end Ada.UCD;
