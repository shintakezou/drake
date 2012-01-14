pragma License (Unrestricted);
--  extended unit
with Ada.IO_Exceptions;
with System.Storage_Elements;
private with Ada.Finalization;
package Ada.Streams.Buffer_Storage_IO is
   --  This package provides temporary stream on memory.
   pragma Preelaborate;

   type Buffer is tagged private;

   function Size (Object : Buffer) return Stream_Element_Count;
   pragma Inline (Size);
   procedure Set_Size (
      Object : in out Buffer;
      New_Size : Stream_Element_Count);

   --  direct storage accessing
   function Address (Object : Buffer) return System.Address;
   pragma Inline (Address);
   function Size (Object : Buffer)
      return System.Storage_Elements.Storage_Count;
   pragma Inline (Size);

   --  streaming
   function Stream (Object : Buffer)
      return not null access Root_Stream_Type'Class;
   pragma Inline (Stream);

   End_Error : exception
      renames IO_Exceptions.End_Error;

private

   type Stream_Element_Array_Access is access Stream_Element_Array;

   type Stream_Type is new Seekable_Stream_Type with record
      Data : System.Address;
      Capacity : Stream_Element_Offset;
      Last : Stream_Element_Offset;
      Index : Stream_Element_Offset := 1;
   end record;

   overriding procedure Read (
      Stream : in out Stream_Type;
      Item : out Stream_Element_Array;
      Last : out Stream_Element_Offset);
   overriding procedure Write (
      Stream : in out Stream_Type;
      Item : Stream_Element_Array);
   overriding procedure Set_Index (
      Stream : in out Stream_Type;
      To : Stream_Element_Positive_Count);
   overriding function Index (Stream : Stream_Type)
      return Stream_Element_Positive_Count;
   overriding function Size (Stream : Stream_Type)
      return Stream_Element_Count;

   type Stream_Access is access Stream_Type;

   type Buffer is new Finalization.Controlled with record
      Stream : Stream_Access;
   end record;

   overriding procedure Initialize (Object : in out Buffer);
   overriding procedure Finalize (Object : in out Buffer);
   overriding procedure Adjust (Object : in out Buffer);

   package No_Primitives is

      procedure Read (
         Stream : not null access Root_Stream_Type'Class;
         Object : out Buffer);
      procedure Write (
         Stream : not null access Root_Stream_Type'Class;
         Object : Buffer);

   end No_Primitives;

   for Buffer'Write use No_Primitives.Write;
   for Buffer'Read use No_Primitives.Read;

end Ada.Streams.Buffer_Storage_IO;
