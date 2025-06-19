with Ada.Text_IO;
with Library;

procedure Test_Library is
   use Ada.Text_IO;
   
   Result : Float;
begin
   Put_Line("Testing Ada Library Functions");
   Put_Line("=============================");
   
   -- Test Add
   Result := Library.Add(10.0, 5.0);
   Put_Line("Add(10.0, 5.0) = " & Float'Image(Result));
   
   -- Test Subtract
   Result := Library.Subtract(10.0, 5.0);
   Put_Line("Subtract(10.0, 5.0) = " & Float'Image(Result));
   
   -- Test Multiply
   Result := Library.Multiply(10.0, 5.0);
   Put_Line("Multiply(10.0, 5.0) = " & Float'Image(Result));
   
   -- Test Divide
   Result := Library.Divide(10.0, 5.0);
   Put_Line("Divide(10.0, 5.0) = " & Float'Image(Result));
   
   -- Test Square_Root
   Result := Library.Square_Root(25.0);
   Put_Line("Square_Root(25.0) = " & Float'Image(Result));
   
   -- Test Power
   Result := Library.Power(2.0, 3.0);
   Put_Line("Power(2.0, 3.0) = " & Float'Image(Result));
   
   -- Test Absolute_Value
   Result := Library.Absolute_Value(-15.5);
   Put_Line("Absolute_Value(-15.5) = " & Float'Image(Result));
   
   -- Test Maximum
   Result := Library.Maximum(10.0, 20.0);
   Put_Line("Maximum(10.0, 20.0) = " & Float'Image(Result));
   
   -- Test Minimum
   Result := Library.Minimum(10.0, 20.0);
   Put_Line("Minimum(10.0, 20.0) = " & Float'Image(Result));
   
   Put_Line("=============================");
   Put_Line("All tests completed successfully!");
   
exception
   when Constraint_Error =>
      Put_Line("Error: Constraint violation occurred");
   when others =>
      Put_Line("Error: An unexpected error occurred");
end Test_Library;