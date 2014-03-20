with Ada.Real_Time;
with System;
with Communication.IPC;

package Application_Settings is

   -- Common start time for all applications.
   protected Global_Start_time is
      procedure Get(Time: out Ada.Real_Time.Time);
   private
      pragma Priority(System.Priority'Last);
      Start: Ada.Real_Time.Time;
      First_Time: Boolean := True;
   end Global_Start_Time;

   -- CAS to SM-L communication
   -- Inter-process Communication (IPC) is done with a wrapper around
   -- protected objects.
   IPC_From_CAS: Communication.IPC.Com_IPC;

end Application_Settings;
