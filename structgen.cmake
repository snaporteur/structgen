# ============================================================================
# structgen.cmake - CMake helper module for structgen
# ============================================================================
# This module provides the build_struct() function to generate C++ headers
# from structgen .st definition files during the CMake build process.
# ============================================================================

if(DEFINED _STRUCTGEN_CMAKE_INCLUDED)
    return()
endif()
set(_STRUCTGEN_CMAKE_INCLUDED TRUE)

# Find Python if not already found
if(NOT Python3_FOUND)
    find_package(Python3 3.9 REQUIRED COMPONENTS Interpreter)
endif()

# ============================================================================
# build_struct - Main function to generate headers from .st files
# ============================================================================
#
# Usage:
#   build_struct(TARGET <target_name>
#       INPUT <input_file.st>
#       [OUTPUT <output_dir>]
#       [DEPENDS <other_files>]
#       [VERBOSE]
#   )
#
# Parameters:
#   TARGET      - The CMake target to attach generated header to
#   INPUT       - Path to the .st definition file to process
#   OUTPUT      - Output directory (default: ${CMAKE_CURRENT_BINARY_DIR}/generated)
#   DEPENDS     - Additional dependencies for the generation
#   VERBOSE     - Enable verbose output during generation
#
# Example:
#   build_struct(TARGET my_app
#       INPUT "${CMAKE_CURRENT_SOURCE_DIR}/structs.st"
#       OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/include"
#   )
#
function(build_struct)
    # Parse arguments
    set(options VERBOSE)
    set(oneValueArgs TARGET INPUT OUTPUT)
    set(multiValueArgs DEPENDS)
    cmake_parse_arguments(BUILD_STRUCT "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    # Validate required arguments
    if(NOT BUILD_STRUCT_TARGET)
        message(FATAL_ERROR "build_struct: TARGET argument is required")
    endif()

    if(NOT BUILD_STRUCT_INPUT)
        message(FATAL_ERROR "build_struct: INPUT argument is required")
    endif()

    # Set default output directory
    if(NOT BUILD_STRUCT_OUTPUT)
        set(BUILD_STRUCT_OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/generated")
    endif()

    # Convert to absolute paths
    if(NOT IS_ABSOLUTE "${BUILD_STRUCT_INPUT}")
        set(BUILD_STRUCT_INPUT "${CMAKE_CURRENT_SOURCE_DIR}/${BUILD_STRUCT_INPUT}")
    endif()

    if(NOT IS_ABSOLUTE "${BUILD_STRUCT_OUTPUT}")
        set(BUILD_STRUCT_OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/${BUILD_STRUCT_OUTPUT}")
    endif()

    # Validate input file exists
    if(NOT EXISTS "${BUILD_STRUCT_INPUT}")
        message(FATAL_ERROR "build_struct: Input file not found: ${BUILD_STRUCT_INPUT}")
    endif()

    # Get the base name for the output file
    get_filename_component(INPUT_BASENAME "${BUILD_STRUCT_INPUT}" NAME_WLE)
    set(OUTPUT_HEADER "${BUILD_STRUCT_OUTPUT}/${INPUT_BASENAME}.h")

    # Build the structgen command
    if(BUILD_STRUCT_VERBOSE)
        set(STRUCTGEN_CMD 
            ${Python3_EXECUTABLE} -m structgen.cli build 
            --file "${BUILD_STRUCT_INPUT}"
            --out "${BUILD_STRUCT_OUTPUT}"
            --verbose
        )
    else()
        set(STRUCTGEN_CMD 
            ${Python3_EXECUTABLE} -m structgen.cli build 
            --file "${BUILD_STRUCT_INPUT}"
            --out "${BUILD_STRUCT_OUTPUT}"
        )
    endif()

    # Create output directory if it doesn't exist
    file(MAKE_DIRECTORY "${BUILD_STRUCT_OUTPUT}")

    # Add custom command to generate the header file
    add_custom_command(
        OUTPUT "${OUTPUT_HEADER}"
        COMMAND ${STRUCTGEN_CMD}
        DEPENDS "${BUILD_STRUCT_INPUT}" ${BUILD_STRUCT_DEPENDS}
        COMMENT "Generating struct header from ${INPUT_BASENAME}.st"
        VERBATIM
    )

    # Add the generated header to the target's sources
    target_sources(${BUILD_STRUCT_TARGET} PRIVATE "${OUTPUT_HEADER}")

    # Ensure the generated file is part of the build
    set_source_files_properties("${OUTPUT_HEADER}" PROPERTIES GENERATED TRUE)

    # Add the output directory to the target's include directories
    target_include_directories(${BUILD_STRUCT_TARGET} PRIVATE "${BUILD_STRUCT_OUTPUT}")

    if(BUILD_STRUCT_VERBOSE)
        message(STATUS "build_struct: Configured generation of ${OUTPUT_HEADER}")
    endif()

endfunction()

# ============================================================================
# build_struct_target - Create a new library target from .st file
# ============================================================================
#
# Usage:
#   build_struct_target(NAME <lib_name>
#       INPUT <input_file.st>
#       [OUTPUT_DIR <output_dir>]
#       [DEPENDENCIES <lib1> <lib2>]
#       [VERBOSE]
#   )
#
# Creates an INTERFACE library that contains the generated header.
#
# Example:
#   build_struct_target(NAME my_structs
#       INPUT "${CMAKE_CURRENT_SOURCE_DIR}/data.st"
#   )
#   target_link_libraries(my_app my_structs)
#
function(build_struct_target)
    # Parse arguments
    set(options VERBOSE)
    set(oneValueArgs NAME INPUT OUTPUT_DIR)
    set(multiValueArgs DEPENDENCIES)
    cmake_parse_arguments(BST "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    # Validate required arguments
    if(NOT BST_NAME)
        message(FATAL_ERROR "build_struct_target: NAME argument is required")
    endif()

    if(NOT BST_INPUT)
        message(FATAL_ERROR "build_struct_target: INPUT argument is required")
    endif()

    if(NOT BST_OUTPUT_DIR)
        set(BST_OUTPUT_DIR "${CMAKE_CURRENT_BINARY_DIR}/generated")
    endif()

    # Create INTERFACE library
    add_library(${BST_NAME} INTERFACE)

    # Build the struct
    if(BST_VERBOSE)
        build_struct(TARGET ${BST_NAME}
            INPUT "${BST_INPUT}"
            OUTPUT "${BST_OUTPUT_DIR}"
            VERBOSE
        )
    else()
        build_struct(TARGET ${BST_NAME}
            INPUT "${BST_INPUT}"
            OUTPUT "${BST_OUTPUT_DIR}"
        )
    endif()

    # Link dependencies if provided
    if(BST_DEPENDENCIES)
        target_link_libraries(${BST_NAME} INTERFACE ${BST_DEPENDENCIES})
    endif()

    message(STATUS "Created struct library target: ${BST_NAME}")

endfunction()

# ============================================================================
# build_all_structs - Generate headers from all .st files in a directory
# ============================================================================
#
# Usage:
#   build_all_structs(TARGET <target_name>
#       DIRECTORY <directory>
#       [OUTPUT <output_dir>]
#       [PATTERN <glob_pattern>]
#       [VERBOSE]
#   )
#
# Recursively finds and processes all .st files in a directory.
#
# Example:
#   build_all_structs(TARGET my_app
#       DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/structs"
#   )
#
function(build_all_structs)
    set(options VERBOSE)
    set(oneValueArgs TARGET DIRECTORY OUTPUT PATTERN)
    set(multiValueArgs)
    cmake_parse_arguments(BAS "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    if(NOT BAS_TARGET)
        message(FATAL_ERROR "build_all_structs: TARGET argument is required")
    endif()

    if(NOT BAS_DIRECTORY)
        message(FATAL_ERROR "build_all_structs: DIRECTORY argument is required")
    endif()

    if(NOT BAS_PATTERN)
        set(BAS_PATTERN "*.st")
    endif()

    if(NOT BAS_OUTPUT)
        set(BAS_OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/generated")
    endif()

    # Find all .st files
    file(GLOB_RECURSE ST_FILES "${BAS_DIRECTORY}/${BAS_PATTERN}")

    if(NOT ST_FILES)
        message(WARNING "build_all_structs: No .st files found in ${BAS_DIRECTORY}")
        return()
    endif()

    # Process each file
    foreach(ST_FILE ${ST_FILES})
        get_filename_component(FILE_NAME "${ST_FILE}" NAME)
        if(BAS_VERBOSE)
            build_struct(TARGET ${BAS_TARGET}
                INPUT "${ST_FILE}"
                OUTPUT "${BAS_OUTPUT}"
                VERBOSE
            )
        else()
            build_struct(TARGET ${BAS_TARGET}
                INPUT "${ST_FILE}"
                OUTPUT "${BAS_OUTPUT}"
            )
        endif()
    endforeach()

    message(STATUS "Configured ${ST_FILES} struct files for generation")

endfunction()

# ============================================================================
# Export the structgen module info for external projects
# ============================================================================

# Mark structgen as found
set(structgen_FOUND TRUE)
