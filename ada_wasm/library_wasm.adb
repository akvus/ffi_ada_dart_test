package body Library_WASM is

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
      -- For WASM, we return a special value instead of raising exception
      if B = 0.0 then
         return Float'First; -- Indicates error condition
      end if;
      return A / B;
   end Divide;

   function Square_Root(X : Float) return Float is
   begin
      -- For WASM, we return a special value instead of raising exception
      if X < 0.0 then
         return Float'First; -- Indicates error condition
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

   -- Error checking functions
   function Is_Valid_Division(B : Float) return Boolean is
   begin
      return B /= 0.0;
   end Is_Valid_Division;

   function Is_Valid_Square_Root(X : Float) return Boolean is
   begin
      return X >= 0.0;
   end Is_Valid_Square_Root;

end Library_WASM;