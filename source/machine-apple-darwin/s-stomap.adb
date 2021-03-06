with System.Address_To_Constant_Access_Conversions;
with C.mach_o.dyld;
with C.mach_o.loader;
package body System.Storage_Map is
   pragma Suppress (All_Checks);

   package mach_header_const_ptr_Conv is
      new Address_To_Constant_Access_Conversions (
         C.mach_o.loader.struct_mach_header,
         C.mach_o.loader.struct_mach_header_const_ptr);

   --  implementation

   function Load_Address return Address is
   begin
      return mach_header_const_ptr_Conv.To_Address (
         C.mach_o.dyld.dyld_get_image_header (0));
   end Load_Address;

end System.Storage_Map;
