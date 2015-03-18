with Ada.Exception_Identification.From_Here;
with Ada.IO_Modes;
with Ada.Streams.Stream_IO.Naked;
package body Ada.Storage_Mapped_IO is
   use Exception_Identification.From_Here;
   use type Streams.Stream_Element_Offset;
   use type System.Address;

   procedure Map (
      Object : in out Non_Controlled_Mapping;
      File : Streams.Naked_Stream_IO.Non_Controlled_File_Type;
      Offset : Streams.Stream_IO.Positive_Count;
      Size : Streams.Stream_IO.Count;
      Writable : Boolean);
   procedure Map (
      Object : in out Non_Controlled_Mapping;
      File : Streams.Naked_Stream_IO.Non_Controlled_File_Type;
      Offset : Streams.Stream_IO.Positive_Count;
      Size : Streams.Stream_IO.Count;
      Writable : Boolean)
   is
      Mapped_Size : Streams.Stream_IO.Count;
   begin
      if Size = 0 then
         Mapped_Size := Streams.Naked_Stream_IO.Size (File) - (Offset - 1);
      else
         Mapped_Size := Size;
      end if;
      System.Native_IO.Map (
         Object.Mapping,
         Streams.Naked_Stream_IO.Handle (File),
         Offset,
         Mapped_Size,
         Writable);
   end Map;

   procedure Unmap (
      Object : in out Non_Controlled_Mapping;
      Raise_On_Error : Boolean);
   procedure Unmap (
      Object : in out Non_Controlled_Mapping;
      Raise_On_Error : Boolean) is
   begin
      --  unmap
      System.Native_IO.Unmap (
         Object.Mapping,
         Raise_On_Error => Raise_On_Error);
      --  close file
      if Streams.Naked_Stream_IO.Is_Open (Object.File) then
         Streams.Naked_Stream_IO.Close (
            Object.File,
            Raise_On_Error => Raise_On_Error);
      end if;
   end Unmap;

   --  implementation

   function Is_Map (Object : Mapping) return Boolean is
      NC_Mapping : constant not null access Non_Controlled_Mapping :=
         Reference (Object);
   begin
      return NC_Mapping.Mapping.Storage_Address /= System.Null_Address;
   end Is_Map;

   procedure Map (
      Object : out Mapping;
      File : Streams.Stream_IO.File_Type;
      Offset : Streams.Stream_IO.Positive_Count := 1;
      Size : Streams.Stream_IO.Count := 0)
   is
      pragma Unmodified (Object); -- modified via 'Unrestricted_Access
      NC_Mapping : constant not null access Non_Controlled_Mapping :=
         Reference (Object);
   begin
      --  check already opened
      if NC_Mapping.Mapping.Storage_Address /= System.Null_Address then
         Raise_Exception (Status_Error'Identity);
      end if;
      --  map
      Map (
         NC_Mapping.all,
         Streams.Stream_IO.Naked.Non_Controlled (File).all,
         Offset,
         Size,
         Writable => Streams.Stream_IO.Mode (File) /= In_File);
   end Map;

   procedure Map (
      Object : out Mapping;
      Mode : File_Mode := In_File;
      Name : String;
      Form : String := "";
      Offset : Streams.Stream_IO.Positive_Count := 1;
      Size : Streams.Stream_IO.Count := 0)
   is
      pragma Unmodified (Object); -- modified via 'Unrestricted_Access
      NC_Mapping : constant not null access Non_Controlled_Mapping :=
         Reference (Object);
   begin
      --  check already opened
      if NC_Mapping.Mapping.Storage_Address /= System.Null_Address then
         Raise_Exception (Status_Error'Identity);
      end if;
      --  open file
      --  this file will be closed in Finalize even if any exception is raised
      Streams.Naked_Stream_IO.Open (
         NC_Mapping.File,
         IO_Modes.File_Mode (Mode),
         Name,
         Streams.Naked_Stream_IO.Pack (Form));
      --  map
      Map (
         NC_Mapping.all,
         NC_Mapping.File,
         Offset,
         Size,
         Writable => Mode /= In_File);
   end Map;

   procedure Unmap (Object : in out Mapping) is
      NC_Mapping : constant not null access Non_Controlled_Mapping :=
         Reference (Object);
   begin
      if NC_Mapping.Mapping.Storage_Address = System.Null_Address then
         Raise_Exception (Status_Error'Identity);
      end if;
      Unmap (NC_Mapping.all, Raise_On_Error => True);
   end Unmap;

   function Storage_Address (Object : Mapping) return System.Address is
      NC_Mapping : constant not null access Non_Controlled_Mapping :=
         Reference (Object);
   begin
      return NC_Mapping.Mapping.Storage_Address;
   end Storage_Address;

   function Storage_Size (Object : Mapping)
      return System.Storage_Elements.Storage_Count
   is
      NC_Mapping : constant not null access Non_Controlled_Mapping :=
         Reference (Object);
   begin
      return NC_Mapping.Mapping.Storage_Size;
   end Storage_Size;

   package body Controlled is

      function Reference (Object : Mapping)
         return not null access Non_Controlled_Mapping is
      begin
         return Object.Data'Unrestricted_Access;
      end Reference;

      overriding procedure Finalize (Object : in out Mapping) is
      begin
         if Object.Data.Mapping.Storage_Address /= System.Null_Address then
            Unmap (Object.Data, Raise_On_Error => False);
         end if;
      end Finalize;

   end Controlled;

end Ada.Storage_Mapped_IO;