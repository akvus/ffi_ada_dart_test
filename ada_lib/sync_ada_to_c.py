#!/usr/bin/env python3
"""
Ada to C Synchronization Tool
============================

This tool parses Ada source files and generates equivalent C implementations
for Android cross-compilation, maintaining interface compatibility.

Usage:
    python3 sync_ada_to_c.py
"""

import re
import os
from typing import List, Dict, Tuple, Optional

class AdaFunction:
    def __init__(self, name: str, params: List[Tuple[str, str]], return_type: str, body: str):
        self.name = name
        self.params = params  # [(param_name, param_type), ...]
        self.return_type = return_type
        self.body = body
        
    def to_c_declaration(self) -> str:
        """Generate C function declaration"""
        c_params = []
        for param_name, param_type in self.params:
            c_type = self.ada_type_to_c(param_type)
            c_params.append(f"{c_type} {param_name.lower()}")
        
        c_return_type = self.ada_type_to_c(self.return_type)
        params_str = ", ".join(c_params) if c_params else "void"
        
        return f"{c_return_type} ada_{self.name.lower()}({params_str})"
    
    def to_c_implementation(self) -> str:
        """Generate C function implementation"""
        declaration = self.to_c_declaration()
        c_body = self.ada_body_to_c()
        
        return f"""{declaration} {{
{c_body}
}}"""
    
    def ada_type_to_c(self, ada_type: str) -> str:
        """Convert Ada type to C type"""
        type_map = {
            'Float': 'float',
            'Integer': 'int',
            'Boolean': 'bool',
            'String': 'char*'
        }
        return type_map.get(ada_type, 'float')  # Default to float
    
    def ada_body_to_c(self) -> str:
        """Convert Ada function body to C"""
        # Simple pattern matching for basic operations
        body = self.body.strip()
        
        # Handle simple arithmetic operations
        if 'return A + B' in body:
            return "    return a + b;"
        elif 'return A - B' in body:
            return "    return a - b;"
        elif 'return A * B' in body:
            return "    return a * b;"
        elif 'return A / B' in body:
            return """    if (b == 0.0f) {
        return NAN;  // Ada would raise Constraint_Error
    }
    return a / b;"""
        elif 'Ada.Numerics.Elementary_Functions.Sqrt' in body:
            return """    if (x < 0.0f) {
        return NAN;  // Ada would raise Argument_Error
    }
    return sqrtf(x);"""
        elif 'Ada.Numerics.Elementary_Functions.\"**\"' in body:
            return "    return powf(base, exponent);"
        elif 'abs(' in body:
            return "    return fabsf(x);"
        elif 'Float\'Max' in body:
            return "    return a > b ? a : b;"
        elif 'Float\'Min' in body:
            return "    return a < b ? a : b;"
        else:
            return "    // TODO: Convert this Ada code to C\\n    return 0.0f;"

class AdaParser:
    def __init__(self, ada_file: str):
        self.ada_file = ada_file
        self.functions: List[AdaFunction] = []
    
    def parse(self) -> List[AdaFunction]:
        """Parse Ada file and extract functions"""
        with open(self.ada_file, 'r') as f:
            content = f.read()
        
        # Find all function definitions
        function_pattern = r'function\s+(\w+)\s*\((.*?)\)\s*return\s+(\w+)\s+is\s*(.*?)end\s+\1;'
        matches = re.findall(function_pattern, content, re.DOTALL | re.IGNORECASE)
        
        for match in matches:
            name, params_str, return_type, body = match
            params = self.parse_parameters(params_str)
            self.functions.append(AdaFunction(name, params, return_type, body))
        
        return self.functions
    
    def parse_parameters(self, params_str: str) -> List[Tuple[str, str]]:
        """Parse Ada function parameters"""
        params = []
        if params_str.strip():
            # Simple parsing for "A, B : Float" format
            param_groups = params_str.split(';')
            for group in param_groups:
                if ':' in group:
                    names_part, type_part = group.split(':', 1)
                    param_type = type_part.strip()
                    names = [name.strip() for name in names_part.split(',')]
                    for name in names:
                        params.append((name, param_type))
        return params

class CGenerator:
    def __init__(self, functions: List[AdaFunction]):
        self.functions = functions
    
    def generate_header(self) -> str:
        """Generate C header file content"""
        header = """#ifndef ADA_MATH_H
#define ADA_MATH_H

#ifdef __cplusplus
extern "C" {
#endif

"""
        for func in self.functions:
            header += f"{func.to_c_declaration()};\n"
        
        header += """
#ifdef __cplusplus
}
#endif

#endif /* ADA_MATH_H */
"""
        return header
    
    def generate_implementation(self) -> str:
        """Generate C implementation file content"""
        impl = """#include "ada_math.h"
#include <math.h>

// Auto-generated from Ada source - DO NOT EDIT MANUALLY
// Generated by sync_ada_to_c.py

"""
        for func in self.functions:
            impl += f"{func.to_c_implementation()}\n\n"
        
        return impl

def main():
    """Main synchronization function"""
    print("Ada to C Synchronization Tool")
    print("============================")
    
    # Check if Ada files exist
    ada_files = ['library.adb', 'library_c_wrapper.adb']
    found_files = [f for f in ada_files if os.path.exists(f)]
    
    if not found_files:
        print("❌ No Ada files found in current directory")
        print("Expected files: library.adb, library_c_wrapper.adb")
        return
    
    print(f"📁 Found Ada files: {', '.join(found_files)}")
    
    # Parse Ada files
    all_functions = []
    for ada_file in found_files:
        print(f"🔍 Parsing {ada_file}...")
        parser = AdaParser(ada_file)
        functions = parser.parse()
        all_functions.extend(functions)
        print(f"   Found {len(functions)} functions")
    
    if not all_functions:
        print("❌ No functions found in Ada files")
        return
    
    print(f"\n📋 Total functions found: {len(all_functions)}")
    for func in all_functions:
        print(f"   - {func.name}({', '.join([p[0] for p in func.params])}) -> {func.return_type}")
    
    # Generate C code
    print("\\n🔧 Generating C code...")
    generator = CGenerator(all_functions)
    
    # Generate header
    header_content = generator.generate_header()
    with open('ada_math_generated.h', 'w') as f:
        f.write(header_content)
    print("   ✅ Generated ada_math_generated.h")
    
    # Generate implementation
    impl_content = generator.generate_implementation()
    with open('ada_math_generated.c', 'w') as f:
        f.write(impl_content)
    print("   ✅ Generated ada_math_generated.c")
    
    # Compare with existing C implementation
    if os.path.exists('ada_math_android.c'):
        print("\\n🔍 Comparing with existing C implementation...")
        with open('ada_math_android.c', 'r') as f:
            existing = f.read()
        
        if impl_content.replace('ada_math_generated.h', 'ada_math.h') in existing:
            print("   ✅ Generated code matches existing implementation")
        else:
            print("   ⚠️  Generated code differs from existing implementation")
            print("   📝 Consider updating ada_math_android.c with generated code")
    
    print("\\n🎉 Synchronization complete!")
    print("\\nNext steps:")
    print("1. Review generated C code")
    print("2. Test generated functions")
    print("3. Update build scripts if needed")

if __name__ == "__main__":
    main()