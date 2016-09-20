pragma License (Unrestricted);
--  extended unit
with Ada.Iterator_Interfaces;
--  diff (Copy_On_Write)
private with Ada.Containers.Hash_Tables;
private with Ada.Finalization;
private with Ada.Streams;
generic
   type Element_Type (<>) is limited private;
   with function Hash (Element : Element_Type) return Hash_Type;
   with function Equivalent_Elements (Left, Right : Element_Type)
      return Boolean;
--  diff ("=")
package Ada.Containers.Limited_Hashed_Sets is
   pragma Preelaborate;
   pragma Remote_Types;

   type Set is tagged limited private
      with
         Constant_Indexing => Constant_Reference,
         Default_Iterator => Iterate,
         Iterator_Element => Element_Type;
   pragma Preelaborable_Initialization (Set);

   type Cursor is private;
   pragma Preelaborable_Initialization (Cursor);

--  diff
--  Empty_Set : constant Set;
   function Empty_Set return Set;

   No_Element : constant Cursor;

   function Has_Element (Position : Cursor) return Boolean;

   package Set_Iterator_Interfaces is
      new Iterator_Interfaces (Cursor, Has_Element);

--  diff ("=")

   function Equivalent_Sets (Left, Right : Set) return Boolean;

--  diff (To_Set)

--  diff (Generic_Array_To_Set)
--
--
--
--

   function Capacity (Container : Set) return Count_Type;

   procedure Reserve_Capacity (
      Container : in out Set;
      Capacity : Count_Type);

   function Length (Container : Set) return Count_Type;

   function Is_Empty (Container : Set) return Boolean;

   procedure Clear (Container : in out Set);

--  diff (Element)

--  diff (Replace_Element)
--
--
--

   procedure Query_Element (
      Position : Cursor;
      Process : not null access procedure (Element : Element_Type));

   type Constant_Reference_Type (
      Element : not null access constant Element_Type) is private
      with Implicit_Dereference => Element;

   function Constant_Reference (Container : aliased Set; Position : Cursor)
      return Constant_Reference_Type;

--  diff (Assign)

--  diff (Copy)

   procedure Move (Target : in out Set; Source : in out Set);

   procedure Insert (
      Container : in out Set'Class;
      New_Item : not null access function return Element_Type;
      Position : out Cursor;
      Inserted : out Boolean);

   procedure Insert (
      Container : in out Set'Class;
      New_Item : not null access function return Element_Type);

--  diff (Include)

--  diff (Replace)

   procedure Exclude (Container : in out Set; Item : Element_Type);

   procedure Delete (Container : in out Set; Item : Element_Type);

   procedure Delete (Container : in out Set; Position : in out Cursor);

--  diff (Union)

--  diff (Union)

--  diff ("or")
--

   procedure Intersection (Target : in out Set; Source : Set);

--  diff (Intersection)

--  diff ("and")
--

   procedure Difference (Target : in out Set; Source : Set);

--  diff (Difference)

--  diff ("-")
--

--  diff (Symmetric_Difference)

--  diff (Symmetric_Difference)

--  diff ("xor")
--

   function Overlap (Left, Right : Set) return Boolean;

   function Is_Subset (Subset : Set; Of_Set : Set) return Boolean;

   function First (Container : Set) return Cursor;

   function Next (Position : Cursor) return Cursor;

   procedure Next (Position : in out Cursor);

   function Find (Container : Set; Item : Element_Type) return Cursor;

   function Contains (Container : Set; Item : Element_Type) return Boolean;

   function Equivalent_Elements (Left, Right : Cursor) return Boolean;

   function Equivalent_Elements (Left : Cursor; Right : Element_Type)
      return Boolean;

