with Ada.Numerics;
with System.Long_Long_Elementary_Functions;
package body System.Long_Long_Complex_Elementary_Functions is

   --  libgcc
   function mulxc3 (Left_Re, Left_Im, Right_Re, Right_Im : Long_Long_Float)
      return Long_Long_Complex
      with Import, Convention => C, External_Name => "__mulxc3";
   function divxc3 (Left_Re, Left_Im, Right_Re, Right_Im : Long_Long_Float)
      return Long_Long_Complex
      with Import, Convention => C, External_Name => "__divxc3";

   pragma Pure_Function (mulxc3);
   pragma Pure_Function (divxc3);

   function "-" (Left : Long_Long_Float; Right : Long_Long_Complex)
      return Long_Long_Complex
      with Convention => Intrinsic;
   function "*" (Left : Long_Long_Float; Right : Long_Long_Complex)
      return Long_Long_Complex
      with Convention => Intrinsic;
   function "*" (Left, Right : Long_Long_Complex) return Long_Long_Complex
      with Convention => Intrinsic;
   function "/" (Left, Right : Long_Long_Complex) return Long_Long_Complex
      with Convention => Intrinsic;

   pragma Inline_Always ("-");
   pragma Inline_Always ("*");
   pragma Inline_Always ("/");

   function "-" (Left : Long_Long_Float; Right : Long_Long_Complex)
      return Long_Long_Complex is
   begin
      return (Re => Left - Right.Re, Im => -Right.Im);
   end "-";

   function "*" (Left : Long_Long_Float; Right : Long_Long_Complex)
      return Long_Long_Complex is
   begin
      return (Re => Left * Right.Re, Im => Left * Right.Im);
   end "*";

   function "*" (Left, Right : Long_Long_Complex) return Long_Long_Complex is
   begin
      return mulxc3 (Left.Re, Left.Im, Right.Re, Right.Im);
   end "*";

   function "/" (Left, Right : Long_Long_Complex) return Long_Long_Complex is
   begin
      return divxc3 (Left.Re, Left.Im, Right.Re, Right.Im);
   end "/";

   --  Complex

   function To_Complex (X : Long_Long_Complex) return Complex;
   function To_Complex (X : Long_Long_Complex) return Complex is
   begin
      return (Re => Float (X.Re), Im => Float (X.Im));
   end To_Complex;

   function To_Long_Long_Complex (X : Complex) return Long_Long_Complex;
   function To_Long_Long_Complex (X : Complex) return Long_Long_Complex is
   begin
      return (Re => Long_Long_Float (X.Re), Im => Long_Long_Float (X.Im));
   end To_Long_Long_Complex;

   function Fast_Log (X : Complex) return Complex is
   begin
      return To_Complex (Fast_Log (To_Long_Long_Complex (X)));
   end Fast_Log;

   function Fast_Exp (X : Complex) return Complex is
   begin
      return To_Complex (Fast_Exp (To_Long_Long_Complex (X)));
   end Fast_Exp;

   function Fast_Exp (X : Imaginary) return Complex is
   begin
      return To_Complex (Fast_Exp (Long_Long_Imaginary (X)));
   end Fast_Exp;

   function Fast_Pow (Left, Right : Complex) return Complex is
   begin
      return To_Complex (
         Fast_Pow (To_Long_Long_Complex (Left), To_Long_Long_Complex (Right)));
   end Fast_Pow;

   function Fast_Sin (X : Complex) return Complex is
   begin
      return To_Complex (Fast_Sin (To_Long_Long_Complex (X)));
   end Fast_Sin;

   function Fast_Cos (X : Complex) return Complex is
   begin
      return To_Complex (Fast_Cos (To_Long_Long_Complex (X)));
   end Fast_Cos;

   function Fast_Tan (X : Complex) return Complex is
   begin
      return To_Complex (Fast_Tan (To_Long_Long_Complex (X)));
   end Fast_Tan;

   function Fast_Arcsin (X : Complex) return Complex is
   begin
      return To_Complex (Fast_Arcsin (To_Long_Long_Complex (X)));
   end Fast_Arcsin;

   function Fast_Arccos (X : Complex) return Complex is
   begin
      return To_Complex (Fast_Arccos (To_Long_Long_Complex (X)));
   end Fast_Arccos;

   function Fast_Arctan (X : Complex) return Complex is
   begin
      return To_Complex (Fast_Arctan (To_Long_Long_Complex (X)));
   end Fast_Arctan;

   function Fast_Sinh (X : Complex) return Complex is
   begin
      return To_Complex (Fast_Sinh (To_Long_Long_Complex (X)));
   end Fast_Sinh;

   function Fast_Cosh (X : Complex) return Complex is
   begin
      return To_Complex (Fast_Cosh (To_Long_Long_Complex (X)));
   end Fast_Cosh;

   function Fast_Tanh (X : Complex) return Complex is
   begin
      return To_Complex (Fast_Tanh (To_Long_Long_Complex (X)));
   end Fast_Tanh;

   function Fast_Arcsinh (X : Complex) return Complex is
   begin
      return To_Complex (Fast_Arcsinh (To_Long_Long_Complex (X)));
   end Fast_Arcsinh;

   function Fast_Arccosh (X : Complex) return Complex is
   begin
      return To_Complex (Fast_Arccosh (To_Long_Long_Complex (X)));
   end Fast_Arccosh;

   function Fast_Arctanh (X : Complex) return Complex is
   begin
      return To_Complex (Fast_Arctanh (To_Long_Long_Complex (X)));
   end Fast_Arctanh;

   --  Long_Complex

   function To_Long_Complex (X : Long_Long_Complex) return Long_Complex;
   function To_Long_Complex (X : Long_Long_Complex) return Long_Complex is
   begin
      return (Re => Long_Float (X.Re), Im => Long_Float (X.Im));
   end To_Long_Complex;

   function To_Long_Long_Complex (X : Long_Complex) return Long_Long_Complex;
   function To_Long_Long_Complex (X : Long_Complex) return Long_Long_Complex is
   begin
      return (Re => Long_Long_Float (X.Re), Im => Long_Long_Float (X.Im));
   end To_Long_Long_Complex;

   function Fast_Log (X : Long_Complex) return Long_Complex is
   begin
      return To_Long_Complex (Fast_Log (To_Long_Long_Complex (X)));
   end Fast_Log;

   function Fast_Exp (X : Long_Complex) return Long_Complex is
   begin
      return To_Long_Complex (Fast_Exp (To_Long_Long_Complex (X)));
   end Fast_Exp;

   function Fast_Exp (X : Long_Imaginary) return Long_Complex is
   begin
      return To_Long_Complex (Fast_Exp (Long_Long_Imaginary (X)));
   end Fast_Exp;

   function Fast_Pow (Left, Right : Long_Complex) return Long_Complex is
   begin
      return To_Long_Complex (
         Fast_Pow (To_Long_Long_Complex (Left), To_Long_Long_Complex (Right)));
   end Fast_Pow;

   function Fast_Sin (X : Long_Complex) return Long_Complex is
   begin
      return To_Long_Complex (Fast_Sin (To_Long_Long_Complex (X)));
   end Fast_Sin;

   function Fast_Cos (X : Long_Complex) return Long_Complex is
   begin
      return To_Long_Complex (Fast_Cos (To_Long_Long_Complex (X)));
   end Fast_Cos;

   function Fast_Tan (X : Long_Complex) return Long_Complex is
   begin
      return To_Long_Complex (Fast_Tan (To_Long_Long_Complex (X)));
   end Fast_Tan;

   function Fast_Arcsin (X : Long_Complex) return Long_Complex is
   begin
      return To_Long_Complex (Fast_Arcsin (To_Long_Long_Complex (X)));
   end Fast_Arcsin;

   function Fast_Arccos (X : Long_Complex) return Long_Complex is
   begin
      return To_Long_Complex (Fast_Arccos (To_Long_Long_Complex (X)));
   end Fast_Arccos;

   function Fast_Arctan (X : Long_Complex) return Long_Complex is
   begin
      return To_Long_Complex (Fast_Arctan (To_Long_Long_Complex (X)));
   end Fast_Arctan;

   function Fast_Sinh (X : Long_Complex) return Long_Complex is
   begin
      return To_Long_Complex (Fast_Sinh (To_Long_Long_Complex (X)));
   end Fast_Sinh;

   function Fast_Cosh (X : Long_Complex) return Long_Complex is
   begin
      return To_Long_Complex (Fast_Cosh (To_Long_Long_Complex (X)));
   end Fast_Cosh;

   function Fast_Tanh (X : Long_Complex) return Long_Complex is
   begin
      return To_Long_Complex (Fast_Tanh (To_Long_Long_Complex (X)));
   end Fast_Tanh;

   function Fast_Arcsinh (X : Long_Complex) return Long_Complex is
   begin
      return To_Long_Complex (Fast_Arcsinh (To_Long_Long_Complex (X)));
   end Fast_Arcsinh;

   function Fast_Arccosh (X : Long_Complex) return Long_Complex is
   begin
      return To_Long_Complex (Fast_Arccosh (To_Long_Long_Complex (X)));
   end Fast_Arccosh;

   function Fast_Arctanh (X : Long_Complex) return Long_Complex is
   begin
      return To_Long_Complex (Fast_Arctanh (To_Long_Long_Complex (X)));
   end Fast_Arctanh;

   --  Long_Long_Complex

   Pi : constant := Ada.Numerics.Pi;
   Pi_Div_2 : constant := Pi / 2.0;

   Sqrt_2 : constant := 1.4142135623730950488016887242096980785696;
   Log_2 : constant := 0.6931471805599453094172321214581765680755;

   Square_Root_Epsilon : constant Long_Long_Float :=
      Sqrt_2 ** (1 - Long_Long_Float'Model_Mantissa);
   Inv_Square_Root_Epsilon : constant Long_Long_Float :=
      Sqrt_2 ** (Long_Long_Float'Model_Mantissa - 1);
   Root_Root_Epsilon : constant Long_Long_Float :=
      Sqrt_2 ** ((1 - Long_Long_Float'Model_Mantissa) / 2);
   Log_Inverse_Epsilon_2 : constant Long_Long_Float :=
      Long_Long_Float (Long_Long_Float'Model_Mantissa - 1) / 2.0;

   function Fast_Log (X : Long_Long_Complex) return Long_Long_Complex is
   begin
      if abs (1.0 - X.Re) < Root_Root_Epsilon
         and then abs X.Im < Root_Root_Epsilon
      then
         declare
            Z : constant Long_Long_Complex := (Re => X.Re - 1.0, Im => X.Im);
               --  X - 1.0
            Result : constant Long_Long_Complex :=
               (1.0 - (1.0 / 2.0 - (1.0 / 3.0 - (1.0 / 4.0) * Z) * Z) * Z) * Z;
         begin
            return Result;
         end;
      else
         declare
            Result_Re : constant Long_Long_Float :=
               Long_Long_Elementary_Functions.Fast_Log (
                  Long_Long_Complex_Types.Fast_Modulus (X));
            Result_Im : constant Long_Long_Float :=
               Long_Long_Elementary_Functions.Fast_Arctan (X.Im, X.Re);
         begin
            if Result_Im > Pi then
               return (Re => Result_Re, Im => Result_Im - 2.0 * Pi);
            else
               return (Re => Result_Re, Im => Result_Im);
            end if;
         end;
      end if;
   end Fast_Log;

   function Fast_Exp (X : Long_Long_Complex) return Long_Long_Complex is
      Y : constant Long_Long_Float :=
         Long_Long_Elementary_Functions.Fast_Exp (X.Re);
   begin
      return (
         Re => Y * Long_Long_Elementary_Functions.Fast_Cos (X.Im),
         Im => Y * Long_Long_Elementary_Functions.Fast_Sin (X.Im));
   end Fast_Exp;

   function Fast_Exp (X : Long_Long_Imaginary) return Long_Long_Complex is
   begin
      return (
         Re => Long_Long_Elementary_Functions.Fast_Cos (Long_Long_Float (X)),
         Im => Long_Long_Elementary_Functions.Fast_Sin (Long_Long_Float (X)));
   end Fast_Exp;

   function Fast_Pow (Left, Right : Long_Long_Complex)
      return Long_Long_Complex is
   begin
      if (Left.Re = 0.0 or else Left.Re = 1.0) and then Left.Im = 0.0 then
         return Left;
      else
         return Fast_Exp (Right * Fast_Log (Left));
      end if;
   end Fast_Pow;

   function Fast_Sin (X : Long_Long_Complex) return Long_Long_Complex is
   begin
      if abs X.Re < Square_Root_Epsilon
         and then abs X.Im < Square_Root_Epsilon
      then
         return X;
      else
         return (
            Re =>
               Long_Long_Elementary_Functions.Fast_Sin (X.Re)
               * Long_Long_Elementary_Functions.Fast_Cosh (X.Im),
            Im =>
               Long_Long_Elementary_Functions.Fast_Cos (X.Re)
               * Long_Long_Elementary_Functions.Fast_Sinh (X.Im));
      end if;
   end Fast_Sin;

   function Fast_Cos (X : Long_Long_Complex) return Long_Long_Complex is
   begin
      return (
         Re =>
            Long_Long_Elementary_Functions.Fast_Cos (X.Re)
            * Long_Long_Elementary_Functions.Fast_Cosh (X.Im),
         Im =>
            -(Long_Long_Elementary_Functions.Fast_Sin (X.Re)
            * Long_Long_Elementary_Functions.Fast_Sinh (X.Im)));
   end Fast_Cos;

   function Fast_Tan (X : Long_Long_Complex) return Long_Long_Complex is
   begin
      if abs X.Re < Square_Root_Epsilon
         and then abs X.Im < Square_Root_Epsilon
      then
         return X;
      elsif X.Im > Log_Inverse_Epsilon_2 then
         return (Re => 0.0, Im => 1.0);
      elsif X.Im < -Log_Inverse_Epsilon_2 then
         return (Re => 0.0, Im => -1.0);
      else
         return Fast_Sin (X) / Fast_Cos (X);
      end if;
   end Fast_Tan;

   function Fast_Arcsin (X : Long_Long_Complex) return Long_Long_Complex is
   begin
      if abs X.Re < Square_Root_Epsilon
         and then abs X.Im < Square_Root_Epsilon
      then
         return X;
      elsif abs X.Re > Inv_Square_Root_Epsilon
         or else abs X.Im > Inv_Square_Root_Epsilon
      then
         declare
            iX : constant Long_Long_Complex := (Re => -X.Im, Im => X.Re);
            Log_2i : constant Long_Long_Complex :=
               Fast_Log ((Re => 0.0, Im => 2.0));
            A : constant Long_Long_Complex :=
               (Re => iX.Re + Log_2i.Re, Im => iX.Im + Log_2i.Im);
               --  iX + Log_2i
            Result : constant Long_Long_Complex := (Re => A.Im, Im => -A.Re);
               --  -i * A
         begin
            if Result.Im > Pi_Div_2 then
               return (Re => Result.Re, Im => Pi - X.Im);
            elsif Result.Im < -Pi_Div_2 then
               return (Re => Result.Re, Im => -(Pi + X.Im));
            else
               return Result;
            end if;
         end;
      else
         declare
            iX : constant Long_Long_Complex := (Re => -X.Im, Im => X.Re);
            X_X : constant Long_Long_Complex := X * X;
            A : constant Long_Long_Complex :=
               (Re => 1.0 - X_X.Re, Im => -X_X.Im);
               --  1.0 - X_X
            Sqrt_A : constant Long_Long_Complex := Fast_Sqrt (A);
            B : constant Long_Long_Complex :=
               (Re => iX.Re + Sqrt_A.Re, Im => iX.Im + Sqrt_A.Im);
               --  iX + Sqrt_A
            Log_B : constant Long_Long_Complex := Fast_Log (B);
            Result : constant Long_Long_Complex :=
               (Re => Log_B.Im, Im => -Log_B.Re);
               --  -i * Log_B
         begin
            if X.Re = 0.0 then
               return (Re => X.Re, Im => Result.Im);
            elsif X.Im = 0.0 and then abs X.Re <= 1.00 then
               return (Re => Result.Re, Im => X.Im);
            else
               return Result;
            end if;
         end;
      end if;
   end Fast_Arcsin;

   function Fast_Arccos (X : Long_Long_Complex) return Long_Long_Complex is
   begin
      if X.Re = 1.0 and then X.Im = 0.0 then
         return (Re => 0.0, Im => 0.0);
      elsif abs X.Re < Square_Root_Epsilon
         and then abs X.Im < Square_Root_Epsilon
      then
         return (Re => Pi_Div_2 - X.Re, Im => -X.Im);
      elsif abs X.Re > Inv_Square_Root_Epsilon
         or else abs X.Im > Inv_Square_Root_Epsilon
      then
         declare
            A : constant Long_Long_Complex := (Re => 1.0 - X.Re, Im => -X.Im);
               --  1.0 - X
            B : constant Long_Long_Complex :=
               (Re => A.Re / 2.0, Im => A.Im / 2.0);
               --  A / 2.0
            Sqrt_B : constant Long_Long_Complex := Fast_Sqrt (B);
            i_Sqrt_B : constant Long_Long_Complex :=
               (Re => -Sqrt_B.Im, Im => Sqrt_B.Re);
            C : constant Long_Long_Complex := (Re => 1.0 + X.Re, Im => X.Im);
               --  1.0 + X
            D : constant Long_Long_Complex :=
               (Re => C.Re / 2.0, Im => C.Im / 2.0);
               --  C / 2.0
            Sqrt_D : constant Long_Long_Complex := Fast_Sqrt (D);
            E : constant Long_Long_Complex :=
               (Re => Sqrt_D.Re + i_Sqrt_B.Re, Im => Sqrt_D.Im + i_Sqrt_B.Im);
               --  Sqrt_D + i_Sqrt_B
            Log_E : constant Long_Long_Complex := Fast_Log (E);
            Result : constant Long_Long_Complex :=
               (Re => 2.0 * Log_E.Im, Im => -2.0 * Log_E.Re);
               --  -2.0 * i * Log_E
         begin
            return Result;
         end;
      else
         declare
            X_X : constant Long_Long_Complex := X * X;
            A : constant Long_Long_Complex :=
               (Re => 1.0 - X_X.Re, Im => -X_X.Im);
               --  1.0 - X_X
            Sqrt_A : constant Long_Long_Complex := Fast_Sqrt (A);
            i_Sqrt_A : constant Long_Long_Complex :=
               (Re => -Sqrt_A.Im, Im => Sqrt_A.Re);
            B : constant Long_Long_Complex :=
               (Re => X.Re + i_Sqrt_A.Re, Im => X.Im + i_Sqrt_A.Im);
               --  X + i_Sqrt_A
            Log_B : constant Long_Long_Complex := Fast_Log (B);
            Result : constant Long_Long_Complex :=
               (Re => Log_B.Im, Im => -Log_B.Re);
               --  -i * Log_B
         begin
            if X.Im = 0.0 and then abs X.Re <= 1.00 then
               return (Re => Result.Re, Im => X.Im);
            else
               return Result;
            end if;
         end;
      end if;
   end Fast_Arccos;

   function Fast_Arctan (X : Long_Long_Complex) return Long_Long_Complex is
   begin
      if abs X.Re < Square_Root_Epsilon
         and then abs X.Im < Square_Root_Epsilon
      then
         return X;
      else
         declare
            iX : constant Long_Long_Complex := (Re => -X.Im, Im => X.Re);
            A : constant Long_Long_Complex := (Re => 1.0 + iX.Re, Im => iX.Im);
               --  1.0 + iX
            Log_A : constant Long_Long_Complex := Fast_Log (A);
            B : constant Long_Long_Complex :=
               (Re => 1.0 - iX.Re, Im => -iX.Im);
               --  1.0 - iX
            Log_B : constant Long_Long_Complex := Fast_Log (B);
            C : constant Long_Long_Complex :=
               (Re => Log_A.Re - Log_B.Re, Im => Log_A.Im - Log_B.Im);
               --  Log_A - Log_B
            Result : constant Long_Long_Complex :=
               (Re => C.Im / 2.0, Im => -C.Re / 2.0);
               --  -i * C / 2.0
         begin
            return Result;
         end;
      end if;
   end Fast_Arctan;

   function Fast_Sinh (X : Long_Long_Complex) return Long_Long_Complex is
   begin
      if abs X.Re < Square_Root_Epsilon
         and then abs X.Re < Square_Root_Epsilon
      then
         return X;
      else
         return (
            Re =>
               Long_Long_Elementary_Functions.Fast_Sinh (X.Re)
               * Long_Long_Elementary_Functions.Fast_Cos (X.Im),
            Im =>
               Long_Long_Elementary_Functions.Fast_Cosh (X.Re)
               * Long_Long_Elementary_Functions.Fast_Sin (X.Im));
      end if;
   end Fast_Sinh;

   function Fast_Cosh (X : Long_Long_Complex) return Long_Long_Complex is
   begin
      return (
         Re =>
            Long_Long_Elementary_Functions.Fast_Cosh (X.Re)
            * Long_Long_Elementary_Functions.Fast_Cos (X.Im),
         Im =>
            Long_Long_Elementary_Functions.Fast_Sinh (X.Re)
            * Long_Long_Elementary_Functions.Fast_Sin (X.Im));
   end Fast_Cosh;

   function Fast_Tanh (X : Long_Long_Complex) return Long_Long_Complex is
   begin
      if abs X.Re < Square_Root_Epsilon
         and then abs X.Im < Square_Root_Epsilon
      then
         return X;
      elsif X.Re > Log_Inverse_Epsilon_2 then
         return (Re => 1.0, Im => 0.0);
      elsif X.Re < -Log_Inverse_Epsilon_2 then
         return (Re => -1.0, Im => 0.0);
      else
         return Fast_Sinh (X) / Fast_Cosh (X);
      end if;
   end Fast_Tanh;

   function Fast_Arcsinh (X : Long_Long_Complex) return Long_Long_Complex is
   begin
      if abs X.Re < Square_Root_Epsilon
         and then abs X.Im < Square_Root_Epsilon
      then
         return X;
      elsif abs X.Re > Inv_Square_Root_Epsilon
         or else abs X.Im > Inv_Square_Root_Epsilon
      then
         declare
            Log_X : constant Long_Long_Complex := Fast_Log (X);
            Result : constant Long_Long_Complex :=
               (Re => Log_2 + Log_X.Re, Im => Log_X.Im);
               --  Log_2 + Log_X
         begin
            if (X.Re < 0.0 and then Result.Re > 0.0)
               or else (X.Re > 0.0 and then Result.Re < 0.0)
            then
               return (Re => -Result.Re, Im => Result.Im);
            else
               return Result;
            end if;
         end;
      else
         declare
            X_X : constant Long_Long_Complex := X * X;
            A : constant Long_Long_Complex :=
               (Re => 1.0 + X_X.Re, Im => X_X.Im);
               --  1.0 + X_X
            Sqrt_A : constant Long_Long_Complex := Fast_Sqrt (A);
            B : constant Long_Long_Complex :=
               (Re => X.Re + Sqrt_A.Re, Im => X.Im + Sqrt_A.Im);
               --  X + Sqrt_A
            Result : constant Long_Long_Complex := Fast_Log (B);
         begin
            if X.Re = 0.0 then
               return (Re => X.Re, Im => Result.Im);
            elsif X.Im = 0.0 then
               return (Re => Result.Re, Im => X.Im);
            else
               return Result;
            end if;
         end;
      end if;
   end Fast_Arcsinh;

   function Fast_Arccosh (X : Long_Long_Complex) return Long_Long_Complex is
   begin
      if X.Re = 1.0 and then X.Im = 0.0 then
         return (Re => 0.0, Im => 0.0);
      elsif abs X.Re < Square_Root_Epsilon
         and then abs X.Im < Square_Root_Epsilon
      then
         declare
            Result : constant Long_Long_Complex :=
               (Re => -X.Im, Im => X.Re - Pi_Div_2);
               --  i * X - i * (Pi / 2)
         begin
            if Result.Re <= 0.0 then
               return (Re => -Result.Re, Im => -Result.Im);
            else
               return Result;
            end if;
         end;
      elsif abs X.Re > Inv_Square_Root_Epsilon
         or else abs X.Im > Inv_Square_Root_Epsilon
      then
         declare
            Log_X : constant Long_Long_Complex := Fast_Log (X);
            Result : constant Long_Long_Complex :=
               (Re => Log_2 + Log_X.Re, Im => Log_X.Im);
               --  Log_2 + Log_X
         begin
            if Result.Re <= 0.0 then
               return (Re => -Result.Re, Im => -Result.Im);
            else
               return Result;
            end if;
         end;
      else
         declare
            A : constant Long_Long_Complex := (Re => X.Re + 1.0, Im => X.Im);
               --  X + 1.0
            B : constant Long_Long_Complex :=
               (Re => A.Re / 2.0, Im => A.Im / 2.0);
               --  A / 2.0
            Sqrt_B : constant Long_Long_Complex := Fast_Sqrt (B);
            C : constant Long_Long_Complex := (Re => X.Re - 1.0, Im => X.Im);
               --  X - 1.0
            D : constant Long_Long_Complex :=
               (Re => C.Re / 2.0, Im => C.Im / 2.0);
               --  C / 2.0
            Sqrt_D : constant Long_Long_Complex := Fast_Sqrt (D);
            E : constant Long_Long_Complex :=
               (Re => Sqrt_B.Re + Sqrt_D.Re, Im => Sqrt_B.Im + Sqrt_D.Im);
               --  Sqrt_B + Sqrt_D
            Log_E : constant Long_Long_Complex := Fast_Log (E);
            Result : constant Long_Long_Complex :=
               (Re => 2.0 * Log_E.Re, Im => 2.0 * Log_E.Im);
               --  2.0 * Log_E
         begin
            if Result.Re <= 0.0 then
               return (Re => -Result.Re, Im => -Result.Im);
            else
               return Result;
            end if;
         end;
      end if;
   end Fast_Arccosh;

   function Fast_Arctanh (X : Long_Long_Complex) return Long_Long_Complex is
   begin
      if abs X.Re < Square_Root_Epsilon
         and then abs X.Im < Square_Root_Epsilon
      then
         return X;
      else
         declare
            A : constant Long_Long_Complex := (Re => 1.0 + X.Re, Im => X.Im);
               --  1.0 + X
            Log_A : constant Long_Long_Complex := Fast_Log (A);
            B : constant Long_Long_Complex := (Re => 1.0 - X.Re, Im => -X.Im);
               --  1.0 - X
            Log_B : constant Long_Long_Complex := Fast_Log (B);
            C : constant Long_Long_Complex :=
               (Re => Log_A.Re - Log_B.Re, Im => Log_A.Im - Log_B.Im);
               --  Log_A - Log_B
            Result : constant Long_Long_Complex :=
               (Re => C.Re / 2.0, Im => C.Im / 2.0);
               --  C / 2.0
         begin
            return Result;
         end;
      end if;
   end Fast_Arctanh;

end System.Long_Long_Complex_Elementary_Functions;
