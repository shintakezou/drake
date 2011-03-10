pragma License (Unrestricted);
--  extended package
--  diff (Copy_On_Write)
private with Ada.Containers.Inside.Binary_Trees.Arne_Andersson;
private with Ada.Finalization;
--  diff (Streams)
generic
   type Element_Type (<>) is limited private;
   with function "<" (Left, Right : Element_Type) return Boolean is <>;
--  diff ("=")
package Ada.Containers.Limited_Ordered_Sets is
   pragma Preelaborate;
--  pragma Remote_Types; --  it defends to define Reference_Type...

   function Equivalent_Elements (Left, Right : Element_Type) return Boolean;

   type Set is tagged limited private;
   pragma Preelaborable_Initialization (Set);

   type Cursor is private;
   pragma Preelaborable_Initialization (Cursor);

--  Empty_Set : constant Set;
   function Empty_Set return Set; --  extended

--  No_Element : constant Cursor;
   function No_Element return Cursor; --  extended

--  diff ("=")

   function Equivalent_Sets (Left, Right : Set) return Boolean;

--  diff (To_Set)

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

--  diff (Assign)

--  diff (Copy)

   procedure Move (Target : in out Set; Source : in out Set);

   procedure Insert (
      Container : in out Set;
      New_Item  : not null access function (C : Set) return Element_Type;
      Position  : out Cursor);
--  diff

--  diff (Insert)

--  diff (Include)

--  diff (Replace)

   procedure Exclude (Container : in out Set; Item : Element_Type);

   procedure Delete (Container : in out Set; Item : Element_Type);

   procedure Delete (Container : in out Set; Position  : in out Cursor);

--  procedure Delete_First (Container : in out Set);

--  procedure Delete_Last (Container : in out Set);

--  diff (Union)

--  diff (Union)

--  diff ("or")

   procedure Intersection (Target : in out Set; Source : Set);

--  diff (Intersection)

--  diff ("and")

   procedure Difference (Target : in out Set; Source : Set);

--  diff (Difference)

--  diff ("-")

--  diff (Symmetric_Difference)

--  diff (Symmetric_Difference)

--  diff ("xor")

   function Overlap (Left, Right : Set) return Boolean;

   function Is_Subset (Subset : Set; Of_Set : Set) return Boolean;

   function First (Container : Set) return Cursor;

--  diff (First_Element)

   function Last (Container : Set) return Cursor;

--  diff (Last_Element)

   function Next (Position : Cursor) return Cursor;

   procedure Next (Position : in out Cursor);

   function Previous (Position : Cursor) return Cursor;

   procedure Previous (Position : in out Cursor);

   function Find (Container : Set; Item : Element_Type) return Cursor;

   function Floor (Container : Set; Item : Element_Type) return Cursor;

   function Ceiling (Container : Set; Item : Element_Type) return Cursor;

   function Contains (Container : Set; Item : Element_Type) return Boolean;

   function Has_Element (Position : Cursor) return Boolean;

   function "<" (Left, Right : Cursor) return Boolean;

--  function ">" (Left, Right : Cursor) return Boolean;

--  function "<" (Left : Cursor; Right : Element_Type) return Boolean;

--  function ">" (Left : Cursor; Right : Element_Type) return Boolean;

--  function "<" (Left : Element_Type; Right : Cursor) return Boolean;

--  function ">" (Left : Element_Type; Right : Cursor) return Boolean;

   procedure Iterate (
      Container : Set;
      Process : not null access procedure (Position : Cursor));

   procedure Reverse_Iterate (
      Container : Set;
      Process : not null access procedure (Position : Cursor));

   --  AI05-0212-1
   type Constant_Reference_Type (
      Element : not null access constant Element_Type) is limited private;
   type Reference_Type (
      Element : not null access Element_Type) is limited private;
   function Constant_Reference (
      Container : not null access constant Set;
      Position  : Cursor)
      return Constant_Reference_Type;
   function Reference (
      Container : not null access Set;
      Position  : Cursor)
      return Reference_Type;

   --  AI05-0139-2
--  type Iterator_Type is new Reversible_Iterator with private;
   type Iterator is limited private;
   function First (Object : Iterator) return Cursor;
   function Next (Object : Iterator; Position : Cursor) return Cursor;
   function Last (Object : Iterator) return Cursor;
   function Previous (Object : Iterator; Position : Cursor) return Cursor;
   function Iterate (Container : not null access constant Set)
      return Iterator;

   generic
      type Key_Type (<>) is private;
      with function Key (Element : Element_Type) return Key_Type;
      with function "<" (Left, Right : Key_Type) return Boolean is <>;
   package Generic_Keys is

      function Equivalent_Keys (Left, Right : Key_Type) return Boolean;

      function Key (Position : Cursor) return Key_Type;

--  diff (Element)

--  diff (Replace)
--
--
--

      procedure Exclude (Container : in out Set; Key : Key_Type);

      procedure Delete (Container : in out Set; Key : Key_Type);

      function Find (Container : Set; Key : Key_Type) return Cursor;

      function Floor (Container : Set; Key : Key_Type) return Cursor;

      function Ceiling (Container : Set; Key : Key_Type) return Cursor;

      function Contains (Container : Set; Key : Key_Type) return Boolean;

      procedure Update_Element_Preserving_Key (
         Container : in out Set;
         Position : Cursor;
         Process : not null access procedure (Element : in out Element_Type));

   end Generic_Keys;

   generic
      with function "=" (Left, Right : Element_Type) return Boolean is <>;
   package Equivalents is
      function "=" (Left, Right : Set) return Boolean;
   end Equivalents;

private

   package Binary_Trees renames Containers.Inside.Binary_Trees;
   package Base renames Binary_Trees.Arne_Andersson;
--  diff (Copy_On_Write)

   type Element_Access is access Element_Type;

   type Node is limited record
      Super : aliased Base.Node;
      Element : Element_Access;
   end record;

   --  place Super at first whether Element_Type is controlled-type
   for Node use record
      Super at 0 range 0 .. Base.Node_Size - 1;
   end record;

   type Cursor is access Node;

--  diff (Data)
--
--
--
--

--  diff (Data_Access)

   type Set is new Finalization.Limited_Controlled with record
      Root : Binary_Trees.Node_Access := null;
      Length : Count_Type := 0;
   end record;

--  diff (Adjust)
   overriding procedure Finalize (Object : in out Set)
      renames Clear;

--  diff (No_Primitives)
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
      Element : not null access constant Element_Type) is limited null record;

   type Reference_Type (
      Element : not null access Element_Type) is limited null record;

   type Iterator is not null access constant Set;

end Ada.Containers.Limited_Ordered_Sets;
