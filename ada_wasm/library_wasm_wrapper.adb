package body Library_WASM_Wrapper is

   function wasm_add(A, B : Float) return Float is
   begin
      return Library_WASM.Add(A, B);
   end wasm_add;

   function wasm_subtract(A, B : Float) return Float is
   begin
      return Library_WASM.Subtract(A, B);
   end wasm_subtract;

   function wasm_multiply(A, B : Float) return Float is
   begin
      return Library_WASM.Multiply(A, B);
   end wasm_multiply;

   function wasm_divide(A, B : Float) return Float is
   begin
      return Library_WASM.Divide(A, B);
   end wasm_divide;

   function wasm_sqrt(X : Float) return Float is
   begin
      return Library_WASM.Square_Root(X);
   end wasm_sqrt;

   function wasm_power(Base, Exponent : Float) return Float is
   begin
      return Library_WASM.Power(Base, Exponent);
   end wasm_power;

   function wasm_abs(X : Float) return Float is
   begin
      return Library_WASM.Absolute_Value(X);
   end wasm_abs;

   function wasm_max(A, B : Float) return Float is
   begin
      return Library_WASM.Maximum(A, B);
   end wasm_max;

   function wasm_min(A, B : Float) return Float is
   begin
      return Library_WASM.Minimum(A, B);
   end wasm_min;

   function wasm_is_valid_division(B : Float) return Integer is
   begin
      if Library_WASM.Is_Valid_Division(B) then
         return 1;
      else
         return 0;
      end if;
   end wasm_is_valid_division;

   function wasm_is_valid_sqrt(X : Float) return Integer is
   begin
      if Library_WASM.Is_Valid_Square_Root(X) then
         return 1;
      else
         return 0;
      end if;
   end wasm_is_valid_sqrt;

end Library_WASM_Wrapper;