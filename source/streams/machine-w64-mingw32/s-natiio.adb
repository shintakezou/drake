with Ada.Exception_Identification.From_Here;
with System.Address_To_Named_Access_Conversions;
with System.Standard_Allocators;
with System.System_Allocators;
with C.basetsd;
with C.string;
with C.wincon;
with C.winerror;
package body System.Native_IO is
   use Ada.Exception_Identification.From_Here;
   use type Ada.IO_Modes.File_Shared;
   use type Ada.IO_Modes.File_Shared_Spec;
   use type Ada.Streams.Stream_Element_Offset;
   use type Storage_Elements.Storage_Offset;
   use type C.size_t;
   use type C.windef.DWORD;
   use type C.windef.UINT;
   use type C.windef.WINBOOL;
   use type C.winnt.ULONGLONG;

   package Name_Pointer_Conv is
      new Address_To_Named_Access_Conversions (Name_Character, Name_Pointer);

   Temp_Prefix : constant C.winnt.WCHAR_array (0 .. 3) := (
      C.winnt.WCHAR'Val (Wide_Character'Pos ('A')),
      C.winnt.WCHAR'Val (Wide_Character'Pos ('D')),
      C.winnt.WCHAR'Val (Wide_Character'Pos ('A')),
      C.winnt.WCHAR'Val (0));

   --  implementation

   procedure Free (Item : in out Name_Pointer) is
   begin
      Standard_Allocators.Free (Name_Pointer_Conv.To_Address (Item));
      Item := null;
   end Free;

   procedure New_External_Name (
      Item : String;
      Out_Item : aliased out Name_Pointer) is
   begin
      Out_Item := Name_Pointer_Conv.To_Pointer (
         Standard_Allocators.Allocate (
            (Item'Length * Zero_Terminated_WStrings.Expanding + 2) -- '*' & NUL
            * (C.winnt.WCHAR'Size / Standard'Storage_Unit)));
      declare
         pragma Suppress (Alignment_Check);
         Out_Item_A : Name_String (C.size_t);
         for Out_Item_A'Address use Name_Pointer_Conv.To_Address (Out_Item);
      begin
         Out_Item_A (0) := Name_Character'Val (Wide_Character'Pos ('*'));
         Zero_Terminated_WStrings.To_C (Item, Out_Item_A (1)'Access);
      end;
   end New_External_Name;

   procedure Open_Temporary (
      Handle : aliased out Handle_Type;
      Out_Item : aliased out Name_Pointer)
   is
      use type C.winnt.HANDLE;
      Temp_Dir : C.winnt.WCHAR_array (0 .. C.windef.MAX_PATH - 1);
      Temp_Name : C.winnt.WCHAR_array (0 .. C.windef.MAX_PATH - 1);
      Out_Length : C.size_t;
   begin
      --  compose template
      if C.winbase.GetTempPath (Temp_Dir'Length, Temp_Dir (0)'Access) = 0
         or else C.winbase.GetTempFileName (
            Temp_Dir (0)'Access,
            Temp_Prefix (0)'Access,
            0,
            Temp_Name (0)'Access) = 0
      then
         Raise_Exception (Use_Error'Identity);
      end if;
      --  open
      Handle := C.winbase.CreateFile (
         lpFileName => Temp_Name (0)'Access,
         dwDesiredAccess =>
            C.winnt.GENERIC_READ
            or C.winnt.GENERIC_WRITE, -- full access for Reset/Set_Mode
         dwShareMode =>
            C.winnt.FILE_SHARE_READ
            or C.winnt.FILE_SHARE_WRITE,
         lpSecurityAttributes => null,
         dwCreationDisposition => C.winbase.TRUNCATE_EXISTING,
         dwFlagsAndAttributes =>
            C.winnt.FILE_ATTRIBUTE_TEMPORARY
            or C.winbase.FILE_FLAG_DELETE_ON_CLOSE,
         hTemplateFile => C.winnt.HANDLE (Null_Address));
      if Handle = C.winbase.INVALID_HANDLE_VALUE then
         Raise_Exception (IO_Exception_Id (C.winbase.GetLastError));
      end if;
      --  allocate filename
      Out_Length := C.string.wcslen (Temp_Name (0)'Access);
      Out_Item := Name_Pointer_Conv.To_Pointer (
         Standard_Allocators.Allocate (
            (Storage_Elements.Storage_Offset (Out_Length) + 1) -- NUL
            * (C.winnt.WCHAR'Size / Standard'Storage_Unit)));
      declare
         pragma Suppress (Alignment_Check);
         Out_Item_A : C.winnt.WCHAR_array (C.size_t);
         for Out_Item_A'Address use Name_Pointer_Conv.To_Address (Out_Item);
      begin
         Out_Item_A (0 .. Out_Length) :=
            Temp_Name (0 .. Out_Length); -- including nul
      end;
   end Open_Temporary;

   procedure Open_Ordinary (
      Method : Open_Method;
      Handle : aliased out Handle_Type;
      Mode : Ada.IO_Modes.File_Mode;
      Name : not null Name_Pointer;
      Form : Packed_Form)
   is
      use type C.winnt.HANDLE;
      DesiredAccess : C.windef.DWORD;
      ShareMode : C.windef.DWORD;
      CreationDisposition : C.windef.DWORD;
      Shared : Ada.IO_Modes.File_Shared;
      Error : C.windef.DWORD;
   begin
      --  Flags, Append_File always has read and write access for Inout_File
      if Form.Shared /= Ada.IO_Modes.By_Mode then
         Shared := Ada.IO_Modes.File_Shared (Form.Shared);
      else
         case Mode is
            when Ada.IO_Modes.In_File =>
               Shared := Ada.IO_Modes.Read_Only;
            when Ada.IO_Modes.Out_File | Ada.IO_Modes.Append_File =>
               Shared := Ada.IO_Modes.Deny;
         end case;
      end if;
      case Method is
         when Create =>
            declare
               use Ada.IO_Modes;
               use C.winbase, C.winnt;
               Access_Modes : constant array (File_Mode) of C.windef.DWORD := (
                  In_File => GENERIC_READ or GENERIC_WRITE,
                  Out_File => GENERIC_WRITE,
                  Append_File => GENERIC_READ or GENERIC_WRITE);
               Creations : constant array (File_Mode) of C.windef.DWORD := (
                  In_File => CREATE_ALWAYS,
                  Out_File => CREATE_ALWAYS,
                  Append_File => OPEN_ALWAYS); -- no truncation
            begin
               DesiredAccess := Access_Modes (Mode);
               Shared := Ada.IO_Modes.Deny;
               if Form.Overwrite then
                  CreationDisposition := Creations (Mode);
               else
                  CreationDisposition := CREATE_NEW;
               end if;
            end;
         when Open =>
            declare
               use Ada.IO_Modes;
               use C.winbase, C.winnt;
               Access_Modes : constant array (File_Mode) of C.windef.DWORD := (
                  In_File => GENERIC_READ,
                  Out_File => GENERIC_WRITE,
                  Append_File => GENERIC_READ or GENERIC_WRITE);
               Creations : constant array (File_Mode) of C.windef.DWORD := (
                  In_File => OPEN_EXISTING,
                  Out_File => TRUNCATE_EXISTING,
                  Append_File => OPEN_EXISTING);
            begin
               DesiredAccess := Access_Modes (Mode);
               CreationDisposition := Creations (Mode);
            end;
         when Reset =>
            declare
               use Ada.IO_Modes;
               use C.winbase, C.winnt;
               Access_Modes : constant array (File_Mode) of C.windef.DWORD := (
                  In_File => GENERIC_READ,
                  Out_File => GENERIC_WRITE,
                  Append_File => GENERIC_READ or GENERIC_WRITE);
            begin
               DesiredAccess := Access_Modes (Mode);
               CreationDisposition := OPEN_EXISTING; -- no truncation
            end;
      end case;
      if Shared /= Ada.IO_Modes.Allow then
         if Form.Wait then
            --  use LockFileEx
            ShareMode := C.winnt.FILE_SHARE_READ or C.winnt.FILE_SHARE_WRITE;
         else
            declare
               Lock_Flags : constant array (
                  Ada.IO_Modes.File_Shared'(Ada.IO_Modes.Read_Only) ..
                  Ada.IO_Modes.Deny) of C.windef.DWORD := (
                     Ada.IO_Modes.Read_Only => C.winnt.FILE_SHARE_READ,
                     Ada.IO_Modes.Deny => 0);
            begin
               ShareMode := Lock_Flags (Shared);
            end;
         end if;
      else
         ShareMode := C.winnt.FILE_SHARE_READ or C.winnt.FILE_SHARE_WRITE;
      end if;
      --  open
      Handle := C.winbase.CreateFile (
         lpFileName => Name,
         dwDesiredAccess => DesiredAccess,
         dwShareMode => ShareMode,
         lpSecurityAttributes => null,
         dwCreationDisposition => CreationDisposition,
         dwFlagsAndAttributes => C.winnt.FILE_ATTRIBUTE_NORMAL,
         hTemplateFile => C.winnt.HANDLE (Null_Address));
      if Handle = C.winbase.INVALID_HANDLE_VALUE then
         Error := C.winbase.GetLastError;
         case Error is
            when C.winerror.ERROR_FILE_NOT_FOUND
               | C.winerror.ERROR_PATH_NOT_FOUND
               | C.winerror.ERROR_FILE_EXISTS -- CREATE_NEW
               | C.winerror.ERROR_INVALID_NAME
               | C.winerror.ERROR_ALREADY_EXISTS =>
               Raise_Exception (Name_Error'Identity);
            when C.winerror.ERROR_SHARING_VIOLATION =>
               Raise_Exception (Tasking_Error'Identity);
               --  Is Tasking_Error suitable?
            when others =>
               Raise_Exception (IO_Exception_Id (Error));
         end case;
      end if;
      if Shared /= Ada.IO_Modes.Allow and then Form.Wait then
         declare
            Flags : constant array (
               Ada.IO_Modes.File_Shared'(Ada.IO_Modes.Read_Only) ..
               Ada.IO_Modes.Deny) of C.windef.DWORD := (
                  Ada.IO_Modes.Read_Only => 0,
                  Ada.IO_Modes.Deny => C.winbase.LOCKFILE_EXCLUSIVE_LOCK);
            Overlapped : aliased C.winbase.OVERLAPPED :=
               (0, 0, (0, 0, 0), C.winnt.HANDLE (Null_Address));
         begin
            if C.winbase.LockFileEx (
               hFile => Handle,
               dwFlags => Flags (Shared),
               dwReserved => 0,
               nNumberOfBytesToLockLow => C.windef.DWORD'Last,
               nNumberOfBytesToLockHigh => C.windef.DWORD'Last,
               lpOverlapped => Overlapped'Access) = 0
            then
               Raise_Exception (Tasking_Error'Identity);
               --  Is Tasking_Error suitable?
            end if;
         end;
      end if;
   end Open_Ordinary;

   procedure Close_Ordinary (
      Handle : Handle_Type;
      Name : Name_Pointer;
      Raise_On_Error : Boolean)
   is
      pragma Unreferenced (Name);
      Error : Boolean;
   begin
      Error := C.winbase.CloseHandle (Handle) = 0;
      if Error and then Raise_On_Error then
         Raise_Exception (IO_Exception_Id (C.winbase.GetLastError));
      end if;
   end Close_Ordinary;

   procedure Delete_Ordinary (
      Handle : Handle_Type;
      Name : Name_Pointer;
      Raise_On_Error : Boolean)
   is
      Error : Boolean;
   begin
      Error := C.winbase.CloseHandle (Handle) = 0;
      if not Error then
         Error := C.winbase.DeleteFile (Name) = 0;
      end if;
      if Error and then Raise_On_Error then
         Raise_Exception (IO_Exception_Id (C.winbase.GetLastError));
      end if;
   end Delete_Ordinary;

   function Is_Terminal (Handle : Handle_Type) return Boolean is
      Mode : aliased C.windef.DWORD;
   begin
      return C.winbase.GetFileType (Handle) = C.winbase.FILE_TYPE_CHAR
         and then C.wincon.GetConsoleMode (Handle, Mode'Access) /= 0;
   end Is_Terminal;

   function Is_Seekable (Handle : Handle_Type) return Boolean is
   begin
      return C.winbase.SetFilePointerEx (
         Handle,
         (Unchecked_Tag => 2, QuadPart => 0),
         null,
         C.winbase.FILE_CURRENT) /= 0;
   end Is_Seekable;

   function Block_Size (Handle : Handle_Type)
      return Ada.Streams.Stream_Element_Count
   is
      File_Type : C.windef.DWORD;
      Result : Ada.Streams.Stream_Element_Count;
   begin
      File_Type := C.winbase.GetFileType (Handle);
      if File_Type /= C.winbase.FILE_TYPE_DISK then
         --  no buffering for terminal, pipe and unknown device
         Result := 0;
      else
         --  disk file
         Result := Ada.Streams.Stream_Element_Offset (
            System_Allocators.Page_Size);
      end if;
      return Result;
   end Block_Size;

   procedure Read (
      Handle : Handle_Type;
      Item : Address;
      Length : Ada.Streams.Stream_Element_Offset;
      Out_Length : out Ada.Streams.Stream_Element_Offset)
   is
      Read_Size : aliased C.windef.DWORD;
      ReadFile_Result : C.windef.WINBOOL;
   begin
      ReadFile_Result := C.winbase.ReadFile (
         Handle,
         C.windef.LPVOID (Item),
         C.windef.DWORD (Length),
         Read_Size'Access,
         lpOverlapped => null);
      Out_Length := Ada.Streams.Stream_Element_Offset (Read_Size);
      if ReadFile_Result = 0 then
         case C.winbase.GetLastError is
            when C.winerror.ERROR_BROKEN_PIPE
               | C.winerror.ERROR_NO_DATA =>
               --  closed pipe
               --  this subprogram is called from End_Of_File
               --  because no buffering on pipe
               Out_Length := 0;
            when others =>
               Out_Length := -1;
         end case;
      end if;
   end Read;

   procedure Write (
      Handle : Handle_Type;
      Item : Address;
      Length : Ada.Streams.Stream_Element_Offset;
      Out_Length : out Ada.Streams.Stream_Element_Offset)
   is
      Written_Size : aliased C.windef.DWORD;
      WriteFile_Result : C.windef.WINBOOL;
   begin
      WriteFile_Result := C.winbase.WriteFile (
         Handle,
         C.windef.LPCVOID (Item),
         C.windef.DWORD (Length),
         Written_Size'Access,
         lpOverlapped => null);
      Out_Length := Ada.Streams.Stream_Element_Offset (Written_Size);
      if WriteFile_Result = 0 then
         case C.winbase.GetLastError is
            when C.winerror.ERROR_BROKEN_PIPE
               | C.winerror.ERROR_NO_DATA =>
               Out_Length := 0;
            when others =>
               Out_Length := -1;
         end case;
      end if;
   end Write;

   procedure Flush (Handle : Handle_Type) is
   begin
      if C.winbase.FlushFileBuffers (Handle) = 0 then
         case C.winbase.GetLastError is
            when C.winerror.ERROR_INVALID_HANDLE =>
               null; -- means fd is not file but terminal, pipe, etc
            when others =>
               Raise_Exception (Device_Error'Identity);
         end case;
      end if;
   end Flush;

   procedure Set_Relative_Index (
      Handle : Handle_Type;
      Relative_To : Ada.Streams.Stream_Element_Offset;
      Whence : Whence_Type;
      New_Index : out Ada.Streams.Stream_Element_Offset)
   is
      liDistanceToMove : C.winnt.LARGE_INTEGER;
      liNewFilePointer : aliased C.winnt.LARGE_INTEGER;
   begin
      liDistanceToMove.QuadPart := C.winnt.LONGLONG (Relative_To);
      if C.winbase.SetFilePointerEx (
         Handle,
         liDistanceToMove,
         liNewFilePointer'Access,
         Whence) = 0
      then
         Raise_Exception (IO_Exception_Id (C.winbase.GetLastError));
      end if;
      New_Index :=
         Ada.Streams.Stream_Element_Offset (liNewFilePointer.QuadPart) + 1;
   end Set_Relative_Index;

   function Index (Handle : Handle_Type)
      return Ada.Streams.Stream_Element_Offset
   is
      liDistanceToMove : C.winnt.LARGE_INTEGER;
      liNewFilePointer : aliased C.winnt.LARGE_INTEGER;
   begin
      liDistanceToMove.QuadPart := 0;
      if C.winbase.SetFilePointerEx (
         Handle,
         liDistanceToMove,
         liNewFilePointer'Access,
         C.winbase.FILE_CURRENT) = 0
      then
         Raise_Exception (IO_Exception_Id (C.winbase.GetLastError));
      end if;
      return Ada.Streams.Stream_Element_Offset (liNewFilePointer.QuadPart) + 1;
   end Index;

   function Size (Handle : Handle_Type)
      return Ada.Streams.Stream_Element_Count
   is
      liFileSize : aliased C.winnt.LARGE_INTEGER;
   begin
      if C.winbase.GetFileSizeEx (Handle, liFileSize'Access) = 0 then
         Raise_Exception (IO_Exception_Id (C.winbase.GetLastError));
      end if;
      return Ada.Streams.Stream_Element_Offset (liFileSize.QuadPart);
   end Size;

   function Standard_Input return Handle_Type is
   begin
      return C.winbase.GetStdHandle (C.winbase.STD_INPUT_HANDLE);
   end Standard_Input;

   function Standard_Output return Handle_Type is
   begin
      return C.winbase.GetStdHandle (C.winbase.STD_OUTPUT_HANDLE);
   end Standard_Output;

   function Standard_Error return Handle_Type is
   begin
      return C.winbase.GetStdHandle (C.winbase.STD_ERROR_HANDLE);
   end Standard_Error;

   procedure Initialize (
      Standard_Input_Handle : aliased in out Handle_Type;
      Standard_Output_Handle : aliased in out Handle_Type;
      Standard_Error_Handle : aliased in out Handle_Type) is
   begin
      Standard_Input_Handle := Standard_Input;
      Standard_Output_Handle := Standard_Output;
      Standard_Error_Handle := Standard_Error;
   end Initialize;

   procedure Open_Pipe (
      Reading_Handle : aliased out Handle_Type;
      Writing_Handle : aliased out Handle_Type) is
   begin
      if C.winbase.CreatePipe (
         Reading_Handle'Access,
         Writing_Handle'Access,
         null,
         0) = 0
      then
         Raise_Exception (Use_Error'Identity);
      end if;
   end Open_Pipe;

   procedure Map (
      Mapping : out Mapping_Type;
      Handle : Handle_Type;
      Offset : Ada.Streams.Stream_Element_Offset; -- 1-origin
      Size : Ada.Streams.Stream_Element_Count;
      Writable : Boolean)
   is
      use type C.winnt.HANDLE;
      Protects : constant array (Boolean) of C.windef.DWORD :=
         (C.winnt.PAGE_READONLY, C.winnt.PAGE_READWRITE);
      Accesses : constant array (Boolean) of C.windef.DWORD :=
         (C.winbase.FILE_MAP_READ, C.winbase.FILE_MAP_WRITE);
      Mapped_Offset : C.winnt.ULARGE_INTEGER;
      Mapped_Size : C.winnt.ULARGE_INTEGER;
      Mapped_Address : C.windef.LPVOID;
      File_Mapping : C.winnt.HANDLE;
   begin
      Mapped_Offset.QuadPart := C.winnt.ULONGLONG (Offset) - 1;
      Mapped_Size.QuadPart := C.winnt.ULONGLONG (Size);
      File_Mapping := C.winbase.CreateFileMapping (
         Handle,
         null,
         Protects (Writable),
         Mapped_Size.HighPart,
         Mapped_Size.LowPart,
         null);
      if File_Mapping = C.winbase.INVALID_HANDLE_VALUE then
         Raise_Exception (Use_Error'Identity);
      end if;
      Mapped_Address := C.winbase.MapViewOfFileEx (
         File_Mapping,
         Accesses (Writable),
         Mapped_Offset.HighPart,
         Mapped_Offset.LowPart,
         C.basetsd.SIZE_T (Mapped_Size.QuadPart),
         C.windef.LPVOID (Null_Address));
      if Address (Mapped_Address) = Null_Address then
         if C.winbase.CloseHandle (File_Mapping) = 0 then
            null; -- raise Use_Error;
         end if;
         Raise_Exception (Use_Error'Identity);
      end if;
      Mapping.Storage_Address := Address (Mapped_Address);
      Mapping.Storage_Size := Storage_Elements.Storage_Offset (Size);
      Mapping.File_Mapping := File_Mapping;
   end Map;

   procedure Unmap (
      Mapping : in out Mapping_Type;
      Raise_On_Error : Boolean) is
   begin
      if C.winbase.UnmapViewOfFile (
            C.windef.LPCVOID (Mapping.Storage_Address)) = 0
         or else C.winbase.CloseHandle (Mapping.File_Mapping) = 0
      then
         if Raise_On_Error then
            Raise_Exception (Use_Error'Identity);
         end if;
      end if;
      Mapping.Storage_Address := Null_Address;
      Mapping.Storage_Size := 0;
   end Unmap;

   function IO_Exception_Id (Error : C.windef.DWORD)
      return Ada.Exception_Identification.Exception_Id is
   begin
      case Error is
         when C.winerror.ERROR_WRITE_FAULT
            | C.winerror.ERROR_READ_FAULT
            | C.winerror.ERROR_GEN_FAILURE
            | C.winerror.ERROR_IO_DEVICE =>
            return Device_Error'Identity;
         when others =>
            return Use_Error'Identity;
      end case;
   end IO_Exception_Id;

end System.Native_IO;
