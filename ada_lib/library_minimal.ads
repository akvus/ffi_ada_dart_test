-- Minimal Ada library interface without runtime dependencies
package Library_Minimal is
   pragma Pure;  -- No runtime dependencies
   
   function Add(A, B : Float) return Float
     with Export => True, Convention => C, External_Name => "ada_add_minimal";
   
   function Subtract(A, B : Float) return Float
     with Export => True, Convention => C, External_Name => "ada_subtract_minimal";
   
   function Multiply(A, B : Float) return Float
     with Export => True, Convention => C, External_Name => "ada_multiply_minimal";
   
   function Divide(A, B : Float) return Float
     with Export => True, Convention => C, External_Name => "ada_divide_minimal";

end Library_Minimal;