--  function Equivalent_Elements (Left : Element_Type; Right : Cursor)
--    return Boolean;

   --  modified
   procedure Iterate (
      Container : Set'Class; -- not primitive
      Process : not null access procedure (Position : Cursor));

   --  modified
   function Iterate (Container : Set'Class) -- not primitive
      return Set_Iterator_Interfaces.Forward_Iterator'Class;

   generic
      type Key_Type (<>) is private;
      with function Key (Element : Element_Type) return Key_Type;
      with function Hash (Key : Key_Type) return Hash_Type;
      with function Equivalent_Keys (Left, Right : Key_Type) return Boolean;
   package Generic_Keys is

      function Key (Position : Cursor) return Key_Type;

--  diff (Element)

--  diff (Replace)
--
--
--

      procedure Exclude (Container : in out Set; Key : Key_Type);

      procedure Delete (Container : in out Set; Key : Key_Type);

      function Find (Container : Set; Key : Key_Type) return Cursor;

      function Contains (Container : Set; Key : Key_Type) return Boolean;

      procedure Update_Element_Preserving_Key (
         Container : in out Set;
         Position : Cursor;
         Process : not null access procedure (
            Element : in out Element_Type));

      type Reference_Type (Element : not null access Element_Type) is private
         with Implicit_Dereference => Element;

      function Reference_Preserving_Key (
         Container : aliased in out Set;
         Position : Cursor)
         return Reference_Type;

      function Constant_Reference (Container : aliased Set; Key : Key_Type)
         return Constant_Reference_Type;

      function Reference_Preserving_Key (
         Container : aliased in out Set;
         Key : Key_Type)
         return Reference_Type;

   private

      type Reference_Type (Element : not null access Element_Type) is
         null record;

      --  dummy 'Read and 'Write

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

      for Reference_Type'Read use Missing_Read;
      for Reference_Type'Write use Missing_Write;

   end Generic_Keys;

   --  extended
   generic
      with function "=" (Left, Right : Element_Type) return Boolean is <>;
   package Equivalents is
      function "=" (Left, Right : Set) return Boolean;
   end Equivalents;

private

   type Element_Access is access Element_Type;

   type Node is limited record
      Super : aliased Hash_Tables.Node;
      Element : Element_Access;
   end record;

   --  place Super at first whether Element_Type is controlled-type
   for Node use record
      Super at 0 range 0 .. Hash_Tables.Node_Size - 1;
   end record;

--  diff (Data)
--
--
--
--

--  diff (Data_Access)

   type Set is limited new Finalization.Limited_Controlled with record
      Table : Hash_Tables.Table_Access;
      Length : Count_Type := 0;
   end record;

--  diff (Adjust)
   overriding procedure Finalize (Object : in out Set)
      renames Clear;

   type Cursor is access Node;

   type Constant_Reference_Type (
      Element : not null access constant Element_Type) is null record;

   type Set_Access is access constant Set;
   for Set_Access'Storage_Size use 0;

   type Set_Iterator is
      new Set_Iterator_Interfaces.Forward_Iterator with
   record
      First : Cursor;
   end record;

   overriding function First (Object : Set_Iterator) return Cursor;
   overriding function Next (Object : Set_Iterator; Position : Cursor)
      return Cursor;

   package Streaming is

--  diff (Read)
--
--
--  diff (Write)
--
--

      procedure Missing_Read (
         Stream : access Streams.Root_Stream_Type'Class;
         Item : out Cursor)
         with Import,
            Convention => Ada, External_Name => "__drake_program_error";
      procedure Missing_Write (
         Stream : access Streams.Root_Stream_Type'Class;
         Item : Cursor)
         with Import,
            Convention => Ada, External_Name => "__drake_program_error";

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

   end Streaming;

--  diff ('Read)
--  diff ('Write)

   for Cursor'Read use Streaming.Missing_Read;
   for Cursor'Write use Streaming.Missing_Write;

   for Constant_Reference_Type'Read use Streaming.Missing_Read;
   for Constant_Reference_Type'Write use Streaming.Missing_Write;

   No_Element : constant Cursor := null;

end Ada.Containers.Limited_Hashed_Sets;
