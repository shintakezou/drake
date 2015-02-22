pragma License (Unrestricted);
--  implementation unit specialized for POSIX (Darwin, FreeBSD, or Linux)
with C.sys.time; -- struct timeval
with C.sys.types; -- time_t
with C.time; -- struct timespec
package System.Native_Time is
   pragma Preelaborate;

   --  representation

   type Nanosecond_Number is range
      -(2 ** (Duration'Size - 1)) ..
      +(2 ** (Duration'Size - 1)) - 1;
   for Nanosecond_Number'Size use Duration'Size;

   --  convert absolute time

   subtype Native_Time is C.time.struct_timespec;

   function To_Native_Time (T : Duration) return Native_Time;
   function To_Time (T : Native_Time) return Duration;
   function To_Time (T : C.sys.types.time_t) return Duration;

   pragma Pure_Function (To_Native_Time);
   pragma Pure_Function (To_Time);

   function To_Duration (D : C.sys.time.struct_timeval) return Duration;

   pragma Pure_Function (To_Duration);

   --  current absolute time

   function Clock return Native_Time;

   Tick : constant := 1.0 / 1000_000; -- gettimeofday returns timeval

   --  for delay

   procedure Simple_Delay_For (D : Duration);

   type Delay_For_Handler is access procedure (D : Duration);
   pragma Suppress (Access_Check, Delay_For_Handler);

   --  equivalent to Timed_Delay (s-soflin.ads)
   Delay_For_Hook : Delay_For_Handler := Simple_Delay_For'Access;
   pragma Suppress (Access_Check, Delay_For_Hook); -- not null

   procedure Delay_For (D : Duration);
   pragma Inline (Delay_For);

   --  for delay until

   procedure Simple_Delay_Until (T : Native_Time);

   type Delay_Until_Handler is access procedure (T : Native_Time);
   pragma Suppress (Access_Check, Delay_Until_Handler);

   --  equivalent to Timed_Delay (s-soflin.ads)
   Delay_Until_Hook : Delay_Until_Handler := Simple_Delay_Until'Access;
   pragma Suppress (Access_Check, Delay_Until_Hook); -- not null

   procedure Delay_Until (T : Native_Time);
   pragma Inline (Delay_Until);

   generic
      type Ada_Time is new Duration;
   procedure Generic_Delay_Until (T : Ada_Time);
   pragma Inline (Generic_Delay_Until);

end System.Native_Time;
