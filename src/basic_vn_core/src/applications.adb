package body Applications is

   function Get_Int return My_Int is
   begin
      return This_Int;
   end Get_Int;

   procedure Increment_Int is
   begin
      This_Int := This_Int + 1;
   end Increment_Int;

end Applications;
