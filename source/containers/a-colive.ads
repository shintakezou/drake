pragma License (Unrestricted);
--  extended unit
private with Ada.Finalization;
--  diff (Ada.Streams)
--  diff (Interfaces)
generic
   type Index_Type is range <>;
   type Element_Type (<>) is limited private;
--  diff ("=")
package Ada.Containers.Limited_Vectors is
   pragma Preelaborate;
--  pragma Remote_Types; -- [gcc 4.5/4.6] it defends to define Reference_Type

   subtype Extended_Index is Index_Type'Base range
         Index_Type'First - 1 ..
         Index_Type'Min (Index_Type'Base'Last - 1, Index_Type'Last) + 1;
   No_Index : constant Extended_Index := Extended_Index'First;

   type Vector is tagged limited private;
   pragma Preelaborable_Initialization (Vector);

--  diff
--  type Cursor is private;
--  pragma Preelaborable_Initialization (Cursor);
   subtype Cursor is Extended_Index;

--  diff
--  Empty_Vector : constant Vector;
   function Empty_Vector return Vector;

   No_Element : Cursor
      renames No_Index;

   function Has_Element (Position : Cursor) return Boolean;

--  package Vector_Iterator_Interfaces is
--     new Ada.Iterator_Interfaces (Cursor, Has_Element);
   type Iterator is limited private;
   function First (Object : Iterator) return Cursor;
   function Next (Object : Iterator; Position : Cursor) return Cursor;
   function Last (Object : Iterator) return Cursor;
   function Previous (Object : Iterator; Position : Cursor) return Cursor;

--  diff ("=")

   function To_Vector (Length : Count_Type) return Vector;

--  diff (To_Vector)
--

--  diff ("&")

--  diff ("&")

--  diff ("&")

--  diff ("&")

   function Capacity (Container : Vector) return Count_Type;

   procedure Reserve_Capacity (
      Container : in out Vector;
      Capacity : Count_Type);

   function Length (Container : Vector) return Count_Type;

   procedure Set_Length (Container : in out Vector; Length : Count_Type);

   function Is_Empty (Container : Vector) return Boolean;

   procedure Clear (Container : in out Vector);

   function To_Cursor (Container : Vector; Index : Extended_Index)
      return Cursor;

   function To_Index (Position : Cursor) return Extended_Index
      renames "+";

--  diff (Element)
--
--
--
--

--  diff (Element)

   procedure Replace_Element (
      Container : in out Vector;
      Position : Index_Type;
      New_Item : not null access function (C : Vector) return Element_Type);

--  diff (Replace_Element)
--
--
--

   --  modified
   procedure Query_Element (
      Container : Vector'Class; -- not primitive
      Index : Index_Type;
      Process : not null access procedure (Element : Element_Type));

--  procedure Query_Element (
--    Position : Cursor;
--    Process : not null access procedure (Element : Element_Type));

   --  modified
   procedure Update_Element (
      Container : in out Vector'Class; -- not primitive
      Index : Index_Type;
      Process : not null access procedure (Element : in out Element_Type));

--  procedure Update_Element (
--    Container : in out Vector;
--    Position : Cursor;
--    Process : not null access procedure (Element : in out Element_Type));

   type Constant_Reference_Type (
      Element : not null access constant Element_Type) is private;

   type Reference_Type (
      Element : not null access Element_Type) is private;

   function Constant_Reference (
      Container : not null access constant Vector; -- [gcc 4.5/4.6] aliased
      Index : Index_Type)
      return Constant_Reference_Type;

   function Reference (
      Container : not null access Vector; -- [gcc 4.5/4.6] aliased
      Index : Index_Type)
      return Reference_Type;

--  function Constant_Reference (
--    Container : aliased in Vector;
--    Position : Cursor)
--    return Constant_Reference_Type;

--  function Reference (
--    Container : aliased in out Vector;
--    Position : Cursor)
--    return Reference_Type;

--  diff (Assign)

--  diff (Copy)

   procedure Move (Target : in out Vector; Source : in out Vector);

--  diff (Insert)
--
--
--

--  diff (Insert)
--
--
--

--  diff (Insert)
--
--
--
--

--  diff (Insert)
--
--
--
--

--  diff (Insert)
--
--
--
--

   procedure Insert (
      Container : in out Vector;
      Before : Cursor;
      New_Item : not null access function (C : Vector) return Element_Type;
      Position : out Cursor; -- [gcc-4.5] C is a dummy to avoid bug of compiler
      Count : Count_Type := 1);

--  diff (Insert)
--
--
--

--  diff (Insert)
--
--
--
--

--  diff (Prepend)

--  diff (Prepend)
--
--
--

--  diff (Append)

