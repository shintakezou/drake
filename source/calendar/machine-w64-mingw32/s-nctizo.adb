--  reference:
--  https://blogs.msdn.microsoft.com/oldnewthing/20140307-00/?p=1573
with Ada.Exception_Identification.From_Here;
with System.Native_Time;
with C.winbase;
with C.windef;
package body System.Native_Calendar.Time_Zones is
   use Ada.Exception_Identification.From_Here;
   use type System.Native_Time.Nanosecond_Number;
   use type C.windef.WINBOOL;

   --  Raymond Chen explains:
   --  SystemTimeToTzSpecificLocalTime uses the time zone in effect at the time
   --    being converted, whereas the FileTimeToLocalFileTime function uses the
   --    time zone in effect right now.

   function UTC_Time_Offset (Date : Time) return Time_Offset is
      Offset : System.Native_Time.Nanosecond_Number;
   begin
      declare
         File_Time : aliased constant C.windef.FILETIME :=
            To_Native_Time (Duration (Date));
         System_Time : aliased C.winbase.SYSTEMTIME;
         Local_System_Time : aliased C.winbase.SYSTEMTIME;
         Local_File_Time : aliased C.windef.FILETIME;
         Backed_File_Time : aliased C.windef.FILETIME;
      begin
         if not (
            C.winbase.FileTimeToSystemTime (
                  File_Time'Access,
                  System_Time'Access) /=
               C.windef.FALSE
            and then C.winbase.SystemTimeToTzSpecificLocalTime (
                  null,
                  System_Time'Access,
                  Local_System_Time'Access) /=
               C.windef.FALSE
            and then C.winbase.SystemTimeToFileTime (
                  Local_System_Time'Access,
                  Local_File_Time'Access) /=
               C.windef.FALSE
            and then C.winbase.SystemTimeToFileTime (
                  System_Time'Access,
                  Backed_File_Time'Access) /=
               C.windef.FALSE)
         then
            Raise_Exception (Time_Error'Identity);
         end if;
         --  Use Backed_File_Time instead of Date (or File_Time) because the
         --    unit of FILETIME is 100 nano-seconds but the unit of SYSTEMTIME
         --    is one milli-second.
         Offset :=
            System.Native_Time.Nanosecond_Number'Integer_Value (
               To_Time (Local_File_Time) - To_Time (Backed_File_Time));
      end;
      return Time_Offset (Offset / 60_000_000_000);
   end UTC_Time_Offset;

end System.Native_Calendar.Time_Zones;
