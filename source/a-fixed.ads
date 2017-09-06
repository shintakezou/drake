pragma License (Unrestricted);
package Ada.Fixed is
   --  There is a helper subprogram Divide for ordinary fixed types.
   pragma Pure;

   generic
      type Dividend_Type is delta <>;
      type Divisor_Type is delta <>;
      type Quotient_Type is delta <>;
      type Remainder_Type is delta <>;
   procedure Divide (
      Dividend : Dividend_Type;
      Divisor : Divisor_Type;
      Quotient : out Quotient_Type;
      Remainder : out Remainder_Type);

end Ada.Fixed;
