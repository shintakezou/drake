with Ada.Exception_Identification.From_Here;
with System.Debug;
with System.Address_To_Constant_Access_Conversions;
with System.Address_To_Named_Access_Conversions;
with System.Zero_Terminated_Strings;
with C.errno;
package body System.Native_Environment_Encoding is
   use Ada.Exception_Identification.From_Here;
   use type Ada.Streams.Stream_Element_Offset;
   use type C.iconv.iconv_t; -- C.void_ptr
   use type C.signed_int;
   use type C.size_t;

   package char_ptr_Conv is
      new Address_To_Named_Access_Conversions (C.char, C.char_ptr);
   package char_const_ptr_Conv is
      new Address_To_Constant_Access_Conversions (C.char, C.char_const_ptr);

   procedure Default_Substitute (
      Encoding : Encoding_Id;
      Item : out Ada.Streams.Stream_Element_Array;
      Last : out Ada.Streams.Stream_Element_Offset);
   procedure Default_Substitute (
      Encoding : Encoding_Id;
      Item : out Ada.Streams.Stream_Element_Array;
      Last : out Ada.Streams.Stream_Element_Offset) is
   begin
      if Encoding = UTF_16_Names (High_Order_First)(0)'Access then
         Last := Item'First;
         Item (Last) := 0;
         Last := Last + 1;
         Item (Last) := Character'Pos ('?');
      elsif Encoding = UTF_16_Names (Low_Order_First)(0)'Access then
         Last := Item'First;
         Item (Last) := Character'Pos ('?');
         Last := Last + 1;
         Item (Last) := 0;
      elsif Encoding = UTF_32_Names (High_Order_First)(0)'Access then
         Last := Item'First;
         Item (Last) := 0;
         Last := Last + 1;
         Item (Last) := 0;
         Last := Last + 1;
         Item (Last) := 0;
         Last := Last + 1;
         Item (Last) := Character'Pos ('?');
      elsif Encoding = UTF_32_Names (Low_Order_First)(0)'Access then
         Last := Item'First;
         Item (Last) := Character'Pos ('?');
         Last := Last + 1;
         Item (Last) := 0;
         Last := Last + 1;
         Item (Last) := 0;
         Last := Last + 1;
         Item (Last) := 0;
      else
         Last := Item'First;
         Item (Last) := Character'Pos ('?');
      end if;
   end Default_Substitute;

   --  implementation

   function Get_Image (Encoding : Encoding_Id) return String is
   begin
      return Zero_Terminated_Strings.Value (Encoding);
   end Get_Image;

   function Get_Default_Substitute (Encoding : Encoding_Id)
      return Ada.Streams.Stream_Element_Array
   is
      Result : Ada.Streams.Stream_Element_Array (
         0 .. -- from 0 for a result value
         Max_Substitute_Length - 1);
      Last : Ada.Streams.Stream_Element_Offset;
   begin
      Default_Substitute (Encoding, Result, Last);
      return Result (Result'First .. Last);
   end Get_Default_Substitute;

   function Get_Min_Size_In_Stream_Elements (Encoding : Encoding_Id)
      return Ada.Streams.Stream_Element_Offset is
   begin
      if Encoding = UTF_16_Names (High_Order_First)(0)'Access
         or else Encoding = UTF_16_Names (Low_Order_First)(0)'Access
      then
         return 2;
      elsif Encoding = UTF_32_Names (High_Order_First)(0)'Access
         or else Encoding = UTF_32_Names (Low_Order_First)(0)'Access
      then
         return 4;
      else
         return 1;
      end if;
   end Get_Min_Size_In_Stream_Elements;

   function Get_Current_Encoding return Encoding_Id is
   begin
      return UTF_8_Name (0)'Access;
   end Get_Current_Encoding;

   procedure Open (Object : in out Converter; From, To : Encoding_Id) is
      Error : constant C.iconv.iconv_t :=
         C.iconv.iconv_t (System'To_Address (-1));
      iconv : C.iconv.iconv_t;
   begin
      iconv := C.iconv.iconv_open (To, From);
      if iconv = Error then
         Raise_Exception (Name_Error'Identity);
      end if;
      Object.iconv := iconv;
      --  about "From"
      Object.Min_Size_In_From_Stream_Elements :=
         Get_Min_Size_In_Stream_Elements (From);
      --  about "To"
      Default_Substitute (To, Object.Substitute, Object.Substitute_Length);
   end Open;

   procedure Close (Object : in out Converter) is
      pragma Unmodified (Object);
   begin
      if Object.iconv /= C.void_ptr (Null_Address) then
         declare
            R : C.signed_int;
         begin
            R := C.iconv.iconv_close (Object.iconv);
            pragma Check (Debug,
               Check =>
                  not (R < 0)
                  or else Debug.Runtime_Error ("iconv_close failed"));
         end;
      end if;
   end Close;

   function Is_Open (Object : Converter) return Boolean is
   begin
      return Object.iconv /= C.void_ptr (Null_Address);
   end Is_Open;

   function Min_Size_In_From_Stream_Elements_No_Check (Object : Converter)
      return Ada.Streams.Stream_Element_Offset is
   begin
      return Object.Min_Size_In_From_Stream_Elements;
   end Min_Size_In_From_Stream_Elements_No_Check;

   function Substitute_No_Check (Object : Converter)
      return Ada.Streams.Stream_Element_Array is
   begin
      return Object.Substitute (1 .. Object.Substitute_Length);
   end Substitute_No_Check;

   procedure Set_Substitute_No_Check (
      Object : in out Converter;
      Substitute : Ada.Streams.Stream_Element_Array) is
   begin
      if Substitute'Length > Object.Substitute'Length then
         raise Constraint_Error;
      end if;
      Object.Substitute_Length := Substitute'Length;
      Object.Substitute (1 .. Object.Substitute_Length) := Substitute;
   end Set_Substitute_No_Check;

   procedure Convert_No_Check (
      Object : Converter;
      Item : Ada.Streams.Stream_Element_Array;
      Last : out Ada.Streams.Stream_Element_Offset;
      Out_Item : out Ada.Streams.Stream_Element_Array;
      Out_Last : out Ada.Streams.Stream_Element_Offset;
      Finish : Boolean;
      Status : out Subsequence_Status_Type)
   is
      Continuing_Status : Continuing_Status_Type;
      Finishing_Status : Finishing_Status_Type;
   begin
      Convert_No_Check (
         Object,
         Item,
         Last,
         Out_Item,
         Out_Last,
         Status => Continuing_Status);
      Status := Subsequence_Status_Type (Continuing_Status);
      if Finish and then Status = Success and then Last = Item'Last then
         Convert_No_Check (
            Object,
            Out_Item (Out_Last + 1 .. Out_Item'Last),
            Out_Last,
            Finish => True,
            Status => Finishing_Status);
         Status := Subsequence_Status_Type (Finishing_Status);
      end if;
   end Convert_No_Check;

   procedure Convert_No_Check (
      Object : Converter;
      Item : Ada.Streams.Stream_Element_Array;
      Last : out Ada.Streams.Stream_Element_Offset;
      Out_Item : out Ada.Streams.Stream_Element_Array;
      Out_Last : out Ada.Streams.Stream_Element_Offset;
      Status : out Continuing_Status_Type)
   is
      Pointer : aliased C.char_const_ptr :=
         char_const_ptr_Conv.To_Pointer (Item'Address);
      Size : aliased C.size_t := Item'Length;
      Out_Pointer : aliased C.char_ptr :=
         char_ptr_Conv.To_Pointer (Out_Item'Address);
      Out_Size : aliased C.size_t := Out_Item'Length;
      errno : C.signed_int;
   begin
      if C.iconv.iconv (
         Object.iconv,
         Pointer'Access,
         Size'Access,
         Out_Pointer'Access,
         Out_Size'Access) = C.size_t'Last
      then
         errno := C.errno.errno;
         case errno is
            when C.errno.E2BIG =>
               Status := Overflow;
            when C.errno.EINVAL =>
               Status := Truncated;
            when others => -- C.errno.EILSEQ =>
               Status := Illegal_Sequence;
         end case;
      else
         Status := Success;
      end if;
      Last := Item'First
         + (Item'Length - Ada.Streams.Stream_Element_Offset (Size) - 1);
      Out_Last := Out_Item'First
         + (
            Out_Item'Length
            - Ada.Streams.Stream_Element_Offset (Out_Size)
            - 1);
   end Convert_No_Check;

   procedure Convert_No_Check (
      Object : Converter;
      Out_Item : out Ada.Streams.Stream_Element_Array;
      Out_Last : out Ada.Streams.Stream_Element_Offset;
      Finish : True_Only;
      Status : out Finishing_Status_Type)
   is
      pragma Unreferenced (Finish);
      Out_Pointer : aliased C.char_ptr :=
         char_ptr_Conv.To_Pointer (Out_Item'Address);
      Out_Size : aliased C.size_t := Out_Item'Length;
      errno : C.signed_int;
   begin
      if C.iconv.iconv (
         Object.iconv,
         null,
         null,
         Out_Pointer'Access,
         Out_Size'Access) = C.size_t'Last
      then
         errno := C.errno.errno;
         case errno is
            when C.errno.E2BIG =>
               Status := Overflow;
            when others => -- unknown
               Raise_Exception (Use_Error'Identity);
         end case;
      else
         Status := Finished;
      end if;
      Out_Last := Out_Item'First
         + (
            Out_Item'Length
            - Ada.Streams.Stream_Element_Offset (Out_Size)
            - 1);
   end Convert_No_Check;

   procedure Convert_No_Check (
      Object : Converter;
      Item : Ada.Streams.Stream_Element_Array;
      Last : out Ada.Streams.Stream_Element_Offset;
      Out_Item : out Ada.Streams.Stream_Element_Array;
      Out_Last : out Ada.Streams.Stream_Element_Offset;
      Finish : True_Only;
      Status : out Substituting_Status_Type)
   is
      Index : Ada.Streams.Stream_Element_Offset := Item'First;
      Out_Index : Ada.Streams.Stream_Element_Offset := Out_Item'First;
   begin
      loop
         declare
            Subsequence_Status : Subsequence_Status_Type;
         begin
            Convert_No_Check (
               Object,
               Item (Index .. Item'Last),
               Last,
               Out_Item (Out_Index .. Out_Item'Last),
               Out_Last,
               Finish => Finish,
               Status => Subsequence_Status);
            pragma Assert (
               Subsequence_Status in
                  Subsequence_Status_Type (Status_Type'First) ..
                  Subsequence_Status_Type (Status_Type'Last));
            case Status_Type (Subsequence_Status) is
               when Finished =>
                  Status := Finished;
                  return;
               when Success =>
                  Status := Success;
                  return;
               when Overflow =>
                  Status := Overflow;
                  return;
               when Illegal_Sequence =>
                  declare
                     Is_Overflow : Boolean;
                  begin
                     Put_Substitute (
                        Object,
                        Out_Item (Out_Last + 1 .. Out_Item'Last),
                        Out_Last,
                        Is_Overflow);
                     if Is_Overflow then
                        Status := Overflow;
                        return; -- wait a next try
                     end if;
                  end;
                  declare
                     New_Last : Ada.Streams.Stream_Element_Offset :=
                        Last + Object.Min_Size_In_From_Stream_Elements;
                  begin
                     if New_Last > Item'Last
                        or else New_Last < Last -- overflow
                     then
                        New_Last := Item'Last;
                     end if;
                     Last := New_Last;
                  end;
                  Index := Last + 1;
                  Out_Index := Out_Last + 1;
            end case;
         end;
      end loop;
   end Convert_No_Check;

   procedure Put_Substitute (
      Object : Converter;
      Out_Item : out Ada.Streams.Stream_Element_Array;
      Out_Last : out Ada.Streams.Stream_Element_Offset;
      Is_Overflow : out Boolean) is
   begin
      Is_Overflow := Out_Item'Length < Object.Substitute_Length;
      if Is_Overflow then
         Out_Last := Out_Item'First - 1;
      else
         Out_Last := Out_Item'First + (Object.Substitute_Length - 1);
         Out_Item (Out_Item'First .. Out_Last) :=
            Object.Substitute (1 .. Object.Substitute_Length);
      end if;
   end Put_Substitute;

end System.Native_Environment_Encoding;
