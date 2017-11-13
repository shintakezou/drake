pragma License (Unrestricted);
--  Ada 2005
with Ada.Iterator_Interfaces;
with Ada.References;
private with Ada.Containers.Copy_On_Write;
private with Ada.Finalization;
private with Ada.Streams;
generic
   type Index_Type is range <>;
   type Element_Type is private;
   with function "=" (Left, Right : Element_Type) return Boolean is <>;
package Ada.Containers.Vectors is
   pragma Preelaborate;
   pragma Remote_Types;

   subtype Extended_Index is
      Index_Type'Base range
         Index_Type'First - 1 ..
         Index_Type'Min (Index_Type'Base'Last - 1, Index_Type'Last) + 1;
   No_Index : constant Extended_Index := Extended_Index'First;

   type Vector is tagged private
      with
--       Constant_Indexing => Constant_Reference, -- is overloaded
--       Variable_Indexing => Reference,
         Constant_Indexing => Constant_Indexing,
         Variable_Indexing => Indexing,
         Default_Iterator => Iterate,
         Iterator_Element => Element_Type;
   pragma Preelaborable_Initialization (Vector);

   --  modified
--  type Cursor is private;
--  pragma Preelaborable_Initialization (Cursor);
   subtype Cursor is Extended_Index;

   --  modified
--  Empty_Vector : constant Vector;
   function Empty_Vector return Vector;

   No_Element : Cursor
      renames No_Index;

   function Has_Element (Position : Cursor) return Boolean;

   package Vector_Iterator_Interfaces is
      new Iterator_Interfaces (Cursor, Has_Element);

   overriding function "=" (Left, Right : Vector) return Boolean;

   function To_Vector (Length : Count_Type) return Vector;

   function To_Vector (New_Item : Element_Type; Length : Count_Type)
      return Vector;

   --  extended
   generic
      type Element_Array is array (Index_Type range <>) of Element_Type;
   function Generic_Array_To_Vector (S : Element_Array) return Vector;

   function "&" (Left, Right : Vector) return Vector;

   function "&" (Left : Vector; Right : Element_Type) return Vector;

   function "&" (Left : Element_Type; Right : Vector) return Vector;

   function "&" (Left, Right : Element_Type) return Vector;

   function Capacity (Container : Vector) return Count_Type;

   procedure Reserve_Capacity (
      Container : in out Vector;
      Capacity : Count_Type);

   function Length (Container : Vector) return Count_Type;

   procedure Set_Length (Container : in out Vector; Length : Count_Type);

   function Is_Empty (Container : Vector) return Boolean;

   procedure Clear (Container : in out Vector);

   --  modified
   function To_Cursor (
      Container : Vector'Class; -- not primitive
      Index : Extended_Index)
      return Cursor;

   function To_Index (Position : Cursor) return Extended_Index
      renames "+";

   --  modified
   function Element (
      Container : Vector'Class; -- not primitive
      Index : Index_Type)
      return Element_Type;

--  function Element (Position : Cursor) return Element_Type;

--  procedure Replace_Element (
--    Container : in out Vector;
--    Index : Index_Type;
--    New_Item : Element_Type);

   procedure Replace_Element (
      Container : in out Vector;
      Position : Cursor;
      New_Item : Element_Type);

   --  modified
   procedure Query_Element (
      Container : Vector'Class; -- not primitive
      Index : Index_Type;
      Process : not null access procedure (Element : Element_Type));

--  procedure Query_Element (
--    Position : Cursor;
--    Process : not null access procedure (Element : Element_Type));

--  procedure Update_Element (
--    Container : in out Vector;
--    Index : Index_Type;
--    Process : not null access procedure (Element : in out Element_Type));

   --  modified
   procedure Update_Element (
      Container : in out Vector'Class; -- not primitive
      Position : Cursor;
      Process : not null access procedure (Element : in out Element_Type));

   type Constant_Reference_Type (
      Element : not null access constant Element_Type) is private
      with Implicit_Dereference => Element;

   type Reference_Type (Element : not null access Element_Type) is private
      with Implicit_Dereference => Element;

--  function Constant_Reference (
--    Container : aliased Vector;
--    Index : Index_Type)
--    return Constant_Reference_Type;

--  function Reference (Container : aliased in out Vector; Index : Index_Type)
--    return Reference_Type;

   function Constant_Reference (Container : aliased Vector; Position : Cursor)
      return Constant_Reference_Type;

   function Reference (Container : aliased in out Vector; Position : Cursor)
      return Reference_Type;

   procedure Assign (Target : in out Vector; Source : Vector);

   function Copy (Source : Vector; Capacity : Count_Type := 0) return Vector;

   procedure Move (Target : in out Vector; Source : in out Vector);

