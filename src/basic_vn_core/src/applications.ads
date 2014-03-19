with Ada.Real_Time;
with System;

package Applications is

   -- Common start time for all applications.
   protected Global_Start_time is
      procedure Get(Time: out Ada.Real_Time.Time);
   private
      pragma Priority(System.Priority'Last);
      Start: Ada.Real_Time.Time;
      First_Time: Boolean := True;
   end Global_Start_Time;

end Applications;
