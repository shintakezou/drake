pragma License (Unrestricted);
--  implementation unit
package System.Formatting.Literals is
   pragma Pure;

   --  parsing Ada-form literals

   procedure Skip_Spaces (Item : String; Last : in out Natural);

   procedure Check_Last (Item : String; Last : Natural; Error : out Boolean);

   procedure Get_Exponent (
      Item : String;
      Last : in out Natural;
      Result : out Integer;
      Positive_Only : Boolean;
      Error : out Boolean);

   --  for integer types

   procedure Get_Literal (
      Item : String;
      Last : out Natural;
      Result : out Long_Long_Integer_Types.Word_Integer;
      Error : out Boolean);

   procedure Get_Literal (
      Item : String;
      Last : out Natural;
      Result : out Long_Long_Integer;
      Error : out Boolean);

   --  for modular types

   procedure Get_Literal (
      Item : String;
      Last : out Natural;
      Result : out Long_Long_Integer_Types.Word_Unsigned;
      Error : out Boolean);

   procedure Get_Literal (
      Item : String;
      Last : out Natural;
      Result : out Long_Long_Integer_Types.Long_Long_Unsigned;
      Error : out Boolean);

end System.Formatting.Literals;
