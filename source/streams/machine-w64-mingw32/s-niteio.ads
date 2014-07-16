pragma License (Unrestricted);
--  implementation unit specialized for Windows
with C.windef;
package System.Native_IO.Text_IO is
   pragma Preelaborate;

   --  file management

   Default_External : constant Ada.IO_Modes.File_External :=
      Ada.IO_Modes.Locale;
   Default_New_Line : constant Ada.IO_Modes.File_New_Line :=
      Ada.IO_Modes.CR_LF;

   type Packed_Form is record
      Stream_Form : Native_IO.Packed_Form;
      External : Ada.IO_Modes.File_External_Spec;
      New_Line : Ada.IO_Modes.File_New_Line_Spec;
      SUB : Ada.IO_Modes.File_SUB;
   end record;
   pragma Suppress_Initialization (Packed_Form);
   pragma Pack (Packed_Form);
   pragma Compile_Time_Error (Packed_Form'Size /= 4, "not packed");

   --  read / write

   subtype Buffer_Type is String (1 .. 12); -- 2 code-points of UTF-8

   subtype DBCS_Buffer_Type is String (1 .. 2);

   procedure To_UTF_8 (
      Buffer : aliased DBCS_Buffer_Type;
      Last : Natural;
      Out_Buffer : out Buffer_Type;
      Out_Last : out Natural);

   procedure To_DBCS (
      Buffer : Buffer_Type;
      Last : Natural;
      Out_Buffer : aliased out DBCS_Buffer_Type;
      Out_Last : out Natural);

   --  terminal

   procedure Terminal_Get (
      Handle : Handle_Type;
      Item : Address; -- requires 6 bytes at least
      Length : Ada.Streams.Stream_Element_Offset;
      Out_Length : out Ada.Streams.Stream_Element_Offset); -- -1 when error

   procedure Terminal_Get_Immediate (
      Handle : Handle_Type;
      Item : Address; -- requires 6 bytes at least
      Length : Ada.Streams.Stream_Element_Offset;
      Out_Length : out Ada.Streams.Stream_Element_Offset); -- -1 when error

   procedure Terminal_Put (
      Handle : Handle_Type;
      Item : Address;
      Length : Ada.Streams.Stream_Element_Offset;
      Out_Length : out Ada.Streams.Stream_Element_Offset); -- -1 when error

   procedure Terminal_Size (
      Handle : Handle_Type;
      Line_Length, Page_Length : out Natural);
   procedure Set_Terminal_Size (
      Handle : Handle_Type;
      Line_Length, Page_Length : Natural);

   procedure Terminal_View (
      Handle : Handle_Type;
      Left, Top : out Positive;
      Right, Bottom : out Natural);

   procedure Terminal_Position (
      Handle : Handle_Type;
      Col, Line : out Positive);
   procedure Set_Terminal_Position (
      Handle : Handle_Type;
      Col, Line : Positive);
   procedure Set_Terminal_Col (
      Handle : Handle_Type;
      To : Positive);

   procedure Terminal_Clear (
      Handle : Handle_Type);

   subtype Setting is C.windef.DWORD;

   procedure Set_Non_Canonical_Mode (
      Handle : Handle_Type;
      Wait : Boolean; -- unreferenced
      Saved_Settings : aliased out Setting);

   procedure Restore (
      Handle : Handle_Type;
      Settings : aliased Setting);

   --  exceptions

   Data_Error : exception
      renames Ada.IO_Exceptions.Data_Error;
   Layout_Error : exception
      renames Ada.IO_Exceptions.Layout_Error;

end System.Native_IO.Text_IO;
