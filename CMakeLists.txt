cmake_minimum_required(VERSION 3.10)

find_program(POETRY_EXECUTABLE poetry REQUIRED)

if(NOT EXISTS "${CMAKE_BINARY_DIR}/poetry_installed")
    execute_process(
        COMMAND ${POETRY_EXECUTABLE} install
        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    )

    file(WRITE "${CMAKE_BINARY_DIR}/poetry_installed" "")
endif()

function(struct_build INPUT OUTPUT)

    add_custom_command(
        OUTPUT ${OUTPUT}
        COMMAND ${POETRY_EXECUTABLE} run structgen build
                --file ${INPUT}
                --out ${OUTPUT}
        WORKING_DIRECTORY ${structgen_SOURCE_DIR}
        DEPENDS ${INPUT}
        VERBATIM
    )

endfunction()

function(struct_all_build INPUT_DIR OUTPUT_DIR)

    file(GLOB STRUCT_FILES "${INPUT_DIR}/*.st")

    add_custom_target(all_structs ALL)

    foreach(FILE ${STRUCT_FILES})

        get_filename_component(NAME ${FILE} NAME_WE)
        set(OUT_FILE ${OUTPUT_DIR}/${NAME}.h)

        struct_build(${FILE} ${OUT_FILE})

        add_custom_target(struct_${NAME} DEPENDS ${OUT_FILE})

        add_dependencies(all_structs struct_${NAME})

    endforeach()

endfunction()