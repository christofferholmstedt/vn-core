with Ada.Real_Time;
with Ada.Text_IO;
with Application_Settings;
with VN_Message;

package body Central_Addressing_Service is

   task body CAS is
      use Ada.Real_Time;
      use Application_Settings;
      i: Integer := 1;
      Message: VN_Message.VN_Message_Basic;
      Status: VN_Message.Send_Status;
      Version: VN_Message.VN_Version;

      Next_Period : Ada.Real_Time.Time;
      Period : constant Ada.Real_Time.Time_Span :=
                           Ada.Real_Time.Microseconds(Cycle_Time);
   begin
      Ada.Text_IO.Put_Line("Task type CAS - Start, ID: "
                              & Integer'Image(Task_ID));

      Global_Start_Time.Get(Next_Period);
      loop
         delay until Next_Period;
         ----------------------------

         CAS_Communication.Send(Message, Status);
         Ada.Text_IO.Put("CAS Sent: ");
         Version := Message.Get_Version;
         VN_Version_IO.Put(Version);
         Ada.Text_IO.Put_Line("");
         Message.Set_Version(VN_Message.VN_Version(i + 1));

         ----------------------------
         Next_Period := Next_Period + Period;
         i := i + 1;
         exit when i = 6;
      end loop;
      Ada.Text_IO.Put_Line("Task type CAS - End, ID:"
                              & Integer'Image(Task_ID));
   end CAS;

   CAS1: CAS(20, 1000, 101, 3);

end Central_Addressing_Service;
