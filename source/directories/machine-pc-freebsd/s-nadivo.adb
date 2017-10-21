with Ada.Exception_Identification.From_Here;
with System.Native_Credentials;
with System.Zero_Terminated_Strings;
with C.errno;
with C.stdint;
package body System.Native_Directories.Volumes is
   use Ada.Exception_Identification.From_Here;
   use type File_Size;
   use type C.signed_int;
   use type C.size_t;
   use type C.stdint.uint32_t;

   --  implementation

   function Is_Assigned (FS : Non_Controlled_File_System) return Boolean is
   begin
      return FS.f_version /= 0;
   end Is_Assigned;

   procedure Get (
      Name : String;
      FS : aliased out Non_Controlled_File_System)
   is
      C_Name : C.char_array (
         0 ..
         Name'Length * Zero_Terminated_Strings.Expanding);
   begin
      Zero_Terminated_Strings.To_C (Name, C_Name (0)'Access);
      if C.sys.mount.statfs (C_Name (0)'Access, FS'Access) < 0 then
         Raise_Exception (Named_IO_Exception_Id (C.errno.errno));
      end if;
   end Get;

   function Size (FS : Non_Controlled_File_System) return File_Size is
   begin
      return File_Size (FS.f_blocks) * File_Size (FS.f_bsize);
   end Size;

   function Free_Space (FS : Non_Controlled_File_System) return File_Size is
   begin
      return File_Size (FS.f_bfree) * File_Size (FS.f_bsize);
   end Free_Space;

   function Owner (FS : Non_Controlled_File_System) return String is
   begin
      return Native_Credentials.User_Name (FS.f_owner);
   end Owner;

   function Format_Name (FS : Non_Controlled_File_System) return String is
   begin
      return Zero_Terminated_Strings.Value (FS.f_fstypename (0)'Access);
   end Format_Name;

   function Directory (FS : Non_Controlled_File_System) return String is
   begin
      return Zero_Terminated_Strings.Value (FS.f_mntonname (0)'Access);
   end Directory;

   function Device (FS : Non_Controlled_File_System) return String is
   begin
      return Zero_Terminated_Strings.Value (FS.f_mntfromname (0)'Access);
   end Device;

   function Identity (FS : Non_Controlled_File_System) return File_System_Id is
   begin
      return FS.f_fsid;
   end Identity;

   function Reference (Item : File_System)
      return not null access Non_Controlled_File_System is
   begin
      return Item.Data'Unrestricted_Access;
   end Reference;

end System.Native_Directories.Volumes;
