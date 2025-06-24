with Library_WASM;

package Library_WASM_Wrapper is
   pragma Preelaborate;

   -- C-compatible wrapper functions for WASM export
   -- These functions will be exported to JavaScript

   function wasm_add(A, B : Float) return Float
     with Export, Convention => C, External_Name => "wasm_add";

   function wasm_subtract(A, B : Float) return Float
     with Export, Convention => C, External_Name => "wasm_subtract";

   function wasm_multiply(A, B : Float) return Float
     with Export, Convention => C, External_Name => "wasm_multiply";

   function wasm_divide(A, B : Float) return Float
     with Export, Convention => C, External_Name => "wasm_divide";

   function wasm_sqrt(X : Float) return Float
     with Export, Convention => C, External_Name => "wasm_sqrt";

   function wasm_power(Base, Exponent : Float) return Float
     with Export, Convention => C, External_Name => "wasm_power";

   function wasm_abs(X : Float) return Float
     with Export, Convention => C, External_Name => "wasm_abs";

   function wasm_max(A, B : Float) return Float
     with Export, Convention => C, External_Name => "wasm_max";

   function wasm_min(A, B : Float) return Float
     with Export, Convention => C, External_Name => "wasm_min";

   -- Error checking functions
   function wasm_is_valid_division(B : Float) return Integer
     with Export, Convention => C, External_Name => "wasm_is_valid_division";

   function wasm_is_valid_sqrt(X : Float) return Integer
     with Export, Convention => C, External_Name => "wasm_is_valid_sqrt";

end Library_WASM_Wrapper;