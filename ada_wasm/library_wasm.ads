with Ada.Numerics.Elementary_Functions;

package Library_WASM is
   pragma Preelaborate;

   -- Mathematical functions for WASM compilation
   -- Note: All functions are designed to be WASM-compatible
   -- (no nested subprograms, limited exception handling)

   function Add(A, B : Float) return Float;
   function Subtract(A, B : Float) return Float;
   function Multiply(A, B : Float) return Float;
   function Divide(A, B : Float) return Float;
   function Square_Root(X : Float) return Float;
   function Power(Base, Exponent : Float) return Float;
   function Absolute_Value(X : Float) return Float;
   function Maximum(A, B : Float) return Float;
   function Minimum(A, B : Float) return Float;

   -- Error handling functions for WASM
   function Is_Valid_Division(B : Float) return Boolean;
   function Is_Valid_Square_Root(X : Float) return Boolean;

end Library_WASM;