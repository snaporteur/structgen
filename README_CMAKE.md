# structgen - CMake Integration Guide

## Overview

This CMakeLists.txt integrates **structgen**, a C++ struct code generator, into your CMake build system. It provides convenient CMake functions to generate C++ headers from `.st` definition files during the build process.

## Features

✅ **Python Integration** - Automatically finds and configures Python 3.9+  
✅ **Dependency Management** - Installs required Python packages (jinja2, click, lark)  
✅ **FetchContent Support** - Works seamlessly with CMake's FetchContent module  
✅ **Multiple APIs** - Three levels of functionality depending on your needs  
✅ **Parallel Builds** - Generated files integrate properly with CMake's parallel build system  

## Installation

### For a standalone structgen project

```cmake
# CMakeLists.txt in your project root
cmake_minimum_required(VERSION 3.24)
project(my_project)

# ... your project configuration ...
```

### For using structgen in another project with FetchContent

```cmake
include(FetchContent)

FetchContent_Declare(structgen
    GIT_REPOSITORY https://github.com/yourusername/structgen.git
    GIT_TAG main
)
FetchContent_MakeAvailable(structgen)
```

## Usage Examples

### 1. Simple: Generate a single struct file

```cmake
add_executable(my_app src/main.cpp)

build_struct(TARGET my_app
    INPUT "${CMAKE_CURRENT_SOURCE_DIR}/models/data.st"
    OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/include"
)
```

**Result**: 
- Parses `data.st` 
- Generates `${CMAKE_CURRENT_BINARY_DIR}/include/data.h`
- Adds it to `my_app` sources
- Automatically adds include directory

### 2. Create a struct library target

```cmake
build_struct_target(NAME data_structs
    INPUT "${CMAKE_CURRENT_SOURCE_DIR}/models/data.st"
)

add_executable(my_app src/main.cpp)
target_link_libraries(my_app data_structs)
```

### 3. Generate all structs from a directory

```cmake
add_executable(my_app src/main.cpp)

build_all_structs(TARGET my_app
    DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/structs"
    OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/generated"
)
```

This will:
- Find all `.st` files recursively in `structs/`
- Generate corresponding `.h` files
- Add them all to `my_app`

### 4. With verbose output for debugging

```cmake
build_struct(TARGET my_app
    INPUT "${CMAKE_CURRENT_SOURCE_DIR}/data.st"
    VERBOSE
)
```

### 5. Multiple struct files with dependencies

```cmake
add_executable(my_app src/main.cpp)

# Generate structs and explicitly list dependencies
build_struct(TARGET my_app
    INPUT "${CMAKE_CURRENT_SOURCE_DIR}/base.st"
    OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/include"
    DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/base.lark"
)

build_struct(TARGET my_app
    INPUT "${CMAKE_CURRENT_SOURCE_DIR}/extended.st"
    OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/include"
    DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/base.st"
)
```

## Complete Example Project

```cmake
cmake_minimum_required(VERSION 3.24)
project(MyApp VERSION 1.0.0)

set(CMAKE_CXX_STANDARD 17)

# Fetch structgen from git
include(FetchContent)
FetchContent_Declare(structgen
    GIT_REPOSITORY https://github.com/yourusername/structgen.git
    GIT_TAG v0.1.0
)
FetchContent_MakeAvailable(structgen)

# Create directories for generated files
set(GENERATED_INCLUDE_DIR "${CMAKE_CURRENT_BINARY_DIR}/generated/include")
file(MAKE_DIRECTORY "${GENERATED_INCLUDE_DIR}")

# Create main executable
add_executable(myapp
    src/main.cpp
    src/utils.cpp
)

# Generate struct headers
build_all_structs(TARGET myapp
    DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/structs"
    OUTPUT "${GENERATED_INCLUDE_DIR}"
)

# Link against generated structs
target_include_directories(myapp PRIVATE "${GENERATED_INCLUDE_DIR}")
```

## Function Reference

### `build_struct()`

Generates a single C++ header from a `.st` definition file.

```cmake
build_struct(TARGET <target_name>
    INPUT <input_file.st>
    [OUTPUT <output_dir>]
    [DEPENDS <dependencies...>]
    [VERBOSE]
)
```

