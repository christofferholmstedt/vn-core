with System;
with Ada.Text_IO;
with VN_Message;

package Central_Addressing_Service is

   package VN_Version_IO is new Ada.Text_IO.Modular_IO (VN_Message.VN_Version);

    task type CAS(Pri : System.Priority;
                        Cycle_Time : Positive;
                        Task_ID : Positive;
                        Increment_By : Positive) is
        pragma Priority(Pri);
    end CAS;

end Central_Addressing_Service;
