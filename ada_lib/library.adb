package body Library is

   function Add(A, B : Float) return Float is
   begin
      return A + B;
   end Add;

   function Subtract(A, B : Float) return Float is
   begin
      return A - B;
   end Subtract;

   function Multiply(A, B : Float) return Float is
   begin
      return A * B;
   end Multiply;

   function Divide(A, B : Float) return Float is
   begin
      if B = 0.0 then
         raise Constraint_Error with "Division by zero";
      end if;
      return A / B;
   end Divide;

   function Square_Root(X : Float) return Float is
   begin
      if X < 0.0 then
         raise Constraint_Error with "Square root of negative number";
      end if;
      return Ada.Numerics.Elementary_Functions.Sqrt(X);
   end Square_Root;

   function Power(Base, Exponent : Float) return Float is
   begin
      return Ada.Numerics.Elementary_Functions."**"(Base, Exponent);
   end Power;

   function Absolute_Value(X : Float) return Float is
   begin
      return abs X;
   end Absolute_Value;

   function Maximum(A, B : Float) return Float is
   begin
      if A > B then
         return A;
      else
         return B;
      end if;
   end Maximum;

   function Minimum(A, B : Float) return Float is
   begin
      if A < B then
         return A;
      else
         return B;
      end if;
   end Minimum;

end Library;
