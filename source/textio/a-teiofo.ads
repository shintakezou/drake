pragma License (Unrestricted);
--  implementation unit
with System.Formatting.Literals;
private package Ada.Text_IO.Formatting is

   --  for Integer_IO
   procedure Integer_Image (
      To : out String;
      Last : out Natural;
      Item : System.Formatting.Literals.Word_Integer;
      Base : Number_Base;
      Padding : Character;
      Padding_Width : Field);
   procedure Integer_Image (
      To : out String;
      Last : out Natural;
      Item : Long_Long_Integer;
      Base : Number_Base;
      Padding : Character;
      Padding_Width : Field);

   --  for Modular_IO
   procedure Modular_Image (
      To : out String;
      Last : out Natural;
      Item : System.Formatting.Word_Unsigned;
      Base : Number_Base;
      Padding : Character;
      Padding_Width : Field);
   procedure Modular_Image (
      To : out String;
      Last : out Natural;
      Item : System.Formatting.Longest_Unsigned;
      Base : Number_Base;
      Padding : Character;
      Padding_Width : Field);

   --  for Integer_IO, Modular_IO, Float_IO, Fixed_IO
   function Get_Numeric_Literal (
      File : File_Type; -- Input_File_Type
      Real : Boolean)
      return String;

   --  for Complex_IO
   function Get_Complex_Literal (
      File : File_Type) -- Input_File_Type
      return String;

   --  for Enumeration_IO
   function Get_Enum_Literal (
      File : File_Type) -- Input_File_Type
      return String;

   --  for Get (..., Width);
   procedure Get_Field (
      File : File_Type; -- Input_File_Type
      Item : out String;
      Last : out Natural);

   --  put with layout
   procedure Head (
      File : File_Type; -- Output_File_Type
      Item : String;
      Width : Field);
   procedure Tail (
      File : File_Type; -- Output_File_Type
      Item : String;
      Width : Field);

   --  get from string
   procedure Get_Head (
      Item : String;
      First : out Positive;
      Last : out Natural);
   procedure Get_Tail (Item : String; First : out Positive);

   --  put to string
   procedure Head (
      Target : out String;
      Source : String;
      Padding : Character := ' ');
   procedure Tail (
      Target : out String;
      Source : String;
      Padding : Character := ' ');
   procedure Tail (
      Target : out Wide_String;
      Source : Wide_String;
      Padding : Wide_Character := ' ');
   procedure Tail (
      Target : out Wide_Wide_String;
      Source : Wide_Wide_String;
      Padding : Wide_Wide_Character := ' ');

end Ada.Text_IO.Formatting;
