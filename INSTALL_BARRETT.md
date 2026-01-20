
# Build Plan: Compile git-crypt for Windows with Static Linking (Build Folder)

## Overview
Compile git-crypt for Windows using the MSYS2 MinGW64 toolchain with static linking to create a standalone executable that requires no external DLLs (except Windows system DLLs). All build artifacts will be organized in a dedicated `build/` folder to keep the source tree clean.

## Environment Analysis

### Available Toolchains
1. **MSYS2 Installation** (`C:\msys64\`)
   - OpenSSL headers: `C:\msys64\mingw64\include\openssl\` (142 headers)
   - OpenSSL static libs: `C:\msys64\mingw64\lib\libcrypto.a` (9.6 MB)
   - Unix utilities: `C:\msys64\usr\bin\` (bash, grep, etc.)

2. **Standalone MinGW** (`C:\ProgramData\mingw64\mingw64\`)
   - Compiler: GCC/G++ 15.2.0
   - Make: `mingw32-make.exe` (GNU Make 4.4.1)
   - OpenSSL: Available in `opt\include\openssl` and `opt\lib` (PREFERRED - same compiler version)

### Build Requirements (from Makefile)
- C++ compiler with C++11 support
- Make utility
- OpenSSL development files (headers + static library)
- Windows system libraries: ws2_32, crypt32
- zlib library (dependency of OpenSSL)

## Implementation Steps

### Step 1: Create Build Directory
Create a `build/` folder in the git repository to hold all build artifacts:
```bash
mkdir -p build
```

This keeps the source tree clean by separating compiled objects and executables from source files.

### Step 2: Clean Previous Build Artifacts
Remove any old build artifacts from both the source directory and build folder:
```bash
mingw32-make clean
rm -rf build/*
```

This ensures a fresh build without interference from previous compilations.

### Step 3: Build with Static Linking into Build Folder
Compile all object files into the `build/` directory and place the final executable there.

The Makefile doesn't natively support out-of-tree builds, so we'll copy the necessary files to the build folder:

```bash
# Copy source files and Makefile to build directory
cp Makefile *.cpp *.hpp *.h build/ 2>/dev/null || true

# Build in the build directory
cd build
/c/ProgramData/mingw64/mingw64/bin/mingw32-make.exe \
  CXX="/c/ProgramData/mingw64/mingw64/bin/g++.exe" \
  CXXFLAGS="-Wall -pedantic -Wno-long-long -O2 -std=c++11 -IC:/ProgramData/mingw64/mingw64/opt/include" \
  LDFLAGS="-static-libgcc -static-libstdc++ -static -LC:/ProgramData/mingw64/mingw64/opt/lib -lcrypto -lz -lws2_32 -lcrypt32"
```

**Flag Explanations:**
- `-IC:/ProgramData/mingw64/mingw64/opt/include` - Include path for OpenSSL headers (using matching compiler version)
- `-static-libgcc` - Statically link GCC runtime library
- `-static-libstdc++` - Statically link C++ standard library
- `-static` - Attempt to link all libraries statically
- `-LC:/ProgramData/mingw64/mingw64/opt/lib` - Library search path for OpenSSL (matching compiler version)
- `-lcrypto` - Link OpenSSL cryptography library
- `-lz` - Link zlib library (required by OpenSSL)
- `-lws2_32` - Link Windows Sockets 2 (required by OpenSSL)
- `-lcrypt32` - Link Windows Cryptography API (required by OpenSSL)

### Step 4: Verify the Build

**Check executable exists in build folder:**
```bash
ls -lh build/git-crypt.exe
```

**Check DLL dependencies:**
```bash
C:\ProgramData\mingw64\mingw64\bin\objdump.exe -p build/git-crypt.exe | grep "DLL Name:"
```

Expected: Only Windows system DLLs (KERNEL32.dll, ADVAPI32.dll, CRYPT32.dll, WS2_32.dll, USER32.dll, api-ms-win-crt-*.dll)
NOT expected: libcrypto-3-x64.dll, libstdc++-6.dll, libgcc_s_seh-1.dll

**Test functionality:**
```bash
./build/git-crypt.exe --version
./build/git-crypt.exe --help
```

### Step 5: Copy Final Executable to Root (Optional)
For convenience, copy the final executable to the repository root:
```bash
cp build/git-crypt.exe ./
```

## Critical Files

### Build System
- `Makefile` - Main build configuration (lines 49-50 for linking)

### Source Files to be Compiled
- `git-crypt.cpp` - Main entry point
- `commands.cpp` - Command implementations
- `crypto.cpp`, `crypto-openssl-11.cpp` - Encryption logic
- `gpg.cpp`, `key.cpp` - Key management
- `util.cpp`, `util-win32.cpp` - Platform utilities
- `coprocess.cpp`, `coprocess-win32.cpp` - Process handling
- `parse_options.cpp` - Argument parsing
- `fhstream.cpp` - File stream handling

### Dependencies
- OpenSSL headers: `C:\ProgramData\mingw64\mingw64\opt\include\openssl\*.h`
- OpenSSL static lib: `C:\ProgramData\mingw64\mingw64\opt\lib\libcrypto.a`
- zlib static lib: `C:\ProgramData\mingw64\mingw64\opt\lib\libz.a`

## Build Directory Structure

After a successful build, the directory structure will look like:

```
git-crypt/
├── build/                    # Build output directory
│   ├── *.o                  # Object files (git-crypt.o, commands.o, etc.)
│   └── git-crypt.exe        # Final executable (8.7 MB)
├── *.cpp                     # Source files (remain in root)
├── *.hpp, *.h               # Header files (remain in root)
├── Makefile                 # Build configuration
└── git-crypt.exe            # Optional: copied from build/ for convenience
```

## Expected Output

- **Location**: `build/git-crypt.exe` (primary), optionally copied to root
- **Size**: Approximately 8-9 MB (due to static linking of OpenSSL, C++ stdlib, and zlib)
- **Portability**: Runs on any Windows system without requiring MinGW/MSYS2
- **Dependencies**: Only Windows system DLLs

## Troubleshooting

### If static linking fails for OpenSSL
- Verify `libcrypto.a` exists in `C:\ProgramData\mingw64\mingw64\opt\lib`
- Check compiler version compatibility (GCC 15.2.0 required for this OpenSSL build)
- Fallback: Remove `-static` flag to allow dynamic OpenSSL, then bundle `libcrypto-3-x64.dll` with the exe

### If compilation fails with missing headers
- Verify OpenSSL headers exist: `ls C:/ProgramData/mingw64/mingw64/opt/include/openssl`
- Adjust `-I` path in CXXFLAGS if OpenSSL is in a different location

### If zlib linking fails
- Add `-lz` to LDFLAGS (required by OpenSSL compiled with zlib support)
- Error message will contain "undefined reference to `inflate`" or similar zlib functions

### If make is not found
- Use explicit path: `/c/ProgramData/mingw64/mingw64/bin/mingw32-make.exe`
- Verify MinGW installation in `C:\ProgramData\mingw64\mingw64\bin`

### If files fail to copy to build folder
- Verify source files exist in repository root
- Check that `build/` directory was created successfully
- The `2>/dev/null || true` suppresses errors for missing .hpp/.h files (not all may exist)

## Complete Build Script

Here's the complete end-to-end build script:

```bash
# Navigate to repository root
cd /c/Users/barre/.claude-worktrees/git-crypt/jolly-galileo

# Step 1: Create build directory
mkdir -p build

# Step 2: Clean previous builds
/c/ProgramData/mingw64/mingw64/bin/mingw32-make.exe clean
rm -rf build/*

# Step 3: Copy files to build directory
cp Makefile *.cpp *.hpp *.h build/ 2>/dev/null || true

# Step 4: Build in build directory
cd build
/c/ProgramData/mingw64/mingw64/bin/mingw32-make.exe \
  CXX="/c/ProgramData/mingw64/mingw64/bin/g++.exe" \
  CXXFLAGS="-Wall -pedantic -Wno-long-long -O2 -std=c++11 -IC:/ProgramData/mingw64/mingw64/opt/include" \
  LDFLAGS="-static-libgcc -static-libstdc++ -static -LC:/ProgramData/mingw64/mingw64/opt/lib -lcrypto -lz -lws2_32 -lcrypt32"

# Step 5: Verify the build
ls -lh git-crypt.exe
/c/ProgramData/mingw64/mingw64/bin/objdump.exe -p git-crypt.exe | grep "DLL Name:"
./git-crypt.exe --version

# Step 6 (Optional): Copy to repository root
cp git-crypt.exe ../
```

## Reference
Based on official GitHub Actions workflow: `.github\workflows\release-windows.yml:27`
```yaml
run: make LDFLAGS="-static-libstdc++ -static -lcrypto -lws2_32 -lcrypt32"
```

Note: The build also requires `-lz` for zlib dependency of OpenSSL.


