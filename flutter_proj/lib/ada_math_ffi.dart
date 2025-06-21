import 'dart:ffi';
import 'dart:io';

// Define the function signatures for the Ada library
typedef AdaBinaryOpNative = Float Function(Float a, Float b);
typedef AdaBinaryOp = double Function(double a, double b);

typedef AdaUnaryOpNative = Float Function(Float x);
typedef AdaUnaryOp = double Function(double x);

class AdaMathFFI {
  late final DynamicLibrary _adaLib;
  
  // Binary operations
  late final AdaBinaryOp add;
  late final AdaBinaryOp subtract;
  late final AdaBinaryOp multiply;
  late final AdaBinaryOp divide;
  late final AdaBinaryOp power;
  late final AdaBinaryOp maximum;
  late final AdaBinaryOp minimum;
  
  // Unary operations
  late final AdaUnaryOp squareRoot;
  late final AdaUnaryOp absoluteValue;
  
  AdaMathFFI() {
    // Load the shared library based on the platform
    _adaLib = _loadLibrary();
    
    // Bind the functions
    add = _adaLib
        .lookup<NativeFunction<AdaBinaryOpNative>>('ada_add')
        .asFunction<AdaBinaryOp>();
        
    subtract = _adaLib
        .lookup<NativeFunction<AdaBinaryOpNative>>('ada_subtract')
        .asFunction<AdaBinaryOp>();
        
    multiply = _adaLib
        .lookup<NativeFunction<AdaBinaryOpNative>>('ada_multiply')
        .asFunction<AdaBinaryOp>();
        
    divide = _adaLib
        .lookup<NativeFunction<AdaBinaryOpNative>>('ada_divide')
        .asFunction<AdaBinaryOp>();
        
    power = _adaLib
        .lookup<NativeFunction<AdaBinaryOpNative>>('ada_power')
        .asFunction<AdaBinaryOp>();
        
    maximum = _adaLib
        .lookup<NativeFunction<AdaBinaryOpNative>>('ada_max')
        .asFunction<AdaBinaryOp>();
        
    minimum = _adaLib
        .lookup<NativeFunction<AdaBinaryOpNative>>('ada_min')
        .asFunction<AdaBinaryOp>();
        
    squareRoot = _adaLib
        .lookup<NativeFunction<AdaUnaryOpNative>>('ada_sqrt')
        .asFunction<AdaUnaryOp>();
        
    absoluteValue = _adaLib
        .lookup<NativeFunction<AdaUnaryOpNative>>('ada_abs')
        .asFunction<AdaUnaryOp>();
  }
  
  DynamicLibrary _loadLibrary() {
    if (Platform.isLinux) {
      // Try to load from multiple possible locations
      try {
        // First try the system library path
        return DynamicLibrary.open('libada_math.so');
      } catch (e) {
        try {
          // Try the ada_lib directory (absolute path for development)
          return DynamicLibrary.open('/home/akvus/client_dev/sdev/ffi_ada_dart_test/ada_lib/libada_math.so');
        } catch (e) {
          try {
            // Try current directory
            return DynamicLibrary.open('./libada_math.so');
          } catch (e) {
            try {
              // Try the lib directory relative to the executable
              final executablePath = Platform.resolvedExecutable;
              final libPath = '${executablePath.substring(0, executablePath.lastIndexOf('/'))}/lib/libada_math.so';
              return DynamicLibrary.open(libPath);
            } catch (e) {
              // Try relative path as last resort
              return DynamicLibrary.open('../ada_lib/libada_math.so');
            }
          }
        }
      }
    } else if (Platform.isAndroid) {
      return DynamicLibrary.open('libada_math.so');
    } else if (Platform.isIOS) {
      return DynamicLibrary.process();
    } else if (Platform.isMacOS) {
      return DynamicLibrary.open('libada_math.dylib');
    } else if (Platform.isWindows) {
      return DynamicLibrary.open('ada_math.dll');
    } else {
      throw UnsupportedError('Unsupported platform: ${Platform.operatingSystem}');
    }
  }
}

// Singleton instance
final adaMath = AdaMathFFI();