--  diff (Append)
--
--
--

   procedure Insert_Space (
      Container : in out Vector;
      Before : Extended_Index;
      Count : Count_Type := 1);

   procedure Insert_Space (
      Container : in out Vector;
      Before : Cursor;
      Position : out Cursor;
      Count : Count_Type := 1);

   procedure Delete (
      Container : in out Vector;
      Index : Extended_Index;
      Count : Count_Type := 1);

--  procedure Delete (
--    Container : in out Vector;
--    Position : in out Cursor;
--    Count : Count_Type := 1);

   procedure Delete_First (Container : in out Vector; Count : Count_Type := 1);

   procedure Delete_Last (Container : in out Vector; Count : Count_Type := 1);

   procedure Reverse_Elements (Container : in out Vector);

   procedure Swap (Container : in out Vector; I, J : Index_Type);

--  procedure Swap (Container : in out Vector; I, J : Cursor);

   function First_Index (Container : Vector) return Index_Type;

   function First (Container : Vector) return Cursor;

--  diff (First_Element)

   function Last_Index (Container : Vector) return Extended_Index;

   function Last (Container : Vector) return Cursor
      renames Last_Index;

--  diff (Last_Element)

--  function Next (Position : Cursor) return Cursor;

--  procedure Next (Position : in out Cursor);

--  function Previous (Position : Cursor) return Cursor;

--  procedure Previous (Position : in out Cursor);

--  diff (Find_Index)
--
--
--
--

--  diff (Find)
--
--
--
--
--
--
--
--
--
--
--
--
--
--

--  diff (Reverse_Find_Index)
--
--
--
--

--  diff (Reverse_Find)
--
--
--
--
--
--
--
--
--
--
--
--
--
--

--  diff (Contains)

   --  modified
   procedure Iterate (
      Container : Vector'Class; -- not primitive
      Process : not null access procedure (Position : Cursor));

   --  modified
   procedure Reverse_Iterate (
      Container : Vector'Class; -- not primitive
      Process : not null access procedure (Position : Cursor));

--  function Iterate (Container : Vector)
--    return Vector_Iterator_Interfaces.Reversible_Iterator'Class;
   function Iterate (Container : Vector)
      return Iterator;

--  function Iterate (Container : Vector; Start : Cursor)
--    return Vector_Iterator_Interfaces.Reversible_Iterator'Class;

   --  extended
   function Iterate (Container : Vector; First, Last : Cursor)
      return Iterator;

   generic
      with function "<" (Left, Right : Element_Type) return Boolean is <>;
   package Generic_Sorting is
      function Is_Sorted (Container : Vector) return Boolean;
      procedure Sort (Container : in out Vector);
      procedure Merge (Target : in out Vector; Source : in out Vector);
   end Generic_Sorting;

   --  extended
   generic
      with function "=" (Left, Right : Element_Type) return Boolean is <>;
   package Equivalents is
      function "=" (Left, Right : Vector) return Boolean;
      function Find (Container : Vector; Item : Element_Type) return Cursor;
      function Find (Container : Vector;
                     Item : Element_Type;
                     Position : Cursor) return Cursor;
      function Reverse_Find (Container : Vector;
                             Item : Element_Type) return Cursor;
      function Reverse_Find (Container : Vector;
                             Item : Element_Type;
                             Position : Cursor) return Cursor;
      function Contains (Container : Vector; Item : Element_Type)
         return Boolean;
   end Equivalents;
--  diff
--  diff
--  diff

--  diff (Generic_Array_To_Vector)
--
--
--

private

   type Element_Access is access Element_Type;
   type Element_Array is array (Index_Type range <>) of Element_Access;

   type Data (Capacity_Last : Extended_Index) is limited record
--  diff
--  diff
      Items : aliased Element_Array (Index_Type'First .. Capacity_Last);
   end record;

   type Data_Access is access all Data;

   Empty_Data : aliased constant Data := (
      Capacity_Last => Index_Type'First - 1,
--  diff
--  diff
      Items => <>);

   type Vector is new Finalization.Limited_Controlled with record
      Data : not null Data_Access := Empty_Data'Unrestricted_Access;
      Length : Count_Type := 0;
   end record;

--  diff (Adjust)
   overriding procedure Finalize (Object : in out Vector)
      renames Clear;

--  different line (stream attributes are unimplemented)
--
--
--
--
--
--
--

--  diff ('Read)
--  diff ('Write)

   type Constant_Reference_Type (
      Element : not null access constant Element_Type) is null record;
   type Reference_Type (
      Element : not null access Element_Type) is null record;

   type Iterator is record
      First : Extended_Index;
      Last : Extended_Index;
   end record;

end Ada.Containers.Limited_Vectors;
