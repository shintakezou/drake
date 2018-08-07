with Ada.Exception_Identification.From_Here;
with System.Native_Calendar;
with C.time;
package body System.Native_Calendar.Time_Zones is
   use Ada.Exception_Identification.From_Here;
   use type C.signed_long; -- tm_gmtoff

   function UTC_Time_Offset (Date : Time) return Time_Offset is
      --  FreeBSD does not have timezone variable
      GMT_Time : aliased constant Native_Time :=
         To_Native_Time (Duration (Date));
      Local_TM_Buf : aliased C.time.struct_tm;
      Local_TM : access C.time.struct_tm;
   begin
      Local_TM := C.time.localtime_r (
         GMT_Time.tv_sec'Access,
         Local_TM_Buf'Access);
      if Local_TM = null then
         Raise_Exception (Time_Error'Identity);
      end if;
      return Time_Offset (Local_TM.tm_gmtoff / 60);
   end UTC_Time_Offset;

begin
   C.time.tzset;
end System.Native_Calendar.Time_Zones;
