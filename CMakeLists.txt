cmake_minimum_required(VERSION 3.25)
project(compiler)

set(CMAKE_CXX_STANDARD 14)

enable_testing()
include_directories(src)
include_directories(src/hashTable)
include_directories(src/callTree)

FIND_PACKAGE(BISON REQUIRED)
SET(BisonOutput ${CMAKE_SOURCE_DIR}/src/y.tab.c)
IF(BISON_FOUND)
    ADD_CUSTOM_COMMAND(
            OUTPUT ${BisonOutput}
            COMMAND ${BISON_EXECUTABLE}
            --defines=${CMAKE_SOURCE_DIR}/src/y.tab.h
            --output=${BisonOutput}
            ${CMAKE_SOURCE_DIR}/src/miniC.y
            COMMENT "Generating yacc parser"
    )
ENDIF()

FIND_PACKAGE(FLEX REQUIRED)
SET(FlexOutput ${CMAKE_SOURCE_DIR}/src/lex.yy.c)
IF(FLEX_FOUND)
    ADD_CUSTOM_COMMAND(
            OUTPUT ${FlexOutput}
            COMMAND ${FLEX_EXECUTABLE}
            --outfile=${FlexOutput}
            ${CMAKE_SOURCE_DIR}/src/ANSI-C.l
            COMMENT "Generating lex scanner"
    )
ENDIF()

set (CMAKE_C_FLAGS "-D_FORTIFY_SOURCE=2 -Wno-int-conversion -Wformat -Wunused-function -fasynchronous-unwind-tables -fstack-clash-protection -O2 -Wall")

add_executable("${PROJECT_NAME}"
        src/main.c
        src/hashTable/HashTable.c
        src/hashTable/HashTable.h
        src/callTree/CallTree.c
        src/callTree/CallTree.h
        ${BisonOutput}
        ${FlexOutput})

add_test(NAME add COMMAND ${PROJECT_NAME} ${CMAKE_SOURCE_DIR}/tests/add.c)
add_test(NAME break COMMAND ${PROJECT_NAME} ${CMAKE_SOURCE_DIR}/tests/break.c)
add_test(NAME compteur COMMAND ${PROJECT_NAME} ${CMAKE_SOURCE_DIR}/tests/compteur.c)
add_test(NAME cond COMMAND ${PROJECT_NAME} ${CMAKE_SOURCE_DIR}/tests/cond.c)
add_test(NAME div COMMAND ${PROJECT_NAME} ${CMAKE_SOURCE_DIR}/tests/div.c)
add_test(NAME expr COMMAND ${PROJECT_NAME} ${CMAKE_SOURCE_DIR}/tests/expr.c)
add_test(NAME functions COMMAND ${PROJECT_NAME} ${CMAKE_SOURCE_DIR}/tests/functions.c)
add_test(NAME loops COMMAND ${PROJECT_NAME} ${CMAKE_SOURCE_DIR}/tests/loops.c)
add_test(NAME lsh COMMAND ${PROJECT_NAME} ${CMAKE_SOURCE_DIR}/tests/lsh.c)
add_test(NAME mul COMMAND ${PROJECT_NAME} ${CMAKE_SOURCE_DIR}/tests/mul.c)
add_test(NAME neg COMMAND ${PROJECT_NAME} ${CMAKE_SOURCE_DIR}/tests/neg.c)
add_test(NAME rsh COMMAND ${PROJECT_NAME} ${CMAKE_SOURCE_DIR}/tests/rsh.c)
add_test(NAME sub COMMAND ${PROJECT_NAME} ${CMAKE_SOURCE_DIR}/tests/sub.c)
add_test(NAME tableaux COMMAND ${PROJECT_NAME} ${CMAKE_SOURCE_DIR}/tests/tableaux.c)
add_test(NAME vars COMMAND ${PROJECT_NAME} "${CMAKE_SOURCE_DIR}/tests/variables.c")
add_test(NAME tableaux-multi COMMAND ${PROJECT_NAME} ${CMAKE_SOURCE_DIR}/tests/tableaux-multi.c)

install(TARGETS ${PROJECT_NAME} DESTINATION bin)