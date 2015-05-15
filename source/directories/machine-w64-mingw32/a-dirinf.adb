with Ada.Directories.Inside;
with Ada.Exception_Identification.From_Here;
with Ada.Unchecked_Conversion;
with System.Native_Calendar;
with System.Zero_Terminated_WStrings;
with C.winbase;
with C.winnt;
package body Ada.Directories.Information is
   use Exception_Identification.From_Here;
   use type Exception_Identification.Exception_Id;
   use type C.size_t;
   use type C.windef.DWORD;
   use type C.windef.WINBOOL;
   use type C.winnt.HANDLE; -- C.void_ptr

   function IO_Exception_Id (errno : C.windef.DWORD)
      return Exception_Identification.Exception_Id
      renames System.Directory_Searching.IO_Exception_Id;

   function Named_IO_Exception_Id (errno : C.windef.DWORD)
      return Exception_Identification.Exception_Id
      renames System.Directory_Searching.Named_IO_Exception_Id;

   function Cast is new Unchecked_Conversion (Duration, Calendar.Time);

   --  implementation

   function Creation_Time (Name : String) return Calendar.Time is
      Information : aliased Inside.Directory_Entry_Information_Type;
   begin
      Inside.Get_Information (Name, Information);
      return Cast (System.Native_Calendar.To_Time (
         Information.ftCreationTime));
   end Creation_Time;

   function Creation_Time (Directory_Entry : Directory_Entry_Type)
      return Calendar.Time
   is
      NC_Directory_Entry : constant
         not null access Non_Controlled_Directory_Entry_Type :=
         Reference (Directory_Entry);
   begin
      if NC_Directory_Entry.Status = Empty then
         Raise_Exception (Status_Error'Identity);
      end if;
      return Cast (System.Native_Calendar.To_Time (
         NC_Directory_Entry.Directory_Entry.ftLastWriteTime));
   end Creation_Time;

   function Last_Access_Time (Name : String) return Calendar.Time is
      Information : aliased Inside.Directory_Entry_Information_Type;
   begin
      Inside.Get_Information (Name, Information);
      return Cast (System.Native_Calendar.To_Time (
         Information.ftLastAccessTime));
   end Last_Access_Time;

   function Last_Access_Time (Directory_Entry : Directory_Entry_Type)
      return Calendar.Time
   is
      NC_Directory_Entry : constant
         not null access Non_Controlled_Directory_Entry_Type :=
         Reference (Directory_Entry);
   begin
      if NC_Directory_Entry.Status = Empty then
         Raise_Exception (Status_Error'Identity);
      end if;
      return Cast (System.Native_Calendar.To_Time (
         NC_Directory_Entry.Directory_Entry.ftLastAccessTime));
   end Last_Access_Time;

   function Is_Read_Only (Name : String) return Boolean is
      Information : aliased Inside.Directory_Entry_Information_Type;
   begin
      Inside.Get_Information (Name, Information);
      return (Information.dwFileAttributes
         and C.winnt.FILE_ATTRIBUTE_SPARSE_FILE) /= 0;
   end Is_Read_Only;

   function Is_Read_Only (Directory_Entry : Directory_Entry_Type)
      return Boolean
   is
      NC_Directory_Entry : constant
         not null access Non_Controlled_Directory_Entry_Type :=
         Reference (Directory_Entry);
   begin
      if NC_Directory_Entry.Status = Empty then
         Raise_Exception (Status_Error'Identity);
      end if;
      return (NC_Directory_Entry.Directory_Entry.dwFileAttributes
         and C.winnt.FILE_ATTRIBUTE_READONLY) /= 0;
   end Is_Read_Only;

   function Needs_Archiving (Name : String) return Boolean is
      Information : aliased Inside.Directory_Entry_Information_Type;
   begin
      Inside.Get_Information (Name, Information);
      return (Information.dwFileAttributes
         and C.winnt.FILE_ATTRIBUTE_ARCHIVE) /= 0;
   end Needs_Archiving;

   function Needs_Archiving (Directory_Entry : Directory_Entry_Type)
      return Boolean
   is
      NC_Directory_Entry : constant
         not null access Non_Controlled_Directory_Entry_Type :=
         Reference (Directory_Entry);
   begin
      if NC_Directory_Entry.Status = Empty then
         Raise_Exception (Status_Error'Identity);
      end if;
      return (NC_Directory_Entry.Directory_Entry.dwFileAttributes
         and C.winnt.FILE_ATTRIBUTE_ARCHIVE) /= 0;
   end Needs_Archiving;

   function Is_Compressed (Name : String) return Boolean is
      Information : aliased Inside.Directory_Entry_Information_Type;
   begin
      Inside.Get_Information (Name, Information);
      return (Information.dwFileAttributes
         and C.winnt.FILE_ATTRIBUTE_COMPRESSED) /= 0;
   end Is_Compressed;

   function Is_Compressed (Directory_Entry : Directory_Entry_Type)
      return Boolean
   is
      NC_Directory_Entry : constant
         not null access Non_Controlled_Directory_Entry_Type :=
         Reference (Directory_Entry);
   begin
      if NC_Directory_Entry.Status = Empty then
         Raise_Exception (Status_Error'Identity);
      end if;
      return (NC_Directory_Entry.Directory_Entry.dwFileAttributes
         and C.winnt.FILE_ATTRIBUTE_COMPRESSED) /= 0;
   end Is_Compressed;

   function Is_Encrypted (Name : String) return Boolean is
      Information : aliased Inside.Directory_Entry_Information_Type;
   begin
      Inside.Get_Information (Name, Information);
      return (Information.dwFileAttributes
         and C.winnt.FILE_ATTRIBUTE_ENCRYPTED) /= 0;
   end Is_Encrypted;

   function Is_Encrypted (Directory_Entry : Directory_Entry_Type)
      return Boolean
   is
      NC_Directory_Entry : constant
         not null access Non_Controlled_Directory_Entry_Type :=
         Reference (Directory_Entry);
   begin
      if NC_Directory_Entry.Status = Empty then
         Raise_Exception (Status_Error'Identity);
      end if;
      return (NC_Directory_Entry.Directory_Entry.dwFileAttributes
         and C.winnt.FILE_ATTRIBUTE_ENCRYPTED) /= 0;
   end Is_Encrypted;

   function Is_Hidden (Name : String) return Boolean is
      Information : aliased Inside.Directory_Entry_Information_Type;
   begin
      Inside.Get_Information (Name, Information);
      return (Information.dwFileAttributes
         and C.winnt.FILE_ATTRIBUTE_HIDDEN) /= 0;
   end Is_Hidden;

   function Is_Hidden (Directory_Entry : Directory_Entry_Type)
      return Boolean
   is
      NC_Directory_Entry : constant
         not null access Non_Controlled_Directory_Entry_Type :=
         Reference (Directory_Entry);
   begin
      if NC_Directory_Entry.Status = Empty then
         Raise_Exception (Status_Error'Identity);
      end if;
      return (NC_Directory_Entry.Directory_Entry.dwFileAttributes
         and C.winnt.FILE_ATTRIBUTE_HIDDEN) /= 0;
   end Is_Hidden;

   function Is_System (Name : String) return Boolean is
      Information : aliased Inside.Directory_Entry_Information_Type;
   begin
      Inside.Get_Information (Name, Information);
      return (Information.dwFileAttributes
         and C.winnt.FILE_ATTRIBUTE_SYSTEM) /= 0;
   end Is_System;

   function Is_System (Directory_Entry : Directory_Entry_Type)
      return Boolean
   is
      NC_Directory_Entry : constant
         not null access Non_Controlled_Directory_Entry_Type :=
         Reference (Directory_Entry);
   begin
      if NC_Directory_Entry.Status = Empty then
         Raise_Exception (Status_Error'Identity);
      end if;
      return (NC_Directory_Entry.Directory_Entry.dwFileAttributes
         and C.winnt.FILE_ATTRIBUTE_SYSTEM) /= 0;
   end Is_System;

   function Is_Offline (Name : String) return Boolean is
      Information : aliased Inside.Directory_Entry_Information_Type;
   begin
      Inside.Get_Information (Name, Information);
      return (Information.dwFileAttributes
         and C.winnt.FILE_ATTRIBUTE_OFFLINE) /= 0;
   end Is_Offline;

   function Is_Offline (Directory_Entry : Directory_Entry_Type)
      return Boolean
   is
      NC_Directory_Entry : constant
         not null access Non_Controlled_Directory_Entry_Type :=
         Reference (Directory_Entry);
   begin
      if NC_Directory_Entry.Status = Empty then
         Raise_Exception (Status_Error'Identity);
      end if;
      return (NC_Directory_Entry.Directory_Entry.dwFileAttributes
         and C.winnt.FILE_ATTRIBUTE_OFFLINE) /= 0;
   end Is_Offline;

   function Is_Temporary (Name : String) return Boolean is
      Information : aliased Inside.Directory_Entry_Information_Type;
   begin
      Inside.Get_Information (Name, Information);
      return (Information.dwFileAttributes
         and C.winnt.FILE_ATTRIBUTE_TEMPORARY) /= 0;
   end Is_Temporary;

   function Is_Temporary (Directory_Entry : Directory_Entry_Type)
      return Boolean
   is
      NC_Directory_Entry : constant
         not null access Non_Controlled_Directory_Entry_Type :=
         Reference (Directory_Entry);
   begin
      if NC_Directory_Entry.Status = Empty then
         Raise_Exception (Status_Error'Identity);
      end if;
      return (NC_Directory_Entry.Directory_Entry.dwFileAttributes
         and C.winnt.FILE_ATTRIBUTE_TEMPORARY) /= 0;
   end Is_Temporary;

   function Is_Sparse (Name : String) return Boolean is
      Information : aliased Inside.Directory_Entry_Information_Type;
   begin
      Inside.Get_Information (Name, Information);
      return (Information.dwFileAttributes
         and C.winnt.FILE_ATTRIBUTE_SPARSE_FILE) /= 0;
   end Is_Sparse;

   function Is_Sparse (Directory_Entry : Directory_Entry_Type)
      return Boolean
   is
      NC_Directory_Entry : constant
         not null access Non_Controlled_Directory_Entry_Type :=
         Reference (Directory_Entry);
   begin
      if NC_Directory_Entry.Status = Empty then
         Raise_Exception (Status_Error'Identity);
      end if;
      return (NC_Directory_Entry.Directory_Entry.dwFileAttributes
         and C.winnt.FILE_ATTRIBUTE_SPARSE_FILE) /= 0;
   end Is_Sparse;

   function Is_Not_Indexed (Name : String) return Boolean is
      Information : aliased Inside.Directory_Entry_Information_Type;
   begin
      Inside.Get_Information (Name, Information);
      return (Information.dwFileAttributes
         and C.winnt.FILE_ATTRIBUTE_NOT_CONTENT_INDEXED) /= 0;
   end Is_Not_Indexed;

   function Is_Not_Indexed (Directory_Entry : Directory_Entry_Type)
      return Boolean
   is
      NC_Directory_Entry : constant
         not null access Non_Controlled_Directory_Entry_Type :=
         Reference (Directory_Entry);
   begin
      if NC_Directory_Entry.Status = Empty then
         Raise_Exception (Status_Error'Identity);
      end if;
      return (NC_Directory_Entry.Directory_Entry.dwFileAttributes
         and C.winnt.FILE_ATTRIBUTE_NOT_CONTENT_INDEXED) /= 0;
   end Is_Not_Indexed;

   function Identity (Name : String) return File_Id is
      Exception_Id : Exception_Identification.Exception_Id :=
         Exception_Identification.Null_Id;
      W_Name : aliased C.winnt.WCHAR_array (
         0 ..
         Name'Length * System.Zero_Terminated_WStrings.Expanding);
      Handle : C.winnt.HANDLE;
      Info : aliased C.winbase.BY_HANDLE_FILE_INFORMATION;
   begin
      System.Zero_Terminated_WStrings.To_C (Name, W_Name (0)'Access);
      Handle := C.winbase.CreateFile (
         W_Name (0)'Access,
         dwDesiredAccess => 0,
         dwShareMode => C.winnt.FILE_SHARE_READ or C.winnt.FILE_SHARE_WRITE
            or C.winnt.FILE_SHARE_DELETE, -- only for query
         lpSecurityAttributes => null,
         dwCreationDisposition => C.winbase.OPEN_EXISTING,
         dwFlagsAndAttributes => C.winbase.FILE_FLAG_BACKUP_SEMANTICS
            or C.winbase.FILE_FLAG_OPEN_REPARSE_POINT,
         hTemplateFile => C.windef.LPVOID (System.Null_Address));
      if Handle = C.winbase.INVALID_HANDLE_VALUE then
         Exception_Id := Named_IO_Exception_Id (C.winbase.GetLastError);
      else
         if C.winbase.GetFileInformationByHandle (Handle, Info'Access) = 0 then
            Exception_Id := IO_Exception_Id (C.winbase.GetLastError);
         end if;
         if C.winbase.CloseHandle (Handle) = 0 then
            if Exception_Id = Exception_Identification.Null_Id then
               Exception_Id := IO_Exception_Id (C.winbase.GetLastError);
            end if;
         end if;
      end if;
      if Exception_Id /= Exception_Identification.Null_Id then
         Raise_Exception (Exception_Id);
      end if;
      return (
         FileIndexLow => Info.nFileIndexLow,
         FileIndexHigh => Info.nFileIndexHigh,
         VolumeSerialNumber => Info.dwVolumeSerialNumber);
   end Identity;

   function Identity (Directory_Entry : Directory_Entry_Type) return File_Id is
   begin
      --  WIN32_FILE_ATTRIBUTE_DATA does not contain the file index
      return Identity (Full_Name (Directory_Entry));
   end Identity;

end Ada.Directories.Information;