--  procedure Insert (
--    Container : in out Vector;
--    Before : Extended_Index;
--    New_Item : Vector);

   procedure Insert (
      Container : in out Vector;
      Before : Cursor;
      New_Item : Vector);

   procedure Insert (
      Container : in out Vector;
      Before : Cursor;
      New_Item : Vector;
      Position : out Cursor);

--  procedure Insert (
--    Container : in out Vector;
--    Before : Extended_Index;
--    New_Item : Element_Type;
--    Count : Count_Type := 1);

   procedure Insert (
      Container : in out Vector;
      Before : Cursor;
      New_Item : Element_Type;
      Count : Count_Type := 1);

   procedure Insert (
      Container : in out Vector;
      Before : Cursor;
      New_Item : Element_Type;
      Position : out Cursor;
      Count : Count_Type := 1);

--  procedure Insert (
--    Container : in out Vector;
--    Before : Extended_Index;
--    Count : Count_Type := 1);

--  procedure Insert (
--    Container : in out Vector;
--    Before : Cursor;
--    Position : out Cursor;
--    Count : Count_Type := 1);

   procedure Prepend (Container : in out Vector; New_Item : Vector);

   procedure Prepend (
      Container : in out Vector;
      New_Item : Element_Type;
      Count : Count_Type := 1);

   procedure Append (Container : in out Vector; New_Item : Vector);

   procedure Append (
      Container : in out Vector;
      New_Item : Element_Type;
      Count : Count_Type := 1);

   --  modified
   procedure Insert_Space (
      Container : in out Vector'Class; -- not primitive
      Before : Extended_Index;
      Count : Count_Type := 1);

   procedure Insert_Space (
      Container : in out Vector;
      Before : Cursor;
      Position : out Cursor;
      Count : Count_Type := 1);

--  procedure Delete (
--    Container : in out Vector;
--    Index : Extended_Index;
--    Count : Count_Type := 1);

   procedure Delete (
      Container : in out Vector;
      Position : in out Cursor;
      Count : Count_Type := 1);

   --  modified
   procedure Delete_First (
      Container : in out Vector'Class; -- not primitive
      Count : Count_Type := 1);

   --  modified
   procedure Delete_Last (
      Container : in out Vector'Class; -- not primitive
      Count : Count_Type := 1);

   procedure Reverse_Elements (Container : in out Vector);

