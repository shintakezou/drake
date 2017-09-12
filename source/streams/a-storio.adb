package body Ada.Storage_IO is
   use type System.Storage_Elements.Storage_Offset;

   procedure Read (Buffer : Buffer_Type; Item : out Element_Type) is
      subtype T is
         System.Storage_Elements.Storage_Array (
            1 ..
            (Item'Size + Standard'Storage_Unit - 1) / Standard'Storage_Unit);
      Item_As_T : T;
      for Item_As_T'Address use Item'Address;
   begin
      Item_As_T := Buffer (T'Range);
   end Read;

   procedure Write (Buffer : out Buffer_Type; Item : Element_Type) is
      subtype T is
         System.Storage_Elements.Storage_Array (
            1 ..
            (Item'Size + Standard'Storage_Unit - 1) / Standard'Storage_Unit);
      Item_As_T : T;
      for Item_As_T'Address use Item'Address;
   begin
      Buffer (T'Range) := Item_As_T;
   end Write;

end Ada.Storage_IO;
