pragma Check_Policy (Validate => Disable);
--  with Ada.Strings.Naked_Maps.Debug;
with Ada.UCD.Case_Folding;
with System.Once;
with System.Reference_Counting;
package body Ada.Strings.Naked_Maps.Case_Folding is
   use type UCD.Difference_Base;
   use type UCD.UCS_4;

   procedure Decode (
      Mapping : in out Character_Mapping_Data;
      I : in out Positive;
      Table : UCD.Map_16x1_Type);
   procedure Decode (
      Mapping : in out Character_Mapping_Data;
      I : in out Positive;
      Table : UCD.Map_16x1_Type) is
   begin
      for J in Table'Range loop
         declare
            F : UCD.Map_16x1_Item_Type renames Table (J);
         begin
            Mapping.From (I) := Character_Type'Val (F.Code);
            Mapping.To (I) := Character_Type'Val (F.Mapping);
         end;
         I := I + 1;
      end loop;
   end Decode;

   procedure Decode (
      Mapping : in out Character_Mapping_Data;
      I : in out Positive;
      Table : UCD.Case_Folding.Compressed_Type;
      Offset : UCD.Difference_Base);
   procedure Decode (
      Mapping : in out Character_Mapping_Data;
      I : in out Positive;
      Table : UCD.Case_Folding.Compressed_Type;
      Offset : UCD.Difference_Base) is
   begin
      for J in Table'Range loop
         declare
            F : UCD.Case_Folding.Compressed_Item_Type renames Table (J);
            From : Character_Type :=
               Character_Type'Val (UCD.Difference_Base (F.Start) + Offset);
            To : Character_Type :=
               Character_Type'Val (Character_Type'Pos (From) + F.Diff);
         begin
            for K in 1 .. F.Length loop
               Mapping.From (I) := From;
               Mapping.To (I) := To;
               From := Character_Type'Succ (From);
               To := Character_Type'Succ (To);
               I := I + 1;
            end loop;
         end;
      end loop;
   end Decode;

   type Character_Mapping_Access_With_Pool is access Character_Mapping_Data;

   Mapping : Character_Mapping_Access_With_Pool;
   Mapping_Flag : aliased System.Once.Flag := 0;

   procedure Mapping_Init;
   procedure Mapping_Init is
   begin
      Mapping := new Character_Mapping_Data'(
         Length => UCD.Case_Folding.C_Total + UCD.Case_Folding.S_Total,
         Reference_Count => System.Reference_Counting.Static,
         From => <>,
         To => <>);
      declare
         I : Positive := Mapping.From'First;
      begin
         --  16#0041# ..
         Decode (
            Mapping.all,
            I,
            UCD.Case_Folding.C_Table_XXXXx1_Compressed,
            Offset => 0);
         --  16#00B5# ..
         Decode (
            Mapping.all,
            I,
            UCD.Case_Folding.C_Table_XXXXx1);
         --  16#1E9E# ..
         Decode (
            Mapping.all,
            I,
            UCD.Case_Folding.S_Table_XXXXx1);
         --  16#1F88# ..
         Decode (
            Mapping.all,
            I,
            UCD.Case_Folding.S_Table_XXXXx1_Compressed,
            Offset => 0);
         --  16#10400# ..
         Decode (
            Mapping.all,
            I,
            UCD.Case_Folding.C_Table_1XXXXx1_Compressed,
            Offset => 16#10000#);
         pragma Assert (I = Mapping.From'Last + 1);
      end;
      Sort (Mapping.From, Mapping.To);
      pragma Check (Validate, Debug.Valid (Mapping.all));
   end Mapping_Init;

   --  implementation

   function Case_Folding_Map return not null Character_Mapping_Access is
   begin
      System.Once.Initialize (Mapping_Flag'Access, Mapping_Init'Access);
      return Character_Mapping_Access (Mapping);
   end Case_Folding_Map;

end Ada.Strings.Naked_Maps.Case_Folding;
