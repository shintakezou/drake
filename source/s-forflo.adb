with System.Long_Long_Float_Types;
package body System.Formatting.Float is
   pragma Suppress (All_Checks);

   subtype Word_Unsigned is Long_Long_Integer_Types.Word_Unsigned;

   function roundl (X : Long_Long_Float) return Long_Long_Float
      with Import,
         Convention => Intrinsic, External_Name => "__builtin_roundl";
   function truncl (X : Long_Long_Float) return Long_Long_Float
      with Import,
         Convention => Intrinsic, External_Name => "__builtin_truncl";

   function isnanl (X : Long_Long_Float) return Integer
      with Import,
         Convention => Intrinsic, External_Name => "__builtin_isnanl";
   function isinfl (X : Long_Long_Float) return Integer
      with Import,
         Convention => Intrinsic, External_Name => "__builtin_isinfl";

   function signbitl (X : Long_Long_Float) return Integer
      with Import,
         Convention => Intrinsic, External_Name => "__builtin_signbitl";

   procedure Split (
      X : Long_Long_Unsigned_Float;
      Fore : out Digit; -- Fore < Base
      Aft : out Long_Long_Unsigned_Float;
      Exponent : out Integer;
      Base : Number_Base := 10);
   procedure Split (
      X : Long_Long_Unsigned_Float;
      Fore : out Digit;
      Aft : out Long_Long_Unsigned_Float;
      Exponent : out Integer;
      Base : Number_Base := 10) is
   begin
      if X > 0.0 then
         if X >= Long_Long_Unsigned_Float (Base) then
            declare
               B : Long_Long_Unsigned_Float := Long_Long_Unsigned_Float (Base);
            begin
               Exponent := 1;
               loop
                  declare
                     Next_B : constant Long_Long_Unsigned_Float :=
                        B * Long_Long_Unsigned_Float (Base);
                  begin
                     exit when Next_B > X;
                     B := Next_B;
                  end;
                  Exponent := Exponent + 1;
               end loop;
               declare
                  Scaled : constant Long_Long_Unsigned_Float := X / B;
                  Fore_Float : constant Long_Long_Unsigned_Float :=
                     truncl (Scaled);
               begin
                  Fore := Digit (Fore_Float);
                  Aft := X - Fore_Float * B;
               end;
            end;
         else
            declare
               Scaled : Long_Long_Unsigned_Float := X;
               B : Long_Long_Unsigned_Float := 1.0;
            begin
               Exponent := 0;
               while Scaled < 1.0 loop
                  Scaled := Scaled * Long_Long_Unsigned_Float (Base);
                  B := B * Long_Long_Unsigned_Float (Base);
                  Exponent := Exponent - 1;
               end loop;
               declare
                  Fore_Float : constant Long_Long_Unsigned_Float :=
                     truncl (Scaled);
               begin
                  Fore := Digit (Fore_Float);
                  Aft := X - Fore_Float / B;
               end;
            end;
         end if;
      else
         Fore := 0;
         Aft := 0.0;
         Exponent := 0;
      end if;
   end Split;

   --  implementation

   procedure Aft_Scale (
      Aft : Long_Long_Unsigned_Float;
      Scaled_Aft : out Long_Long_Unsigned_Float;
      Exponent : Integer;
      Round_Up : out Boolean;
      Base : Number_Base := 10;
      Width : Positive := Standard.Float'Digits - 1)
   is
      L : constant Long_Long_Unsigned_Float :=
         Long_Long_Unsigned_Float (Base) ** Width;
   begin
      Scaled_Aft := roundl (
         Aft * Long_Long_Unsigned_Float (Base) ** (Width - Exponent));
      Round_Up := Scaled_Aft >= L; -- ".99"99.. would be rounded up to 1".00"
   end Aft_Scale;

   procedure Aft_Image (
      Value : Long_Long_Unsigned_Float;
      Item : out String;
      Last : out Natural;
      Base : Number_Base := 10;
      Set : Type_Set := Upper_Case;
      Width : Positive := Standard.Float'Digits - 1)
   is
      X : Long_Long_Unsigned_Float := Value;
   begin
      Last := Item'First + Width;
      Item (Item'First) := '.';
      for I in reverse Item'First + 1 .. Last loop
         declare
            Q : Long_Long_Float;
            R : Long_Long_Float;
         begin
            Long_Long_Float_Types.Divide (X, Long_Long_Float (Base), Q, R);
            Image (Digit (R), Item (I), Set => Set);
            X := Q;
         end;
      end loop;
      pragma Assert (X = 0.0);
   end Aft_Image;

   function Fore_Width (
      Value : Long_Long_Unsigned_Float;
      Base : Number_Base := 10)
      return Positive
   is
      P : Long_Long_Float := Long_Long_Float (Base);
      Result : Positive := 1;
   begin
      while P <= Value loop -- Value is finite, so exit when isinfl (P)
         Result := Result + 1;
         P := P * Long_Long_Float (Base);
      end loop;
      return Result;
   end Fore_Width;

   function Fore_Width (
      First, Last : Long_Long_Float;
      Base : Number_Base := 10)
      return Positive
   is
      Actual_First : Long_Long_Float := First;
      Actual_Last : Long_Long_Float := Last;
      Max_Abs : Long_Long_Float;
   begin
      if First > Last then
         Actual_First := Last;
         Actual_Last := First;
      end if;
      if Actual_Last <= 0.0 then
         Max_Abs := -Actual_First;
      elsif Actual_First >= 0.0 then
         Max_Abs := Actual_Last;
      else -- Actual_First < 0 and then Actual_Last > 0
         Max_Abs := Long_Long_Float'Max (-Actual_First, Actual_Last);
      end if;
      return Fore_Width (Max_Abs, Base => Base);
   end Fore_Width;

   procedure Image (
      Value : Long_Long_Float;
      Item : out String;
      Last : out Natural;
      Minus_Sign : Character := '-';
      Zero_Sign : Character := ' ';
      Plus_Sign : Character := ' ';
      Base : Number_Base := 10;
      Base_Form : Boolean := False;
      Set : Type_Set := Upper_Case;
      Fore_Width : Positive := 1;
      Fore_Padding : Character := '0';
      Aft_Width : Positive;
      Exponent_Mark : Character := 'E';
      Exponent_Minus_Sign : Character := '-';
      Exponent_Zero_Sign : Character := '+';
      Exponent_Plus_Sign : Character := '+';
      Exponent_Width : Positive := 2;
      Exponent_Padding : Character := '0';
      NaN : String := "NAN";
      Infinity : String := "INF") is
   begin
      Last := Item'First - 1;
      if signbitl (Value) /= 0 then
         if Minus_Sign /= No_Sign then
            Last := Last + 1;
            pragma Assert (Last <= Item'Last);
            Item (Last) := Minus_Sign;
         end if;
      elsif Value > 0.0 then
         if Plus_Sign /= No_Sign then
            Last := Last + 1;
            pragma Assert (Last <= Item'Last);
            Item (Last) := Plus_Sign;
         end if;
      else
         if Zero_Sign /= No_Sign then
            Last := Last + 1;
            pragma Assert (Last <= Item'Last);
            Item (Last) := Zero_Sign;
         end if;
      end if;
      if isnanl (Value) /= 0 then
         declare
            First : constant Positive := Last + 1;
         begin
            Last := Last + NaN'Length;
            pragma Assert (Last <= Item'Last);
            Item (First .. Last) := NaN;
         end;
      elsif isinfl (Value) /= 0 then
         declare
            First : constant Positive := Last + 1;
         begin
            Last := Last + Infinity'Length;
            pragma Assert (Last <= Item'Last);
            Item (First .. Last) := Infinity;
         end;
      else
         declare
            Fore : Digit;
            Aft : Long_Long_Float;
            Exponent : Integer;
            Scaled_Aft : Long_Long_Float;
            Rouned_Up : Boolean;
            Error : Boolean;
         begin
            Split (
               abs Value,
               Fore,
               Aft,
               Exponent,
               Base => Base);
            Aft_Scale (
               Aft,
               Scaled_Aft,
               Exponent,
               Rouned_Up,
               Base => Base,
               Width => Aft_Width);
            if Rouned_Up then
               Fore := Fore + 1;
               Scaled_Aft := 0.0;
               if Fore >= Base then
                  Fore := 1;
                  Exponent := Exponent + 1;
               end if;
            end if;
            --  opening '#'
            if Base_Form then
               Image (
                  Word_Unsigned (Base),
                  Item (Last + 1 .. Item'Last),
                  Last,
                  Error => Error);
               pragma Assert (not Error);
               Last := Last + 1;
               pragma Assert (Last <= Item'Last);
               Item (Last) := '#';
            end if;
            --  integer part
            pragma Assert (Last + Fore_Width <= Item'Last);
            Fill_Padding (
               Item (Last + 1 .. Last + Fore_Width - 1),
               Fore_Padding);
            Last := Last + Fore_Width; -- including one digit
            Image (Fore, Item (Last), Set => Set);
            --  '.' and decimal part
            pragma Assert (Last + 1 + Aft_Width <= Item'Last);
            Aft_Image (
               Scaled_Aft,
               Item (Last + 1 .. Item'Last),
               Last,
               Base => Base,
               Width => Aft_Width);
            --  closing #
            if Base_Form then
               Last := Last + 1;
               pragma Assert (Last <= Item'Last);
               Item (Last) := '#';
            end if;
            --  exponent
            Last := Last + 1;
            pragma Assert (Last <= Item'Last);
            Item (Last) := Exponent_Mark;
            if Exponent < 0 then
               if Exponent_Minus_Sign /= No_Sign then
                  Last := Last + 1;
                  pragma Assert (Last <= Item'Last);
                  Item (Last) := Exponent_Minus_Sign;
               end if;
            elsif Exponent > 0 then
               if Exponent_Plus_Sign /= No_Sign then
                  Last := Last + 1;
                  pragma Assert (Last <= Item'Last);
                  Item (Last) := Exponent_Plus_Sign;
               end if;
            else
               if Exponent_Zero_Sign /= No_Sign then
                  Last := Last + 1;
                  pragma Assert (Last <= Item'Last);
                  Item (Last) := Exponent_Zero_Sign;
               end if;
            end if;
            Image (
               Word_Unsigned (abs Exponent),
               Item (Last + 1 .. Item'Last),
               Last,
               Width => Exponent_Width,
               Padding => Exponent_Padding,
               Error => Error);
            pragma Assert (not Error);
         end;
      end if;
   end Image;

end System.Formatting.Float;
