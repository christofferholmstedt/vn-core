with Ada.Real_Time;
with Ada.Text_IO;
with Application_Settings;

package body Subnet_Manager_Local is

   task body SM_L is
      use Ada.Real_Time;
      use Application_Settings;
      i: Integer := 1;
      Message: VN.Message.VN_Message_Basic;
      Status: VN.Message.Receive_Status;
      Version: VN.Message.VN_Version;

      Next_Period : Ada.Real_Time.Time;
      Period : constant Ada.Real_Time.Time_Span :=
                           Ada.Real_Time.Microseconds(Cycle_Time);
   begin
      Ada.Text_IO.Put_Line("Task type SM_L - Start, ID: "
                              & Integer'Image(Task_ID));

      Global_Start_Time.Get(Next_Period);
      loop
         delay until Next_Period;
         ----------------------------

         SM_L_Communication.Receive(Message, Status);
         Version := Message.Get_Version;
         Ada.Text_IO.Put("SM_L Received: ");
         VN_Version_IO.Put(Version);
         Ada.Text_IO.Put_Line("");

         ----------------------------
         Next_Period := Next_Period + Period;
         i := i + 1;
         exit when i = 6;
      end loop;
      Ada.Text_IO.Put_Line("Task type SM_L - End, ID:"
                              & Integer'Image(Task_ID));
   end SM_L;

   SM_L1: SM_L(20, 2000, 80, 3);

end Subnet_Manager_Local;
