with Library;

package body Library_C_Wrapper is

   function Add_C(A, B : Float) return Float is
   begin
      return Library.Add(A, B);
   end Add_C;

   function Subtract_C(A, B : Float) return Float is
   begin
      return Library.Subtract(A, B);
   end Subtract_C;

   function Multiply_C(A, B : Float) return Float is
   begin
      return Library.Multiply(A, B);
   end Multiply_C;

   function Divide_C(A, B : Float) return Float is
   begin
      return Library.Divide(A, B);
   end Divide_C;

   function Square_Root_C(X : Float) return Float is
   begin
      return Library.Square_Root(X);
   end Square_Root_C;

   function Power_C(Base, Exponent : Float) return Float is
   begin
      return Library.Power(Base, Exponent);
   end Power_C;

   function Absolute_Value_C(X : Float) return Float is
   begin
      return Library.Absolute_Value(X);
   end Absolute_Value_C;

   function Maximum_C(A, B : Float) return Float is
   begin
      return Library.Maximum(A, B);
   end Maximum_C;

   function Minimum_C(A, B : Float) return Float is
   begin
      return Library.Minimum(A, B);
   end Minimum_C;

end Library_C_Wrapper;