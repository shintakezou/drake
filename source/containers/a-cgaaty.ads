pragma License (Unrestricted);
--  extended unit
generic
   type Index_Type is range <>;
   type Element_Type is private;
   type Array_Type is array (Index_Type range <>) of Element_Type;
   type Array_Access is access Array_Type;
   with procedure Free (X : in out Array_Access) is <>;
package Ada.Containers.Generic_Array_Access_Types is
   --  There are utilities like Vectors for access-to-array types.
   pragma Preelaborate;

   subtype Extended_Index is
      Index_Type'Base range
         Index_Type'Base'Pred (Index_Type'First) ..
         Index_Type'Last;

   function Length (Container : Array_Access) return Count_Type;

   procedure Set_Length (
      Container : in out Array_Access;
      Length : Count_Type);

   procedure Clear (Container : in out Array_Access)
      renames Free;

   procedure Assign (Target : in out Array_Access; Source : Array_Access);

   procedure Move (
      Target : in out Array_Access;
      Source : in out Array_Access);

   procedure Insert (
      Container : in out Array_Access;
      Before : Extended_Index;
      New_Item : Array_Type);
   procedure Insert (
      Container : in out Array_Access;
      Before : Extended_Index;
      New_Item : Array_Access);
   procedure Insert (
      Container : in out Array_Access;
      Before : Extended_Index;
      New_Item : Element_Type;
      Count : Count_Type := 1);
   procedure Insert (
      Container : in out Array_Access;
      Before : Extended_Index;
      Count : Count_Type := 1);

   procedure Prepend (
      Container : in out Array_Access;
      New_Item : Array_Type);
   procedure Prepend (
      Container : in out Array_Access;
      New_Item : Array_Access);
   procedure Prepend (
      Container : in out Array_Access;
      New_Item : Element_Type;
      Count : Count_Type := 1);
   procedure Prepend (
      Container : in out Array_Access;
      Count : Count_Type := 1);

   procedure Append (
      Container : in out Array_Access;
      New_Item : Array_Type);
   procedure Append (
      Container : in out Array_Access;
      New_Item : Array_Access);
   procedure Append (
      Container : in out Array_Access;
      New_Item : Element_Type;
      Count : Count_Type := 1);
   procedure Append (
      Container : in out Array_Access;
      Count : Count_Type := 1);

   procedure Delete (
      Container : in out Array_Access;
      Index : Extended_Index;
      Count : Count_Type := 1);
   procedure Delete_First (
      Container : in out Array_Access;
      Count : Count_Type := 1);
   procedure Delete_Last (
      Container : in out Array_Access;
      Count : Count_Type := 1);

   procedure Swap (Container : in out Array_Access; I, J : Index_Type);

   function First_Index (Container : Array_Access) return Index_Type;
   function Last_Index (Container : Array_Access) return Extended_Index;

   generic
      with procedure Swap (
         Container : in out Array_Access;
         I, J : Index_Type) is Generic_Array_Access_Types.Swap;
   package Generic_Reversing is

      procedure Reverse_Elements (Container : in out Array_Access);

      procedure Reverse_Rotate_Elements (
         Container : in out Array_Access;
         Before : Extended_Index);
      procedure Juggling_Rotate_Elements (
         Container : in out Array_Access;
         Before : Extended_Index);
      procedure Rotate_Elements (
         Container : in out Array_Access;
         Before : Extended_Index)
         renames Juggling_Rotate_Elements;

   end Generic_Reversing;

   generic
      with function "<" (Left, Right : Element_Type) return Boolean is <>;
      with procedure Swap (
         Container : in out Array_Access;
         I, J : Index_Type) is Generic_Array_Access_Types.Swap;
   package Generic_Sorting is

      function Is_Sorted (Container : Array_Access) return Boolean;

      procedure Insertion_Sort (Container : in out Array_Access);
      procedure Merge_Sort (Container : in out Array_Access);
      procedure Sort (Container : in out Array_Access)
         renames Merge_Sort;

      procedure Merge (
         Target : in out Array_Access;
         Source : in out Array_Access);

   end Generic_Sorting;

   --  Allocating concatenation operators

   type New_Array (<>) is limited private;

   procedure Assign (Target : in out Array_Access; Source : New_Array);

   generic
   package Operators is

      type New_Array_1 (<>) is limited private;
      type New_Array_2 (<>) is limited private;

      function "&" (Left : Array_Access; Right : Element_Type)
         return New_Array;
      function "&" (Left : New_Array_1; Right : Element_Type)
         return New_Array;
      function "&" (Left : Array_Access; Right : Element_Type)
         return New_Array_1;
      function "&" (Left : New_Array_2; Right : Element_Type)
         return New_Array_1;
      function "&" (Left : Array_Access; Right : Element_Type)
         return New_Array_2;

   private

      type New_Array_1 is record
         Data : Array_Access;
         Last : Extended_Index;
      end record;
      pragma Suppress_Initialization (New_Array_1);

      type New_Array_2 is new New_Array_1;

   end Operators;

private

   type New_Array is new Array_Access;

end Ada.Containers.Generic_Array_Access_Types;
