pragma Check_Policy (Validate => Disable);
--  with Ada.Strings.Naked_Maps.Debug;
with Ada.Unchecked_Conversion;
with Ada.Unchecked_Deallocation;
with System.UTF_Conversions.From_8_To_32;
with System.UTF_Conversions.From_16_To_32;
with System.UTF_Conversions.From_32_To_8;
with System.UTF_Conversions.From_32_To_16;
package body Ada.Strings.Maps is
   use type Naked_Maps.Character_Ranges;

   --  sets

   subtype Nonnull_Set_Data_Access is not null Set_Data_Access;

   function Upcast is
      new Unchecked_Conversion (
         Nonnull_Set_Data_Access,
         System.Reference_Counting.Container);
   function Downcast is
      new Unchecked_Conversion (
         System.Reference_Counting.Container,
         Nonnull_Set_Data_Access);

   type Set_Data_Access_Access is access all Nonnull_Set_Data_Access;
   type Container_Access is access all System.Reference_Counting.Container;

   function Upcast is
      new Unchecked_Conversion (Set_Data_Access_Access, Container_Access);

   procedure Free is new Unchecked_Deallocation (Set_Data, Set_Data_Access);

   procedure Free_Set_Data (
      Data : in out System.Reference_Counting.Data_Access);
   procedure Free_Set_Data (
      Data : in out System.Reference_Counting.Data_Access)
   is
      X : Set_Data_Access := Downcast (Data);
   begin
      Free (X);
      Data := null;
   end Free_Set_Data;

   function Copy_Set_Data (Items : Naked_Maps.Character_Ranges)
      return not null Set_Data_Access;
   function Copy_Set_Data (Items : Naked_Maps.Character_Ranges)
      return not null Set_Data_Access
   is
      Result : Set_Data_Access;
   begin
      if Items'Length = 0 then
         Result := Empty_Set_Data'Unrestricted_Access;
      else
         Result := new Set_Data'(
            Length => Items'Length,
            Reference_Count => 1,
            Items => Items);
      end if;
      return Result;
   end Copy_Set_Data;

   --  "-" operation
   procedure Sub (
      Result : in out Naked_Maps.Character_Ranges;
      Last : out Natural;
      Left, Right : Naked_Maps.Character_Ranges);
   procedure Sub (
      Result : in out Naked_Maps.Character_Ranges;
      Last : out Natural;
      Left, Right : Naked_Maps.Character_Ranges)
   is
      I : Positive := Left'First;
      J : Positive := Right'First;
   begin
      Last := Result'First - 1;
      while I <= Left'Last and then J <= Right'Last loop
         if Left (I).High < Right (I).Low then
            Last := Last + 1;
            Result (Last) := Left (I);
            I := I + 1;
         elsif Left (J).Low > Right (I).High then
            J := J + 1;
         else
            declare
               L : Wide_Wide_Character := Left (I).Low;
            begin
               while L <= Left (I).High and then J <= Right'Last loop
                  if L < Right (J).Low then
                     Last := Last + 1;
                     Result (Last).Low := L;
                     Result (Last).High :=
                        Wide_Wide_Character'Pred (Right (J).Low);
                  end if;
                  L := Wide_Wide_Character'Succ (Right (J).High);
                  if Right (J).High <= Left (I).High then
                     J := J + 1;
                  end if;
               end loop;
               if L <= Left (I).High then
                  Last := Last + 1;
                  Result (Last).Low := L;
                  Result (Last).High := Left (I).High;
               end if;
               I := I + 1;
            end;
         end if;
      end loop;
      --  right is over
      while I <= Left'Last loop
         Last := Last + 1;
         Result (Last) := Left (I);
         I := I + 1;
      end loop;
   end Sub;

   Full_Set_Data : aliased constant Set_Data := (
      Length => 1,
      Reference_Count => System.Reference_Counting.Static,
      Items => (1 => (Wide_Wide_Character'First, Wide_Wide_Character'Last)));

   --  implementation of sets

   function Null_Set return Character_Set is
   begin
      return Create (Empty_Set_Data'Unrestricted_Access);
   end Null_Set;

   function Is_Null (Set : Character_Set) return Boolean is
   begin
      return Controlled_Sets.Reference (Set).Length = 0;
   end Is_Null;

   function Overloaded_To_Set (Ranges : Character_Ranges)
      return Character_Set
   is
      Items : Naked_Maps.Character_Ranges (1 .. Ranges'Length);
      Last : Natural := Items'First - 1;
      Data : Set_Data_Access;
   begin
      for I in Ranges'Range loop
         declare
            E : Character_Range renames Ranges (I);
         begin
            if E.Low <= E.High then
               Naked_Maps.Add (
                  Items,
                  Last,
                  Naked_Maps.To_Wide_Wide_Character (E.Low),
                  Naked_Maps.To_Wide_Wide_Character (E.High));
            end if;
         end;
      end loop;
      Data := Copy_Set_Data (Items (Items'First .. Last));
      pragma Check (Validate, Naked_Maps.Debug.Valid (Data.all));
      return Create (Data);
   end Overloaded_To_Set;

   function Overloaded_To_Set (Ranges : Wide_Character_Ranges)
      return Character_Set
   is
      Items : Naked_Maps.Character_Ranges (1 .. Ranges'Length);
      Last : Natural := Items'First - 1;
      Data : Set_Data_Access;
   begin
      for I in Ranges'Range loop
         declare
            E : Wide_Character_Range renames Ranges (I);
         begin
            if E.Low <= E.High then
               Naked_Maps.Add (
                  Items,
                  Last,
                  Naked_Maps.To_Wide_Wide_Character (E.Low),
                  Naked_Maps.To_Wide_Wide_Character (E.High));
            end if;
         end;
      end loop;
      Data := Copy_Set_Data (Items (Items'First .. Last));
      pragma Check (Validate, Naked_Maps.Debug.Valid (Data.all));
      return Create (Data);
   end Overloaded_To_Set;

   function Overloaded_To_Set (Ranges : Wide_Wide_Character_Ranges)
      return Character_Set
   is
      Items : Naked_Maps.Character_Ranges (1 .. Ranges'Length);
      Last : Natural := Items'First - 1;
      Data : Set_Data_Access;
   begin
      for I in Ranges'Range loop
         declare
            E : Wide_Wide_Character_Range renames Ranges (I);
         begin
            if E.Low <= E.High then
               Naked_Maps.Add (Items, Last, E.Low, E.High);
            end if;
         end;
      end loop;
      Data := Copy_Set_Data (Items (Items'First .. Last));
      pragma Check (Validate, Naked_Maps.Debug.Valid (Data.all));
      return Create (Data);
   end Overloaded_To_Set;

   function Overloaded_To_Set (Span : Character_Range)
      return Character_Set is
   begin
      return Overloaded_To_Set (
         Wide_Wide_Character_Range'(
            Naked_Maps.To_Wide_Wide_Character (Span.Low),
            Naked_Maps.To_Wide_Wide_Character (Span.High)));
   end Overloaded_To_Set;

   function Overloaded_To_Set (Span : Wide_Character_Range)
      return Character_Set is
   begin
      return Overloaded_To_Set (
         Wide_Wide_Character_Range'(
            Naked_Maps.To_Wide_Wide_Character (Span.Low),
            Naked_Maps.To_Wide_Wide_Character (Span.High)));
   end Overloaded_To_Set;

   function Overloaded_To_Set (Span : Wide_Wide_Character_Range)
      return Character_Set
   is
      Data : Set_Data_Access;
   begin
      if Span.Low > Span.High then
         Data := Empty_Set_Data'Unrestricted_Access;
      else
         Data := new Set_Data'(
            Length => 1,
            Reference_Count => 1,
            Items => <>);
         Data.Items (Data.Items'First).Low := Span.Low;
         Data.Items (Data.Items'First).High := Span.High;
      end if;
      return Create (Data);
   end Overloaded_To_Set;

   function Overloaded_To_Ranges (Set : Character_Set)
      return Character_Ranges
   is
      Set_Data : constant not null Set_Data_Access :=
         Controlled_Sets.Reference (Set);
      pragma Check (Validate, Naked_Maps.Debug.Valid (Set_Data.all));
   begin
      return Result : Character_Ranges (Set_Data.Items'Range) do
         for I in Result'Range loop
            Result (I).Low :=
               Naked_Maps.To_Character (Set_Data.Items (I).Low);
            Result (I).High :=
               Naked_Maps.To_Character (Set_Data.Items (I).High);
         end loop;
      end return;
   end Overloaded_To_Ranges;

   function Overloaded_To_Ranges (Set : Character_Set)
      return Wide_Character_Ranges
   is
      Set_Data : constant not null Set_Data_Access :=
         Controlled_Sets.Reference (Set);
      pragma Check (Validate, Naked_Maps.Debug.Valid (Set_Data.all));
   begin
      return Result : Wide_Character_Ranges (Set_Data.Items'Range) do
         for I in Result'Range loop
            Result (I).Low :=
               Naked_Maps.To_Wide_Character (Set_Data.Items (I).Low);
            Result (I).High :=
               Naked_Maps.To_Wide_Character (Set_Data.Items (I).High);
         end loop;
      end return;
   end Overloaded_To_Ranges;

   function Overloaded_To_Ranges (Set : Character_Set)
      return Wide_Wide_Character_Ranges
   is
      Set_Data : constant not null Set_Data_Access :=
         Controlled_Sets.Reference (Set);
      pragma Check (Validate, Naked_Maps.Debug.Valid (Set_Data.all));
   begin
      return Result : Wide_Wide_Character_Ranges (Set_Data.Items'Range) do
         for I in Result'Range loop
            Result (I).Low := Set_Data.Items (I).Low;
            Result (I).High := Set_Data.Items (I).High;
         end loop;
      end return;
   end Overloaded_To_Ranges;

   overriding function "=" (Left, Right : Character_Set) return Boolean is
      Left_Data : constant not null Set_Data_Access :=
         Controlled_Sets.Reference (Left);
      pragma Check (Validate, Naked_Maps.Debug.Valid (Left_Data.all));
      Right_Data : constant not null Set_Data_Access :=
         Controlled_Sets.Reference (Right);
      pragma Check (Validate, Naked_Maps.Debug.Valid (Right_Data.all));
   begin
      return Left_Data = Right_Data or else Left_Data.Items = Right_Data.Items;
   end "=";

   function "not" (Right : Character_Set) return Character_Set is
      Right_Data : constant not null Set_Data_Access :=
         Controlled_Sets.Reference (Right);
      pragma Check (Validate, Naked_Maps.Debug.Valid (Right_Data.all));
      Data : Set_Data_Access;
   begin
      if Right_Data.Length = 0 then
         Data := Full_Set_Data'Unrestricted_Access;
      else
         declare
            Items : Naked_Maps.Character_Ranges (
               1 ..
               Full_Set_Data.Length + Right_Data.Length);
            Last : Natural;
         begin
            Sub (Items, Last, Full_Set_Data.Items, Right_Data.Items);
            Data := Copy_Set_Data (Items (Items'First .. Last));
            pragma Check (Validate, Naked_Maps.Debug.Valid (Data.all));
         end;
      end if;
      return Create (Data);
   end "not";

   function "and" (Left, Right : Character_Set)
      return Character_Set
   is
      Left_Data : constant not null Set_Data_Access :=
         Controlled_Sets.Reference (Left);
      pragma Check (Validate, Naked_Maps.Debug.Valid (Left_Data.all));
      Right_Data : constant not null Set_Data_Access :=
         Controlled_Sets.Reference (Right);
      pragma Check (Validate, Naked_Maps.Debug.Valid (Right_Data.all));
      Data : Set_Data_Access;
   begin
      if Left_Data.Length = 0 or else Right_Data.Length = 0 then
         Data := Empty_Set_Data'Unrestricted_Access;
      else
         declare
            Items : Naked_Maps.Character_Ranges (
               1 ..
               Left_Data.Length + Right_Data.Length);
            Last : Natural;
         begin
            Naked_Maps.Intersection (
               Items,
               Last,
               Left_Data.Items,
               Right_Data.Items);
            Data := Copy_Set_Data (Items (Items'First .. Last));
            pragma Check (Validate, Naked_Maps.Debug.Valid (Data.all));
         end;
      end if;
      return Create (Data);
   end "and";

   function "or" (Left, Right : Character_Set)
      return Character_Set
   is
      Left_Data : constant not null Set_Data_Access :=
         Controlled_Sets.Reference (Left);
      pragma Check (Validate, Naked_Maps.Debug.Valid (Left_Data.all));
      Right_Data : constant not null Set_Data_Access :=
         Controlled_Sets.Reference (Right);
      pragma Check (Validate, Naked_Maps.Debug.Valid (Right_Data.all));
      Data : Set_Data_Access;
   begin
      if Left_Data.Length = 0 then
         Data := Right_Data;
         declare
            X : aliased System.Reference_Counting.Container := Upcast (Data);
         begin
            System.Reference_Counting.Adjust (X'Access);
         end;
      elsif Right_Data.Length = 0 then
         Data := Left_Data;
         declare
            X : aliased System.Reference_Counting.Container := Upcast (Data);
         begin
            System.Reference_Counting.Adjust (X'Access);
         end;
      else
         declare
            Items : Naked_Maps.Character_Ranges (
               1 ..
               Left_Data.Length + Right_Data.Length);
            Last : Natural;
         begin
            Naked_Maps.Union (
               Items,
               Last,
               Left_Data.Items,
               Right_Data.Items);
            Data := Copy_Set_Data (Items (Items'First .. Last)); -- Length > 0
            pragma Check (Validate, Naked_Maps.Debug.Valid (Data.all));
         end;
      end if;
      return Create (Data);
   end "or";

   function "xor" (Left, Right : Character_Set)
      return Character_Set
   is
      Left_Data : constant not null Set_Data_Access :=
         Controlled_Sets.Reference (Left);
      pragma Check (Validate, Naked_Maps.Debug.Valid (Left_Data.all));
      Right_Data : constant not null Set_Data_Access :=
         Controlled_Sets.Reference (Right);
      pragma Check (Validate, Naked_Maps.Debug.Valid (Right_Data.all));
      Data : Set_Data_Access;
   begin
      if Left_Data.Length = 0 then
         Data := Right_Data;
         declare
            X : aliased System.Reference_Counting.Container := Upcast (Data);
         begin
            System.Reference_Counting.Adjust (X'Access);
         end;
      elsif Right_Data.Length = 0 then
         Data := Left_Data;
         declare
            X : aliased System.Reference_Counting.Container := Upcast (Data);
         begin
            System.Reference_Counting.Adjust (X'Access);
         end;
      else
         declare
            Max : constant Natural := Left_Data.Length + Right_Data.Length;
            X : Naked_Maps.Character_Ranges (1 .. Max);
            X_Last : Natural;
            Y : Naked_Maps.Character_Ranges (1 .. Max);
            Y_Last : Natural;
            Items : Naked_Maps.Character_Ranges (1 .. Max);
            Last : Natural;
         begin
            Naked_Maps.Union (
               X,
               X_Last,
               Left_Data.Items,
               Right_Data.Items);
            Naked_Maps.Intersection (
               Y,
               Y_Last,
               Left_Data.Items,
               Right_Data.Items);
            Sub (Items, Last, X (1 .. X_Last), Y (1 .. Y_Last));
            Data := Copy_Set_Data (Items (Items'First .. Last));
            pragma Check (Validate, Naked_Maps.Debug.Valid (Data.all));
         end;
      end if;
      return Create (Data);
   end "xor";

   function "-" (Left, Right : Character_Set)
      return Character_Set
   is
      Left_Data : constant not null Set_Data_Access :=
         Controlled_Sets.Reference (Left);
      pragma Check (Validate, Naked_Maps.Debug.Valid (Left_Data.all));
      Right_Data : constant not null Set_Data_Access :=
         Controlled_Sets.Reference (Right);
      pragma Check (Validate, Naked_Maps.Debug.Valid (Right_Data.all));
      Data : Set_Data_Access;
   begin
      if Left_Data.Length = 0 then
         Data := Empty_Set_Data'Unrestricted_Access;
      elsif Right_Data.Length = 0 then
         Data := Left_Data;
         declare
            X : aliased System.Reference_Counting.Container := Upcast (Data);
         begin
            System.Reference_Counting.Adjust (X'Access);
         end;
      else
         declare
            Items : Naked_Maps.Character_Ranges (
               1 ..
               Left_Data.Length + Right_Data.Length);
            Last : Natural;
         begin
            Sub (Items, Last, Left_Data.Items, Right_Data.Items);
            Data := Copy_Set_Data (Items (Items'First .. Last));
            pragma Check (Validate, Naked_Maps.Debug.Valid (Data.all));
         end;
      end if;
      return Create (Data);
   end "-";

   function Overloaded_Is_In (
      Element : Character;
      Set : Character_Set)
      return Boolean is
   begin
      return Overloaded_Is_In (
         Naked_Maps.To_Wide_Wide_Character (Element),
         Set);
   end Overloaded_Is_In;

   function Overloaded_Is_In (
      Element : Wide_Character;
      Set : Character_Set)
      return Boolean is
   begin
      return Overloaded_Is_In (
         Naked_Maps.To_Wide_Wide_Character (Element),
         Set);
   end Overloaded_Is_In;

   function Overloaded_Is_In (
      Element : Wide_Wide_Character;
      Set : Character_Set)
      return Boolean
   is
      Set_Data : constant not null Set_Data_Access :=
         Controlled_Sets.Reference (Set);
      pragma Check (Validate, Naked_Maps.Debug.Valid (Set_Data.all));
   begin
      return Naked_Maps.Is_In (Element, Set_Data.all);
   end Overloaded_Is_In;

   function Is_Subset (Elements : Character_Set; Set : Character_Set)
      return Boolean
   is
      Elements_Data : constant not null Set_Data_Access :=
         Controlled_Sets.Reference (Elements);
      pragma Check (Validate, Naked_Maps.Debug.Valid (Elements_Data.all));
      Set_Data : constant not null Set_Data_Access :=
         Controlled_Sets.Reference (Set);
      pragma Check (Validate, Naked_Maps.Debug.Valid (Set_Data.all));
   begin
      if Set_Data.Length = 0 then
         return False;
      else
         declare
            J : Positive := Set_Data.Items'First;
         begin
            for I in Elements_Data.Items'Range loop
               declare
                  E : Naked_Maps.Character_Range
                     renames Elements_Data.Items (I);
               begin
                  loop
                     if E.Low < Set_Data.Items (J).Low then
                        return False;
                     elsif E.High > Set_Data.Items (J).High then
                        J := J + 1;
                        if J > Set_Data.Items'Last then
                           return False;
                        end if;
                     else
                        exit; -- ok for E
                     end if;
                  end loop;
               end;
            end loop;
            return True;
         end;
      end if;
   end Is_Subset;

   function Overloaded_To_Set (Sequence : Character_Sequence)
      return Character_Set
   is
      --  Should it raise Constraint_Error for illegal sequence ?
      U_Sequence : Wide_Wide_Character_Sequence (
        1 .. System.UTF_Conversions.Expanding_From_8_To_32 * Sequence'Length);
      U_Sequence_Last : Natural;
   begin
      System.UTF_Conversions.From_8_To_32.Convert (
         Sequence,
         U_Sequence,
         U_Sequence_Last,
         Substitute => "");
      return Overloaded_To_Set (U_Sequence (1 .. U_Sequence_Last));
   end Overloaded_To_Set;

   function Overloaded_To_Set (Sequence : Wide_Character_Sequence)
      return Character_Set
   is
      --  Should it raise Constraint_Error for illegal sequence ?
      U_Sequence : Wide_Wide_Character_Sequence (
        1 .. System.UTF_Conversions.Expanding_From_16_To_32 * Sequence'Length);
      U_Sequence_Last : Natural;
   begin
      System.UTF_Conversions.From_16_To_32.Convert (
         Sequence,
         U_Sequence,
         U_Sequence_Last,
         Substitute => "");
      return Overloaded_To_Set (U_Sequence (1 .. U_Sequence_Last));
   end Overloaded_To_Set;

   function Overloaded_To_Set (Sequence : Wide_Wide_Character_Sequence)
      return Character_Set
   is
      Items : Naked_Maps.Character_Ranges (Sequence'Range);
      Last : Natural := Items'First - 1;
      Data : Set_Data_Access;
   begin
      --  it should be more optimized...
      for I in Sequence'Range loop
         declare
            E : Wide_Wide_Character renames Sequence (I);
         begin
            Naked_Maps.Add (Items, Last, E, E);
         end;
      end loop;
      Data := Copy_Set_Data (Items (Items'First .. Last));
      pragma Check (Validate, Naked_Maps.Debug.Valid (Data.all));
      return Create (Data);
   end Overloaded_To_Set;

   function Overloaded_To_Set (Singleton : Character)
      return Character_Set is
   begin
      return Overloaded_To_Set (Naked_Maps.To_Wide_Wide_Character (Singleton));
   end Overloaded_To_Set;

   function Overloaded_To_Set (Singleton : Wide_Character)
      return Character_Set is
   begin
      return Overloaded_To_Set (Naked_Maps.To_Wide_Wide_Character (Singleton));
   end Overloaded_To_Set;

   function Overloaded_To_Set (Singleton : Wide_Wide_Character)
      return Character_Set is
   begin
      return Create (
         new Set_Data'(
            Length => 1,
            Reference_Count => 1,
            Items => (1 => (Singleton, Singleton))));
   end Overloaded_To_Set;

   function Overloaded_To_Sequence (Set : Character_Set)
      return Character_Sequence is
   begin
      --  Should it raise Constraint_Error for illegal sequence ?
      return System.UTF_Conversions.From_32_To_8.Convert (
         Overloaded_To_Sequence (Set),
         Substitute => "");
   end Overloaded_To_Sequence;

   function Overloaded_To_Sequence (Set : Character_Set)
      return Wide_Character_Sequence is
   begin
      --  Should it raise Constraint_Error for illegal sequence or unmappable ?
      return System.UTF_Conversions.From_32_To_16.Convert (
         Overloaded_To_Sequence (Set),
         Substitute => "");
   end Overloaded_To_Sequence;

   function Overloaded_To_Sequence (Set : Character_Set)
      return Wide_Wide_Character_Sequence
   is
      Set_Data : constant not null Set_Data_Access :=
         Controlled_Sets.Reference (Set);
      pragma Check (Validate, Naked_Maps.Debug.Valid (Set_Data.all));
      Length : Natural := 0;
   begin
      for I in Set_Data.Items'Range loop
         Length := Length
            + (
               Wide_Wide_Character'Pos (Set_Data.Items (I).High)
               - Wide_Wide_Character'Pos (Set_Data.Items (I).Low)
               + 1);
      end loop;
      return Result : Wide_Wide_String (1 .. Length) do
         declare
            Last : Natural := 0;
         begin
            for I in Set_Data.Items'Range loop
               for J in Set_Data.Items (I).Low .. Set_Data.Items (I).High loop
                  Last := Last + 1;
                  Result (Last) := J;
               end loop;
            end loop;
         end;
      end return;
   end Overloaded_To_Sequence;

   package body Controlled_Sets is

      function Create (Data : not null Set_Data_Access)
         return Character_Set is
      begin
         return (Finalization.Controlled with Data => Data);
      end Create;

      function Reference (Object : Maps.Character_Set)
         return not null Set_Data_Access is
      begin
         return Character_Set (Object).Data;
      end Reference;

      overriding procedure Adjust (Object : in out Character_Set) is
      begin
         System.Reference_Counting.Adjust (
            Upcast (Object.Data'Unchecked_Access));
      end Adjust;

      overriding procedure Finalize (Object : in out Character_Set) is
      begin
         System.Reference_Counting.Clear (
            Upcast (Object.Data'Unchecked_Access),
            Free => Free_Set_Data'Access);
      end Finalize;

      package body Streaming is

         procedure Read (
            Stream : not null access Streams.Root_Stream_Type'Class;
            Item : out Character_Set)
         is
            Length : Integer;
         begin
            Integer'Read (Stream, Length);
            Finalize (Item);
            Item.Data := Empty_Set_Data'Unrestricted_Access;
            if Length > 0 then
               Item.Data := new Set_Data'(
                  Length => Length,
                  Reference_Count => 1,
                  Items => <>);
               Naked_Maps.Character_Ranges'Read (Stream, Item.Data.Items);
               pragma Check (Validate, Naked_Maps.Debug.Valid (Item.Data.all));
            end if;
         end Read;

         procedure Write (
            Stream : not null access Streams.Root_Stream_Type'Class;
            Item : Character_Set)
         is
            pragma Check (Validate, Naked_Maps.Debug.Valid (Item.Data.all));
            Data : constant not null Set_Data_Access := Item.Data;
         begin
            Integer'Write (Stream, Data.Length);
            Naked_Maps.Character_Ranges'Write (Stream, Data.Items);
         end Write;

      end Streaming;

   end Controlled_Sets;

   --  maps

   subtype Nonnull_Map_Data_Access is not null Map_Data_Access;

   function Downcast is
      new Unchecked_Conversion (
         System.Reference_Counting.Container,
         Nonnull_Map_Data_Access);

   type Map_Data_Access_Access is access all Nonnull_Map_Data_Access;

   function Upcast is
      new Unchecked_Conversion (Map_Data_Access_Access, Container_Access);

   procedure Free is new Unchecked_Deallocation (Map_Data, Map_Data_Access);

   procedure Free_Map_Data (
      Data : in out System.Reference_Counting.Data_Access);
   procedure Free_Map_Data (
      Data : in out System.Reference_Counting.Data_Access)
   is
      X : Map_Data_Access := Downcast (Data);
   begin
      Free (X);
      Data := null;
   end Free_Map_Data;

   --  implementation of maps

   function Overloaded_Value (
      Map : Character_Mapping;
      Element : Character)
      return Character is
   begin
      return Naked_Maps.To_Character (
         Overloaded_Value (Map, Naked_Maps.To_Wide_Wide_Character (Element)));
   end Overloaded_Value;

   function Overloaded_Value (
      Map : Character_Mapping;
      Element : Wide_Character)
      return Wide_Character is
   begin
      return Naked_Maps.To_Wide_Character (
         Overloaded_Value (Map, Naked_Maps.To_Wide_Wide_Character (Element)));
   end Overloaded_Value;

   function Overloaded_Value (
      Map : Character_Mapping;
      Element : Wide_Wide_Character)
      return Wide_Wide_Character
   is
      Map_Data : constant not null Map_Data_Access :=
         Controlled_Maps.Reference (Map);
      pragma Check (Validate, Naked_Maps.Debug.Valid (Map_Data.all));
   begin
      return Naked_Maps.Value (Map_Data.all, Element);
   end Overloaded_Value;

   function Identity return Character_Mapping is
   begin
      return Create (Empty_Map_Data'Unrestricted_Access);
   end Identity;

   function Is_Identity (Map : Character_Mapping) return Boolean is
      Map_Data : constant not null Map_Data_Access :=
         Controlled_Maps.Reference (Map);
      pragma Check (Validate, Naked_Maps.Debug.Valid (Map_Data.all));
   begin
      return Map_Data.Length = 0;
   end Is_Identity;

   function Overloaded_To_Mapping (From, To : Character_Sequence)
      return Character_Mapping
   is
      --  Should it raise Constraint_Error for illegal sequence ?
      U_From : Wide_Wide_Character_Sequence (
        1 .. System.UTF_Conversions.Expanding_From_8_To_32 * From'Length);
      U_From_Last : Natural;
      U_To : Wide_Wide_Character_Sequence (
        1 .. System.UTF_Conversions.Expanding_From_8_To_32 * To'Length);
      U_To_Last : Natural;
   begin
      System.UTF_Conversions.From_8_To_32.Convert (From, U_From, U_From_Last,
         Substitute => "");
      System.UTF_Conversions.From_8_To_32.Convert (To, U_To, U_To_Last,
         Substitute => "");
      return Overloaded_To_Mapping (
         From => U_From (1 .. U_From_Last),
         To => U_To (1 .. U_To_Last));
   end Overloaded_To_Mapping;

   function Overloaded_To_Mapping (From, To : Wide_Character_Sequence)
      return Character_Mapping
   is
      --  Should it raise Constraint_Error for illegal sequence ?
      U_From : Wide_Wide_Character_Sequence (
        1 .. System.UTF_Conversions.Expanding_From_16_To_32 * From'Length);
      U_From_Last : Natural;
      U_To : Wide_Wide_Character_Sequence (
        1 .. System.UTF_Conversions.Expanding_From_16_To_32 * To'Length);
      U_To_Last : Natural;
   begin
      System.UTF_Conversions.From_16_To_32.Convert (From, U_From, U_From_Last,
         Substitute => "");
      System.UTF_Conversions.From_16_To_32.Convert (To, U_To, U_To_Last,
         Substitute => "");
      return Overloaded_To_Mapping (
         From => U_From (1 .. U_From_Last),
         To => U_To (1 .. U_To_Last));
   end Overloaded_To_Mapping;

   function Overloaded_To_Mapping (From, To : Wide_Wide_Character_Sequence)
      return Character_Mapping
   is
      Sorted_From, Sorted_To : Wide_Wide_Character_Sequence (1 .. From'Length);
      Sorted_Last : Natural;
      New_Data : Map_Data_Access;
   begin
      Naked_Maps.To_Mapping (
         From => From,
         To => To,
         Out_From => Sorted_From,
         Out_To => Sorted_To,
         Out_Last => Sorted_Last);
      if Sorted_Last = 0 then
         New_Data := Empty_Map_Data'Unrestricted_Access;
      else
         New_Data := new Map_Data'(
            Length => Sorted_Last,
            Reference_Count => 1,
            From => Sorted_From (1 .. Sorted_Last),
            To => Sorted_To (1 .. Sorted_Last));
      end if;
      pragma Check (Validate, Naked_Maps.Debug.Valid (New_Data.all));
      return Create (New_Data);
   end Overloaded_To_Mapping;

   function Overloaded_To_Domain (Map : Character_Mapping)
      return Character_Sequence is
   begin
      --  Should it raise Constraint_Error for illegal sequence ?
      return System.UTF_Conversions.From_32_To_8.Convert (
         Overloaded_To_Domain (Map),
         Substitute => "");
   end Overloaded_To_Domain;

   function Overloaded_To_Domain (Map : Character_Mapping)
      return Wide_Character_Sequence is
   begin
      --  Should it raise Constraint_Error for illegal sequence or unmappable ?
      return System.UTF_Conversions.From_32_To_16.Convert (
         Overloaded_To_Domain (Map),
         Substitute => "");
   end Overloaded_To_Domain;

   function Overloaded_To_Domain (Map : Character_Mapping)
      return Wide_Wide_Character_Sequence
   is
      Map_Data : constant not null Map_Data_Access :=
         Controlled_Maps.Reference (Map);
      pragma Check (Validate, Naked_Maps.Debug.Valid (Map_Data.all));
   begin
      return Map_Data.From;
   end Overloaded_To_Domain;

   function Overloaded_To_Range (Map : Character_Mapping)
      return Character_Sequence is
   begin
      --  Should it raise Constraint_Error for illegal sequence ?
      return System.UTF_Conversions.From_32_To_8.Convert (
         Overloaded_To_Range (Map),
         Substitute => "");
   end Overloaded_To_Range;

   function Overloaded_To_Range (Map : Character_Mapping)
      return Wide_Character_Sequence is
   begin
      --  Should it raise Constraint_Error for illegal sequence or unmappable ?
      return System.UTF_Conversions.From_32_To_16.Convert (
         Overloaded_To_Range (Map),
         Substitute => "");
   end Overloaded_To_Range;

   function Overloaded_To_Range (Map : Character_Mapping)
      return Wide_Wide_Character_Sequence
   is
      Map_Data : constant not null Map_Data_Access :=
         Controlled_Maps.Reference (Map);
      pragma Check (Validate, Naked_Maps.Debug.Valid (Map_Data.all));
   begin
      return Map_Data.To;
   end Overloaded_To_Range;

   overriding function "=" (Left, Right : Character_Mapping) return Boolean is
      Left_Data : constant not null Map_Data_Access :=
         Controlled_Maps.Reference (Left);
      pragma Check (Validate, Naked_Maps.Debug.Valid (Left_Data.all));
      Right_Data : constant not null Map_Data_Access :=
         Controlled_Maps.Reference (Right);
      pragma Check (Validate, Naked_Maps.Debug.Valid (Right_Data.all));
   begin
      return Left_Data = Right_Data
         or else (
            Left_Data.From = Right_Data.From
            and then Left_Data.To = Right_Data.To);
   end "=";

   package body Controlled_Maps is

      function Create (Data : not null Map_Data_Access)
         return Character_Mapping is
      begin
         return (Finalization.Controlled with Data => Data);
      end Create;

      function Reference (Object : Maps.Character_Mapping)
         return not null Map_Data_Access is
      begin
         return Character_Mapping (Object).Data;
      end Reference;

      overriding procedure Adjust (Object : in out Character_Mapping) is
      begin
         System.Reference_Counting.Adjust (
            Upcast (Object.Data'Unchecked_Access));
      end Adjust;

      overriding procedure Finalize (Object : in out Character_Mapping) is
      begin
         System.Reference_Counting.Clear (
            Upcast (Object.Data'Unchecked_Access),
            Free => Free_Map_Data'Access);
      end Finalize;

      package body Streaming is

         --  compatibility with
         --    Ordered_Maps (Wide_Wide_Character, Wide_Wide_Character)
         --    and Hashed_Maps (Wide_Wide_Character, Wide_Wide_Character, ...)

         procedure Read (
            Stream : not null access Streams.Root_Stream_Type'Class;
            Item : out Character_Mapping)
         is
            Length : Integer;
         begin
            Integer'Read (Stream, Length);
            Finalize (Item);
            Item.Data := Empty_Map_Data'Unrestricted_Access;
            if Length > 0 then
               Item.Data := new Map_Data'(
                  Length => Length,
                  Reference_Count => 1,
                  From => <>,
                  To => <>);
               declare
                  Data : constant not null Map_Data_Access := Item.Data;
               begin
                  for I in 1 .. Length loop
                     Wide_Wide_Character'Read (Stream, Data.From (I));
                     Wide_Wide_Character'Read (Stream, Data.To (I));
                  end loop;
               end;
               pragma Check (Validate, Naked_Maps.Debug.Valid (Item.Data.all));
            end if;
         end Read;

         procedure Write (
            Stream : not null access Streams.Root_Stream_Type'Class;
            Item : Character_Mapping)
         is
            pragma Check (Validate, Naked_Maps.Debug.Valid (Item.Data.all));
            Data : constant not null Map_Data_Access := Item.Data;
         begin
            Integer'Write (Stream, Data.Length);
            for I in 1 .. Data.Length loop
               Wide_Wide_Character'Write (Stream, Data.From (I));
               Wide_Wide_Character'Write (Stream, Data.To (I));
            end loop;
         end Write;

      end Streaming;

   end Controlled_Maps;

end Ada.Strings.Maps;
