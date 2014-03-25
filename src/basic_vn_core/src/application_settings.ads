with Ada.Real_Time;
with System;
with Communication.IPC;
with Communication.PO;

package Application_Settings is

   -- Common start time for all applications.
   protected Global_Start_time is
      procedure Get(Time: out Ada.Real_Time.Time);

   private
      pragma Priority(System.Priority'Last);
      Start: Ada.Real_Time.Time;
      First_Time: Boolean := True;
   end Global_Start_Time;

   -- CAS to SM-L Protected Objects and wrappers.
   PO_CAS_SM_L: aliased Communication.PO.VN_PO;                             -- Step 1
   CAS_IPC_Wrapper: Communication.IPC.IPC_Wrapper(PO_CAS_SM_L'Access, false);  -- Step 2
   SM_L_IPC_Wrapper: Communication.IPC.IPC_Wrapper(PO_CAS_SM_L'Access, true);  -- Step 3

   -- CAS Communication
   CAS_Communication: Communication.IPC.IPC_Wrapper := CAS_IPC_Wrapper;

   -- SM-L Communication
   SM_L_Communication: Communication.IPC.IPC_Wrapper := SM_L_IPC_Wrapper;

end Application_Settings;
