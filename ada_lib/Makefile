# Makefile for Ada Library

# Compiler
GNATMAKE = gnatmake
GNATBIND = gnatbind
GNATLINK = gnatlink
GCC = gcc

# Flags
ADAFLAGS = -gnat2012
CFLAGS = -shared -fPIC
LDFLAGS = -lm

# Targets
all: test shared

# Build test program
test: test_library
	@echo "Test program built successfully"

test_library: test_library.adb library.ads library.adb
	$(GNATMAKE) test_library.adb $(ADAFLAGS)

# Build shared library for FFI
shared: libada_math.so
	@echo "Shared library built successfully"

libada_math.so: library.ads library.adb library_c_wrapper.ads library_c_wrapper.adb
	$(GNATMAKE) -c library.adb $(ADAFLAGS) -fPIC
	$(GNATMAKE) -c library_c_wrapper.adb $(ADAFLAGS) -fPIC
	$(GNATBIND) -shared -x library_c_wrapper.ali
	$(GCC) -shared -o libada_math.so library.o library_c_wrapper.o -lgnat $(LDFLAGS)

# Run tests
run-test: test_library
	./test_library

# Clean build artifacts
clean:
	rm -f *.o *.ali test_library libada_math.so b~*

.PHONY: all test shared run-test clean