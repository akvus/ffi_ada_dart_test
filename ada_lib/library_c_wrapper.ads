package Library_C_Wrapper is
   
   -- C-compatible function declarations with Convention C
   function Add_C(A, B : Float) return Float
     with Export => True, Convention => C, External_Name => "ada_add";
   
   function Subtract_C(A, B : Float) return Float
     with Export => True, Convention => C, External_Name => "ada_subtract";
   
   function Multiply_C(A, B : Float) return Float
     with Export => True, Convention => C, External_Name => "ada_multiply";
   
   function Divide_C(A, B : Float) return Float
     with Export => True, Convention => C, External_Name => "ada_divide";
   
   function Square_Root_C(X : Float) return Float
     with Export => True, Convention => C, External_Name => "ada_sqrt";
   
   function Power_C(Base, Exponent : Float) return Float
     with Export => True, Convention => C, External_Name => "ada_power";
   
   function Absolute_Value_C(X : Float) return Float
     with Export => True, Convention => C, External_Name => "ada_abs";
   
   function Maximum_C(A, B : Float) return Float
     with Export => True, Convention => C, External_Name => "ada_max";
   
   function Minimum_C(A, B : Float) return Float
     with Export => True, Convention => C, External_Name => "ada_min";

end Library_C_Wrapper;