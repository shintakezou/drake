pragma License (Unrestricted);
--  implementation unit specialized for FreeBSD (or Linux)
with Ada.IO_Exceptions;
with Ada.Streams;
with C.iconv;
private with Ada.Finalization;
package System.Native_Environment_Encoding is
   --  Platform-depended text encoding.
   pragma Preelaborate;
   use type C.char_array;

   --  max length of one multi-byte character

   Max_Substitute_Length : constant := 6; -- UTF-8

   --  encoding identifier

   type Encoding_Id is access constant C.char;
   for Encoding_Id'Storage_Size use 0;

   function Get_Image (Encoding : Encoding_Id) return String;

   function Get_Default_Substitute (Encoding : Encoding_Id)
      return Ada.Streams.Stream_Element_Array;

   function Get_Min_Size_In_Stream_Elements (Encoding : Encoding_Id)
      return Ada.Streams.Stream_Element_Offset;

   UTF_8_Name : aliased constant C.char_array (0 .. 5) :=
      "UTF-8" & C.char'Val (0);
   UTF_8 : constant Encoding_Id := UTF_8_Name (0)'Access;
   UTF_16_Names : aliased constant
         array (Bit_Order) of aliased C.char_array (0 .. 8) := (
      High_Order_First => "UTF-16BE" & C.char'Val (0),
      Low_Order_First => "UTF-16LE" & C.char'Val (0));
   UTF_16 : constant Encoding_Id := UTF_16_Names (Default_Bit_Order)(0)'Access;
   UTF_16BE : constant Encoding_Id :=
      UTF_16_Names (High_Order_First)(0)'Access;
   UTF_16LE : constant Encoding_Id :=
      UTF_16_Names (Low_Order_First)(0)'Access;
   UTF_32_Names : aliased constant
         array (Bit_Order) of aliased C.char_array (0 .. 8) := (
      High_Order_First => "UTF-32BE" & C.char'Val (0),
      Low_Order_First => "UTF-32LE" & C.char'Val (0));
   UTF_32 : constant Encoding_Id := UTF_32_Names (Default_Bit_Order)(0)'Access;
   UTF_32BE : constant Encoding_Id :=
      UTF_32_Names (High_Order_First)(0)'Access;
   UTF_32LE : constant Encoding_Id :=
      UTF_32_Names (Low_Order_First)(0)'Access;

   function Get_Current_Encoding return Encoding_Id;
      --  Returns UTF-8. In POSIX, The system encoding is assumed as UTF-8.
   pragma Inline (Get_Current_Encoding);

   --  subsidiary types to converter

   type Subsequence_Status_Type is (
      Finished,
      Success,
      Overflow, -- the output buffer is not large enough
      Illegal_Sequence, -- a input character could not be mapped to the output
      Truncated); -- the input buffer is broken off at a multi-byte character
   pragma Discard_Names (Subsequence_Status_Type);

   type Continuing_Status_Type is
      new Subsequence_Status_Type range
         Success ..
         Subsequence_Status_Type'Last;
   type Finishing_Status_Type is
      new Subsequence_Status_Type range
         Finished ..
         Overflow;
   type Status_Type is
      new Subsequence_Status_Type range
         Finished ..
         Illegal_Sequence;

   type Substituting_Status_Type is
      new Status_Type range
         Finished ..
         Overflow;

   subtype True_Only is Boolean range True .. True;

   --  converter

   type Non_Controlled_Converter is record
      iconv : C.iconv.iconv_t;
      --  about "From"
      Min_Size_In_From_Stream_Elements : Ada.Streams.Stream_Element_Offset;
      --  about "To"
      Substitute_Length : Ada.Streams.Stream_Element_Offset;
      Substitute : Ada.Streams.Stream_Element_Array (
         1 ..
         Max_Substitute_Length);
   end record;
   pragma Suppress_Initialization (Non_Controlled_Converter);

   type Converter;

   package Controlled is

      type Converter is limited private;

      function Reference (Object : Native_Environment_Encoding.Converter)
         return not null access Non_Controlled_Converter;
      pragma Inline (Reference);

   private

      type Converter is
         limited new Ada.Finalization.Limited_Controlled with
      record
         Data : aliased Non_Controlled_Converter :=
            (iconv => C.iconv.iconv_t (Null_Address), others => <>);
      end record;

      overriding procedure Finalize (Object : in out Converter);

   end Controlled;

   type Converter is new Controlled.Converter;

   procedure Open (Object : in out Converter; From, To : Encoding_Id);

   function Get_Is_Open (Object : Converter) return Boolean;
   pragma Inline (Get_Is_Open);

   function Min_Size_In_From_Stream_Elements_No_Check (Object : Converter)
      return Ada.Streams.Stream_Element_Offset;

   function Substitute_No_Check (Object : Converter)
      return Ada.Streams.Stream_Element_Array;

   procedure Set_Substitute_No_Check (
      Object : in out Converter;
      Substitute : Ada.Streams.Stream_Element_Array);

   --  convert subsequence
   procedure Convert_No_Check (
      Object : Converter;
      Item : Ada.Streams.Stream_Element_Array;
      Last : out Ada.Streams.Stream_Element_Offset;
      Out_Item : out Ada.Streams.Stream_Element_Array;
      Out_Last : out Ada.Streams.Stream_Element_Offset;
      Finish : Boolean;
      Status : out Subsequence_Status_Type);

   procedure Convert_No_Check (
      Object : Converter;
      Item : Ada.Streams.Stream_Element_Array;
      Last : out Ada.Streams.Stream_Element_Offset;
      Out_Item : out Ada.Streams.Stream_Element_Array;
      Out_Last : out Ada.Streams.Stream_Element_Offset;
      Status : out Continuing_Status_Type);

   procedure Convert_No_Check (
      Object : Converter;
      Out_Item : out Ada.Streams.Stream_Element_Array;
      Out_Last : out Ada.Streams.Stream_Element_Offset;
      Finish : True_Only;
      Status : out Finishing_Status_Type);

   --  convert all character sequence
--  procedure Convert_No_Check (
--    Object : Converter;
--    Item : Ada.Streams.Stream_Element_Array;
--    Last : out Ada.Streams.Stream_Element_Offset;
--    Out_Item : out Ada.Streams.Stream_Element_Array;
--    Out_Last : out Ada.Streams.Stream_Element_Offset;
--    Finish : True_Only;
--    Status : out Status_Type);

   --  convert all character sequence with substitute
   procedure Convert_No_Check (
      Object : Converter;
      Item : Ada.Streams.Stream_Element_Array;
      Last : out Ada.Streams.Stream_Element_Offset;
      Out_Item : out Ada.Streams.Stream_Element_Array;
      Out_Last : out Ada.Streams.Stream_Element_Offset;
      Finish : True_Only;
      Status : out Substituting_Status_Type);

   procedure Put_Substitute (
      Object : Converter;
      Out_Item : out Ada.Streams.Stream_Element_Array;
      Out_Last : out Ada.Streams.Stream_Element_Offset;
      Is_Overflow : out Boolean);

   --  exceptions

   Name_Error : exception
      renames Ada.IO_Exceptions.Name_Error;
   Use_Error : exception
      renames Ada.IO_Exceptions.Use_Error;

end System.Native_Environment_Encoding;
