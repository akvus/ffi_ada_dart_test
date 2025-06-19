with Ada.Numerics.Elementary_Functions;

package Library is

   function Add(A, B : Float) return Float;
   function Subtract(A, B : Float) return Float;
   function Multiply(A, B : Float) return Float;
   function Divide(A, B : Float) return Float;
   function Square_Root(X : Float) return Float;
   function Power(Base, Exponent : Float) return Float;
   function Absolute_Value(X : Float) return Float;
   function Maximum(A, B : Float) return Float;
   function Minimum(A, B : Float) return Float;

end Library;