--  procedure Swap (Container : in out Vector; I, J : Index_Type);

   procedure Swap (Container : in out Vector; I, J : Cursor);

   --  modified
   function First_Index (Container : Vector'Class) -- not primitive
      return Index_Type;
   pragma Inline (First_Index);

   function First (Container : Vector) return Cursor;

   --  modified
   function First_Element (Container : Vector'Class) -- not primitive
      return Element_Type;

   --  modified
   function Last_Index (Container : Vector'Class) -- not primitive
      return Extended_Index;
   pragma Inline (Last_Index);

   function Last (Container : Vector) return Cursor;

   --  modified
   function Last_Element (Container : Vector'Class) -- not primitive
      return Element_Type;

--  function Next (Position : Cursor) return Cursor;

--  procedure Next (Position : in out Cursor);

--  function Previous (Position : Cursor) return Cursor;

--  procedure Previous (Position : in out Cursor);

   --  modified
   function Find_Index (
      Container : Vector'Class; -- not primitive
      Item : Element_Type;
      Index : Index_Type := Index_Type'First)
      return Extended_Index;

   --  modified
--  function Find (
--    Container : Vector;
--    Item : Element_Type;
--    Position : Cursor := No_Element)
--    return Cursor;
   function Find (
      Container : Vector;
      Item : Element_Type)
      return Cursor;
   function Find (
      Container : Vector;
      Item : Element_Type;
      Position : Cursor)
      return Cursor;

   --  modified
   function Reverse_Find_Index (
      Container : Vector'Class; -- not primitive
      Item : Element_Type;
      Index : Index_Type := Index_Type'Last)
      return Extended_Index;

   --  modified
--  function Reverse_Find (
--    Container : Vector;
--    Item : Element_Type;
--    Position : Cursor := No_Element)
--    return Cursor;
   function Reverse_Find (
      Container : Vector;
      Item : Element_Type)
      return Cursor;
   function Reverse_Find (
      Container : Vector;
      Item : Element_Type;
      Position : Cursor)
      return Cursor;

   function Contains (Container : Vector; Item : Element_Type)
      return Boolean;

   --  modified
   procedure Iterate (
      Container : Vector'Class; -- not primitive
      Process : not null access procedure (Position : Cursor));

   --  modified
   procedure Reverse_Iterate (
      Container : Vector'Class; -- not primitive
      Process : not null access procedure (Position : Cursor));

   --  modified
   function Iterate (Container : Vector'Class) -- not primitive
      return Vector_Iterator_Interfaces.Reversible_Iterator'Class;

--  function Iterate (Container : Vector; Start : Cursor)
--    return Vector_Iterator_Interfaces.Reversible_Iterator'Class;

   --  extended
   function Iterate (Container : Vector'Class; First, Last : Cursor)
      return Vector_Iterator_Interfaces.Reversible_Iterator'Class;

   --  extended from here
   --  Convenient way to direct access.

   type Element_Array is array (Index_Type range <>) of aliased Element_Type;

   package Slicing is
      new References.Generic_Slicing (Index_Type, Element_Type, Element_Array);

   function Constant_Reference (Container : aliased Vector)
      return Slicing.Constant_Reference_Type;
   function Reference (Container : aliased in out Vector)
      return Slicing.Reference_Type;

   --  to here

   generic
      with function "<" (Left, Right : Element_Type) return Boolean is <>;
   package Generic_Sorting is

      function Is_Sorted (Container : Vector) return Boolean;

      procedure Sort (Container : in out Vector);

      procedure Merge (Target : in out Vector; Source : in out Vector);

   end Generic_Sorting;

--  diff (Equivalents)
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

   --  non-overloaded subprograms
   function Constant_Indexing (
      Container : aliased Vector'Class;
      Index : Index_Type)
      return Constant_Reference_Type;
   function Indexing (
      Container : aliased in out Vector'Class;
      Index : Index_Type)
      return Reference_Type;

   pragma Inline (Constant_Indexing);
   pragma Inline (Indexing);

private

--  diff (Element_Access)
--  diff (Element_Array)

   type Data (Capacity_Last : Extended_Index) is limited record
      Super : aliased Copy_On_Write.Data;
      Max_Length : aliased Count_Type;
      Items : aliased Element_Array (Index_Type'First .. Capacity_Last);
   end record;

   --  place Super at first
   for Data use record
      Super at 0 range 0 .. Copy_On_Write.Data_Size - 1;
   end record;

   type Data_Access is access all Data;

   type Vector is new Finalization.Controlled with record
      Super : aliased Copy_On_Write.Container;
      Length : Count_Type := 0;
   end record;

   overriding procedure Adjust (Object : in out Vector);
   overriding procedure Finalize (Object : in out Vector)
      renames Clear;

   type Constant_Reference_Type (
      Element : not null access constant Element_Type) is null record;

   type Reference_Type (Element : not null access Element_Type) is null record;

   type Vector_Iterator is
      new Vector_Iterator_Interfaces.Reversible_Iterator with
   record
      First : Extended_Index;
      Last : Extended_Index;
   end record;

   overriding function First (Object : Vector_Iterator) return Cursor;
   overriding function Next (Object : Vector_Iterator; Position : Cursor)
      return Cursor;
   overriding function Last (Object : Vector_Iterator) return Cursor;
   overriding function Previous (Object : Vector_Iterator; Position : Cursor)
      return Cursor;

   package Streaming is

      procedure Read (
         Stream : not null access Streams.Root_Stream_Type'Class;
         Item : out Vector);
      procedure Write (
         Stream : not null access Streams.Root_Stream_Type'Class;
         Item : Vector);

      procedure Missing_Read (
         Stream : access Streams.Root_Stream_Type'Class;
         Item : out Constant_Reference_Type)
         with Import,
            Convention => Ada, External_Name => "__drake_program_error";
      procedure Missing_Write (
         Stream : access Streams.Root_Stream_Type'Class;
         Item : Constant_Reference_Type)
         with Import,
            Convention => Ada, External_Name => "__drake_program_error";

      procedure Missing_Read (
         Stream : access Streams.Root_Stream_Type'Class;
         Item : out Reference_Type)
         with Import,
            Convention => Ada, External_Name => "__drake_program_error";
      procedure Missing_Write (
         Stream : access Streams.Root_Stream_Type'Class;
         Item : Reference_Type)
         with Import,
            Convention => Ada, External_Name => "__drake_program_error";

   end Streaming;

   for Vector'Read use Streaming.Read;
   for Vector'Write use Streaming.Write;

   for Constant_Reference_Type'Read use Streaming.Missing_Read;
   for Constant_Reference_Type'Write use Streaming.Missing_Write;

   for Reference_Type'Read use Streaming.Missing_Read;
   for Reference_Type'Write use Streaming.Missing_Write;

end Ada.Containers.Vectors;
