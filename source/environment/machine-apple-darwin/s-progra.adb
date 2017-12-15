with System.Zero_Terminated_Strings;
with C.mach_o.dyld;
with C.stdint;
package body System.Program is
   use type C.signed_int;
   use type C.stdint.uint32_t;

   function Full_Name return String is
      --  use proc_pidpath instead of NSGetExecutablePath?
      Buffer_Length : aliased C.stdint.uint32_t := 0;
      Small_Buffer : aliased C.char_array (0 .. 0);
      R : C.signed_int;
   begin
      --  getting the length at first
      R :=
         C.mach_o.dyld.NSGetExecutablePath (
            Small_Buffer (0)'Access,
            Buffer_Length'Access);
      pragma Assert (R < 0 and then Buffer_Length > 0);
      --  Buffer_Length is updated
      declare
         Buffer : aliased C.char_array (0 .. C.size_t (Buffer_Length - 1));
      begin
         R :=
            C.mach_o.dyld.NSGetExecutablePath (
               Buffer (0)'Access,
               Buffer_Length'Access);
         pragma Assert (not (R < 0));
         return Zero_Terminated_Strings.Value (
            Buffer (0)'Access,
            C.size_t (Buffer_Length - 1));
      end;
   end Full_Name;

end System.Program;
