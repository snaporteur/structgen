cmake_minimum_required(VERSION 3.10)

find_program(POETRY poetry REQUIRED)

exec_program(
    COMMAND ${POETRY} install
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
)

function(struct_build INPUT OUTPUT)
    add_custom_command(
        OUTPUT ${OUTPUT}
        COMMAND ${POETRY_EXECUTABLE} run structgen build --file ${INPUT} --out ${OUTPUT}
        DEPENDS ${INPUT}
    )
endfunction()