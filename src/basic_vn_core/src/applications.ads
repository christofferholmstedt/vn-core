package Applications is

   type My_Int is mod 2 ** 3;

   function Get_Int return My_Int;
   procedure Increment_Int;

private
   This_Int: My_Int := 1;

end Applications;
