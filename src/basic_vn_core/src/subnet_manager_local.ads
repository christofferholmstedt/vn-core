with VN_Message;
with System;
with Ada.Text_IO;

package Subnet_Manager_Local is

   package VN_Version_IO is new Ada.Text_IO.Modular_IO (VN_Message.VN_Version);

   task type SM_L(Pri : System.Priority;
                     Cycle_Time : Positive;
                     Task_ID : Positive;
                     Increment_By : Positive) is
      pragma Priority(Pri);
   end SM_L;

end Subnet_Manager_Local;