**Parameters:**
- `TARGET` (required) - CMake target to attach generated header to
- `INPUT` (required) - Path to `.st` definition file
- `OUTPUT` - Output directory (default: `${CMAKE_CURRENT_BINARY_DIR}/generated`)
- `DEPENDS` - Additional files that trigger regeneration if modified
- `VERBOSE` - Enable verbose output

---

### `build_struct_target()`

Creates an INTERFACE library target containing generated headers. Useful for sharing structs across multiple targets.

```cmake
build_struct_target(NAME <library_name>
    INPUT <input_file.st>
    [OUTPUT_DIR <directory>]
    [DEPENDENCIES <lib1> <lib2>...]
    [VERBOSE]
)
```

**Parameters:**
- `NAME` (required) - Name of the created library target
- `INPUT` (required) - Path to `.st` definition file
- `OUTPUT_DIR` - Output directory (default: `${CMAKE_CURRENT_BINARY_DIR}/generated`)
- `DEPENDENCIES` - Other library targets to link
- `VERBOSE` - Enable verbose output

**Usage:**
```cmake
build_struct_target(NAME common_structs INPUT "common.st")
build_struct_target(NAME app_structs INPUT "app.st" DEPENDENCIES common_structs)

add_executable(myapp main.cpp)
target_link_libraries(myapp app_structs)
```

---

### `build_all_structs()`

Generates headers from all `.st` files in a directory (recursive).

```cmake
build_all_structs(TARGET <target_name>
    DIRECTORY <directory>
    [OUTPUT <output_dir>]
    [PATTERN <glob_pattern>]
    [VERBOSE]
)
```

**Parameters:**
- `TARGET` (required) - CMake target to attach all generated headers to
- `DIRECTORY` (required) - Root directory to search for `.st` files
- `OUTPUT` - Output directory (default: `${CMAKE_CURRENT_BINARY_DIR}/generated`)
- `PATTERN` - Glob pattern (default: `*.st`)
- `VERBOSE` - Enable verbose output

---

## How It Works

1. **Configuration Phase** (when you run `cmake`):
   - Finds Python 3.9 or later
   - Installs required packages: jinja2, click, lark
   - Includes the `structgen.cmake` helper module
   - Parses your `build_struct()` calls

2. **Build Phase** (when you run `make` or `ninja`):
   - CMake runs `python -m structgen.cli build`
   - Structgen parses your `.st` file using Lark
   - Generates C++ header using Jinja2 templates
   - Stores header in the output directory
   - Your C++ compiler includes the generated header

3. **Dependency Tracking**:
   - If you modify a `.st` file, CMake detects the change
   - Regenerates the header automatically
   - Recompiles only affected C++ files

## Troubleshooting

### Error: Python not found
```
CMake Error: Could not find Python3 (3.9+)
```

**Solution**: Install Python 3.9+ or specify Python explicitly:
```bash
cmake -DPython3_EXECUTABLE=/path/to/python3 ..
```

### Error: Module 'structgen' not found
```
python: No module named structgen
```

**Solution**: Ensure you're using the structgen module correctly:
```bash
# Check structgen is in Python path
python3 -c "import sys; print(sys.path)"

# Or reinstall with pip
pip install -e /path/to/structgen
```

### Generated files not being included
Make sure you're using `target_include_directories()` or let `build_struct()` do it automatically.

### CMake doesn't regenerate on .st file changes
Check that your `.st` files are in the `DEPENDS` list or are listed as `INPUT`.

## Testing

Run the included tests:

```bash
cd build
ctest --output-on-failure
```

To manually test struct generation:

```bash
python3 -m structgen.cli build -f tests/example.st -o /tmp/generated -v
cat /tmp/generated/example.h
```

## Project Structure

```
structgen/
├── CMakeLists.txt           # Main build configuration
├── structgen.cmake          # Helper functions for struct generation
├── structgenConfig.cmake.in # Package configuration template
├── structgen/
│   ├── __init__.py
│   ├── builder.py           # Main builder class
│   ├── parser.py            # Lark parser
│   ├── cli.py               # Click CLI
│   ├── writter.py           # Code generator
│   ├── template.h           # Jinja2 template
│   └── grammar.lark         # Lark grammar
├── tests/
│   └── example.st           # Example struct definition
└── pyproject.toml           # Python project config
```

## License

See LICENSE in the repository.
