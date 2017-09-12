pragma License (Unrestricted);
--  implementation unit specialized for Windows
with C.windef;
package System.Native_Time is
   pragma Preelaborate;

   --  representation

   type Nanosecond_Number is
      range -(2 ** (Duration'Size - 1)) .. 2 ** (Duration'Size - 1) - 1;
   for Nanosecond_Number'Size use Duration'Size;

   --  convert time span

   function To_Duration (D : C.windef.FILETIME) return Duration;
   pragma Pure_Function (To_Duration);

   --  for delay

   procedure Simple_Delay_For (D : Duration);

   type Delay_For_Handler is access procedure (D : Duration);
   pragma Favor_Top_Level (Delay_For_Handler);

   --  equivalent to Timed_Delay (s-soflin.ads)
   Delay_For_Hook : not null Delay_For_Handler := Simple_Delay_For'Access;

   procedure Delay_For (D : Duration);

end System.Native_Time;
