# WARN: AI used to generate some parts of this file.

cmake_minimum_required(VERSION 3.10)
project(structgen LANGUAGES NONE)

find_package(Python3 3.9 REQUIRED COMPONENTS Interpreter)

execute_process(
    COMMAND ${Python3_EXECUTABLE} -m pip --version
    OUTPUT_VARIABLE PIP_VERSION
    OUTPUT_STRIP_TRAILING_WHITESPACE
)

if(NOT PIP_VERSION)
    message(FATAL_ERROR "pip is not available in Python ${Python3_VERSION}. Please ensure pip is installed.")
endif()

message(STATUS "Using Python ${Python3_VERSION} from ${Python3_EXECUTABLE}")

execute_process(
    COMMAND ${Python3_EXECUTABLE} -m pip install --quiet 
        jinja2>=3.1.6
        click>=8.4.1
        lark>=1.3.1
    RESULT_VARIABLE PIP_RESULT
)

if(NOT PIP_RESULT EQUAL 0)
    message(FATAL_ERROR "Failed to install Python dependencies for structgen")
endif()

message(STATUS "Python dependencies installed successfully")

# ============================================================================
# Add structgen as a library target (for FetchContent compatibility)
# ============================================================================

# Get the absolute path to the structgen module
get_filename_component(STRUCTGEN_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/structgen" ABSOLUTE)
get_filename_component(STRUCTGEN_PROJECT_ROOT "${CMAKE_CURRENT_SOURCE_DIR}" ABSOLUTE)

# Create a custom target to mark structgen as available
add_library(structgen INTERFACE)
target_compile_definitions(structgen INTERFACE STRUCTGEN_FOUND=1)

# Store structgen info for use in other projects
set(structgen_FOUND TRUE CACHE BOOL "structgen package found")
set(structgen_DIR "${CMAKE_CURRENT_SOURCE_DIR}" CACHE PATH "structgen project directory")
set(structgen_PYTHON_EXECUTABLE "${Python3_EXECUTABLE}" CACHE FILEPATH "Python executable used by structgen")
set(structgen_MODULE_PATH "${STRUCTGEN_MODULE_PATH}" CACHE PATH "structgen Python module path")

# Export the build_struct function through a helper module
include("${CMAKE_CURRENT_SOURCE_DIR}/structgen.cmake")

# ============================================================================
# Installation & Packaging
# ============================================================================

# Install the Python module
install(
    DIRECTORY structgen/
    DESTINATION lib/python3/site-packages/structgen
    FILES_MATCHING PATTERN "*.py" PATTERN "*.lark" PATTERN "*.h"
)

# Install CMake helpers
install(
    FILES structgen.cmake
    DESTINATION lib/cmake/structgen
)

# ============================================================================
# Package Configuration (for FetchContent and find_package)
# ============================================================================

include(CMakePackageConfigHelpers)

# Generate version file
write_basic_package_version_file(
    "${CMAKE_CURRENT_BINARY_DIR}/structgenConfigVersion.cmake"
    VERSION ${PROJECT_VERSION}
    COMPATIBILITY SameMajorVersion
)

# Generate config file
configure_package_config_file(
    "${CMAKE_CURRENT_SOURCE_DIR}/structgenConfig.cmake.in"
    "${CMAKE_CURRENT_BINARY_DIR}/structgenConfig.cmake"
    INSTALL_DESTINATION lib/cmake/structgen
    PATH_VARS structgen_DIR
)

# Install config files
install(
    FILES 
        "${CMAKE_CURRENT_BINARY_DIR}/structgenConfig.cmake"
        "${CMAKE_CURRENT_BINARY_DIR}/structgenConfigVersion.cmake"
    DESTINATION lib/cmake/structgen
)

message(STATUS "structgen CMake configuration completed successfully")
