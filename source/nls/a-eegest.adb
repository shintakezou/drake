with Ada.Exceptions.Finally;
with Ada.Unchecked_Conversion;
with Ada.Unchecked_Deallocation;
package body Ada.Environment_Encoding.Generic_Strings is
   pragma Check_Policy (Validate => Ignore);
   use type Streams.Stream_Element_Offset;

   pragma Compile_Time_Error (
      String_Type'Component_Size /= Character_Type'Size,
      "String_Type is not packed");
   pragma Compile_Time_Error (
      Character_Type'Size rem Streams.Stream_Element'Size /= 0,
      "String_Type could not be treated as Stream_Element_Array");

   function Current_Id return Encoding_Id;
   function Current_Id return Encoding_Id is
   begin
      if Character_Type'Size = 8 then
         return UTF_8;
      elsif Character_Type'Size = 16 then
         return UTF_16;
      elsif Character_Type'Size = 32 then
         return UTF_32;
      else
         raise Program_Error; -- bad instance
      end if;
   end Current_Id;

   type String_Type_Access is access String_Type;
   procedure Free is
      new Unchecked_Deallocation (
         String_Type,
         String_Type_Access);

   procedure Expand (
      Item : in out String_Type_Access;
      Last : Natural);
   procedure Expand (
      Item : in out String_Type_Access;
      Last : Natural)
   is
      New_Item : constant String_Type_Access :=
         new String_Type (Item'First .. Item'First + 2 * Item'Length - 1);
   begin
      New_Item (Item'First .. Last) := Item.all (Item'First .. Last);
      Free (Item);
      Item := New_Item;
   end Expand;

   type Stream_Element_Array_Access is access Streams.Stream_Element_Array;
   procedure Free is
      new Unchecked_Deallocation (
         Streams.Stream_Element_Array,
         Stream_Element_Array_Access);

   procedure Expand (
      Item : in out Stream_Element_Array_Access;
      Last : Streams.Stream_Element_Offset);
   procedure Expand (
      Item : in out Stream_Element_Array_Access;
      Last : Streams.Stream_Element_Offset)
   is
      New_Item : constant Stream_Element_Array_Access :=
         new Streams.Stream_Element_Array (
            Item'First ..
            Item'First + 2 * Item'Length - 1);
   begin
      New_Item (Item'First .. Last) := Item.all (Item'First .. Last);
      Free (Item);
      Item := New_Item;
   end Expand;

   Minimal_Size : constant := 8;

   --  implementation of decoder

   function From (Id : Encoding_Id) return Decoder is
      --  [gcc-7] strange error if extended return is placed outside of
      --    the package Controlled, and Disable_Controlled => True
      type T1 is access function (From, To : Encoding_Id) return Converter;
      type T2 is access function (From, To : Encoding_Id) return Decoder;
      function Cast is new Unchecked_Conversion (T1, T2);
   begin
      return Cast (Controlled.Open'Access) (From => Id, To => Current_Id);
   end From;

   procedure Decode (
      Object : Decoder;
      Item : Streams.Stream_Element_Array;
      Last : out Streams.Stream_Element_Offset;
      Out_Item : out String_Type;
      Out_Last : out Natural;
      Finish : Boolean;
      Status : out Subsequence_Status_Type)
   is
      CS_In_SE : constant Streams.Stream_Element_Count :=
         Character_Type'Size / Streams.Stream_Element'Size;
      Out_Item_As_SEA :
         Streams.Stream_Element_Array (1 .. Out_Item'Length * CS_In_SE);
      for Out_Item_As_SEA'Address use Out_Item'Address;
      Out_Item_SEA_Last : Streams.Stream_Element_Offset;
   begin
      Convert (
         Object,
         Item,
         Last,
         Out_Item_As_SEA,
         Out_Item_SEA_Last,
         Finish,
         Status);
      pragma Check (Validate, Out_Item_SEA_Last rem CS_In_SE = 0);
      Out_Last := Out_Item'First + Integer (Out_Item_SEA_Last / CS_In_SE - 1);
   end Decode;

   procedure Decode (
      Object : Decoder;
      Item : Streams.Stream_Element_Array;
      Last : out Streams.Stream_Element_Offset;
      Out_Item : out String_Type;
      Out_Last : out Natural;
      Status : out Continuing_Status_Type)
   is
      CS_In_SE : constant Streams.Stream_Element_Count :=
         Character_Type'Size / Streams.Stream_Element'Size;
      Out_Item_As_SEA :
         Streams.Stream_Element_Array (1 .. Out_Item'Length * CS_In_SE);
      for Out_Item_As_SEA'Address use Out_Item'Address;
      Out_Item_SEA_Last : Streams.Stream_Element_Offset;
   begin
      Convert (Object, Item, Last, Out_Item_As_SEA, Out_Item_SEA_Last, Status);
      pragma Check (Validate, Out_Item_SEA_Last rem CS_In_SE = 0);
      Out_Last := Out_Item'First + Integer (Out_Item_SEA_Last / CS_In_SE - 1);
   end Decode;

   procedure Decode (
      Object : Decoder;
      Out_Item : out String_Type;
      Out_Last : out Natural;
      Finish : True_Only;
      Status : out Finishing_Status_Type)
   is
      CS_In_SE : constant Streams.Stream_Element_Count :=
         Character_Type'Size / Streams.Stream_Element'Size;
      Out_Item_As_SEA :
         Streams.Stream_Element_Array (1 .. Out_Item'Length * CS_In_SE);
      for Out_Item_As_SEA'Address use Out_Item'Address;
      Out_Item_SEA_Last : Streams.Stream_Element_Offset;
   begin
      Convert (Object, Out_Item_As_SEA, Out_Item_SEA_Last, Finish, Status);
      pragma Check (Validate, Out_Item_SEA_Last rem CS_In_SE = 0);
      Out_Last := Out_Item'First + Integer (Out_Item_SEA_Last / CS_In_SE - 1);
   end Decode;

   procedure Decode (
      Object : Decoder;
      Item : Streams.Stream_Element_Array;
      Last : out Streams.Stream_Element_Offset;
      Out_Item : out String_Type;
      Out_Last : out Natural;
      Finish : True_Only;
      Status : out Status_Type)
   is
      CS_In_SE : constant Streams.Stream_Element_Count :=
         Character_Type'Size / Streams.Stream_Element'Size;
      Out_Item_As_SEA :
         Streams.Stream_Element_Array (1 .. Out_Item'Length * CS_In_SE);
      for Out_Item_As_SEA'Address use Out_Item'Address;
      Out_Item_SEA_Last : Streams.Stream_Element_Offset;
   begin
      Convert (
         Object,
         Item,
         Last,
         Out_Item_As_SEA,
         Out_Item_SEA_Last,
         Finish,
         Status);
      pragma Check (Validate, Out_Item_SEA_Last rem CS_In_SE = 0);
      Out_Last := Out_Item'First + Integer (Out_Item_SEA_Last / CS_In_SE - 1);
   end Decode;

   procedure Decode (
      Object : Decoder;
      Item : Streams.Stream_Element_Array;
      Last : out Streams.Stream_Element_Offset;
      Out_Item : out String_Type;
      Out_Last : out Natural;
      Finish : True_Only;
      Status : out Substituting_Status_Type)
   is
      CS_In_SE : constant Streams.Stream_Element_Count :=
         Character_Type'Size / Streams.Stream_Element'Size;
      Out_Item_As_SEA :
         Streams.Stream_Element_Array (1 .. Out_Item'Length * CS_In_SE);
      for Out_Item_As_SEA'Address use Out_Item'Address;
      Out_Item_SEA_Last : Streams.Stream_Element_Offset;
   begin
      Convert (
         Object,
         Item,
         Last,
         Out_Item_As_SEA,
         Out_Item_SEA_Last,
         Finish,
         Status);
      pragma Check (Validate, Out_Item_SEA_Last rem CS_In_SE = 0);
      Out_Last := Out_Item'First + Integer (Out_Item_SEA_Last / CS_In_SE - 1);
   end Decode;

   function Decode (
      Object : Decoder;
      Item : Streams.Stream_Element_Array)
      return String_Type
   is
      package Holder is
         new Exceptions.Finally.Scoped_Holder (String_Type_Access, Free);
      CS_In_SE : constant Streams.Stream_Element_Count :=
         Character_Type'Size / Streams.Stream_Element'Size;
      MS_In_SE : constant Streams.Stream_Element_Positive_Count :=
         Min_Size_In_From_Stream_Elements (Object);
      I : Streams.Stream_Element_Offset := Item'First;
      Out_Item : aliased String_Type_Access;
      Out_Last : Natural;
   begin
      Holder.Assign (Out_Item);
      Out_Item := new String_Type (
         1 ..
         Natural (
            Streams.Stream_Element_Count'Max (
               2 * ((Item'Length + MS_In_SE - 1) / MS_In_SE),
               Minimal_Size / CS_In_SE)));
      Out_Last := 0;
      loop
         declare
            Last : Streams.Stream_Element_Offset;
            Status : Substituting_Status_Type;
         begin
            Decode (
               Object,
               Item (I .. Item'Last),
               Last,
               Out_Item.all (Out_Last + 1 .. Out_Item'Last),
               Out_Last,
               Finish => True,
               Status => Status);
            case Status is
               when Finished =>
                  exit;
               when Success =>
                  null;
               when Overflow =>
                  Expand (Out_Item, Out_Last);
            end case;
            I := Last + 1;
         end;
      end loop;
      return Out_Item (Out_Item'First .. Out_Last);
   end Decode;

   --  implementation of encoder

   function To (Id : Encoding_Id) return Encoder is
      --  [gcc-7] strange error if extended return is placed outside of
      --    the package Controlled, and Disable_Controlled => True
      type T1 is access function (From, To : Encoding_Id) return Converter;
      type T2 is access function (From, To : Encoding_Id) return Encoder;
      function Cast is new Unchecked_Conversion (T1, T2);
   begin
      return Cast (Controlled.Open'Access) (From => Current_Id, To => Id);
   end To;

   procedure Encode (
      Object : Encoder;
      Item : String_Type;
      Last : out Natural;
      Out_Item : out Streams.Stream_Element_Array;
      Out_Last : out Streams.Stream_Element_Offset;
      Finish : Boolean;
      Status : out Subsequence_Status_Type)
   is
      CS_In_SE : constant Streams.Stream_Element_Count :=
         Character_Type'Size / Streams.Stream_Element'Size;
      Item_As_SEA : Streams.Stream_Element_Array (1 .. Item'Length * CS_In_SE);
      for Item_As_SEA'Address use Item'Address;
      Item_SEA_Last : Streams.Stream_Element_Offset;
   begin
      Convert (
         Object,
         Item_As_SEA,
         Item_SEA_Last,
         Out_Item,
         Out_Last,
         Finish,
         Status);
      pragma Check (Validate, Item_SEA_Last rem CS_In_SE = 0);
      Last := Item'First + Integer (Item_SEA_Last / CS_In_SE - 1);
   end Encode;

   procedure Encode (
      Object : Encoder;
      Item : String_Type;
      Last : out Natural;
      Out_Item : out Streams.Stream_Element_Array;
      Out_Last : out Streams.Stream_Element_Offset;
      Status : out Continuing_Status_Type)
   is
      CS_In_SE : constant Streams.Stream_Element_Count :=
         Character_Type'Size / Streams.Stream_Element'Size;
      Item_As_SEA : Streams.Stream_Element_Array (1 .. Item'Length * CS_In_SE);
      for Item_As_SEA'Address use Item'Address;
      Item_SEA_Last : Streams.Stream_Element_Offset;
   begin
      Convert (Object, Item_As_SEA, Item_SEA_Last, Out_Item, Out_Last, Status);
      pragma Check (Validate, Item_SEA_Last rem CS_In_SE = 0);
      Last := Item'First + Integer (Item_SEA_Last / CS_In_SE - 1);
   end Encode;

   procedure Encode (
      Object : Encoder;
      Item : String_Type;
      Last : out Natural;
      Out_Item : out Streams.Stream_Element_Array;
      Out_Last : out Streams.Stream_Element_Offset;
      Finish : True_Only;
      Status : out Status_Type)
   is
      CS_In_SE : constant Streams.Stream_Element_Count :=
         Character_Type'Size / Streams.Stream_Element'Size;
      Item_As_SEA : Streams.Stream_Element_Array (1 .. Item'Length * CS_In_SE);
      for Item_As_SEA'Address use Item'Address;
      Item_SEA_Last : Streams.Stream_Element_Offset;
   begin
      Convert (
         Object,
         Item_As_SEA,
         Item_SEA_Last,
         Out_Item,
         Out_Last,
         Finish,
         Status);
      pragma Check (Validate, Item_SEA_Last rem CS_In_SE = 0);
      Last := Item'First + Integer (Item_SEA_Last / CS_In_SE - 1);
   end Encode;

   procedure Encode (
      Object : Encoder;
      Item : String_Type;
      Last : out Natural;
      Out_Item : out Streams.Stream_Element_Array;
      Out_Last : out Streams.Stream_Element_Offset;
      Finish : True_Only;
      Status : out Substituting_Status_Type)
   is
      CS_In_SE : constant Streams.Stream_Element_Count :=
         Character_Type'Size / Streams.Stream_Element'Size;
      Item_As_SEA : Streams.Stream_Element_Array (1 .. Item'Length * CS_In_SE);
      for Item_As_SEA'Address use Item'Address;
      Item_SEA_Last : Streams.Stream_Element_Offset;
   begin
      Convert (
         Object,
         Item_As_SEA,
         Item_SEA_Last,
         Out_Item,
         Out_Last,
         Finish,
         Status);
      pragma Check (Validate, Item_SEA_Last rem CS_In_SE = 0);
      Last := Item'First + Integer (Item_SEA_Last / CS_In_SE - 1);
   end Encode;

   function Encode (
      Object : Encoder;
      Item : String_Type)
      return Streams.Stream_Element_Array
   is
      package Holder is
         new Exceptions.Finally.Scoped_Holder (
            Stream_Element_Array_Access,
            Free);
      CS_In_SE : constant Streams.Stream_Element_Count :=
         Character_Type'Size / Streams.Stream_Element'Size;
      I : Positive := Item'First;
      Out_Item : aliased Stream_Element_Array_Access;
      Out_Last : Streams.Stream_Element_Offset;
   begin
      Holder.Assign (Out_Item);
      Out_Item := new Streams.Stream_Element_Array (
         0 ..
         Streams.Stream_Element_Offset'Max (
               2 * Item'Length * CS_In_SE,
               Minimal_Size)
            - 1);
      Out_Last := -1;
      loop
         declare
            Last : Natural;
            Status : Substituting_Status_Type;
         begin
            Encode (
               Object,
               Item (I .. Item'Last),
               Last,
               Out_Item.all (Out_Last + 1 .. Out_Item'Last),
               Out_Last,
               Finish => True,
               Status => Status);
            case Status is
               when Finished =>
                  exit;
               when Success =>
                  null;
               when Overflow =>
                  Expand (Out_Item, Out_Last);
            end case;
            I := Last + 1;
         end;
      end loop;
      return Out_Item (Out_Item'First .. Out_Last);
   end Encode;

end Ada.Environment_Encoding.Generic_Strings;
