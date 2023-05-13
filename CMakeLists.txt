cmake_minimum_required(VERSION 3.18)
project(minigcc)

enable_testing()
include_directories(src)
include_directories(src/hashTable)
include_directories(src/callTree)

FIND_PACKAGE(BISON REQUIRED)
SET(BisonOutput ${CMAKE_SOURCE_DIR}/src/y.tab.c)
IF(BISON_FOUND)
    ADD_CUSTOM_COMMAND(
            OUTPUT ${BisonOutput}
            COMMAND ${BISON_EXECUTABLE} -Wno-yacc -Wno-conflicts-sr
            --defines=${CMAKE_SOURCE_DIR}/src/y.tab.h
            --output=${BisonOutput}
            ${CMAKE_SOURCE_DIR}/src/miniC.y
            COMMENT "Building yacc parser"
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
            COMMENT "Building lex scanner"
    )
ENDIF()

set (CMAKE_C_FLAGS "-Wall -Wno-return-type -Wno-unused-function -Wno-int-conversion -Wformat -D_FORTIFY_SOURCE=2 -fasynchronous-unwind-tables -fstack-clash-protection -O2")

set(TEST_OUT_DIR ${CMAKE_SOURCE_DIR}/testsResults)
set(TEST_OUT_DIR_DEFAULT ${TEST_OUT_DIR}/tests)
set(TEST_OUT_DIR_MY ${TEST_OUT_DIR}/myTests)

file(MAKE_DIRECTORY ${TEST_OUT_DIR})
file(MAKE_DIRECTORY ${TEST_OUT_DIR_DEFAULT})
file(MAKE_DIRECTORY ${TEST_OUT_DIR_MY})

add_executable("${PROJECT_NAME}"
        src/main.c
        src/hashTable/HashTable.c
        src/hashTable/HashTable.h
        src/callTree/CallTree.c
        src/callTree/CallTree.h
        src/functionHashTable/functionHashTable.c
        ${BisonOutput}
        ${FlexOutput})

add_test(NAME vars COMMAND ${PROJECT_NAME} "${CMAKE_SOURCE_DIR}/tests/variables.c")
add_test(NAME add COMMAND ${PROJECT_NAME} ${CMAKE_SOURCE_DIR}/tests/add.c ${TEST_OUT_DIR_DEFAULT}/add.dot)
add_test(NAME sub COMMAND ${PROJECT_NAME} ${CMAKE_SOURCE_DIR}/tests/sub.c ${TEST_OUT_DIR_DEFAULT}/sub.dot)
add_test(NAME lsh COMMAND ${PROJECT_NAME} ${CMAKE_SOURCE_DIR}/tests/lsh.c ${TEST_OUT_DIR_DEFAULT}/lsh.dot)
add_test(NAME rsh COMMAND ${PROJECT_NAME} ${CMAKE_SOURCE_DIR}/tests/rsh.c ${TEST_OUT_DIR_DEFAULT}/rsh.dot)
add_test(NAME neg COMMAND ${PROJECT_NAME} ${CMAKE_SOURCE_DIR}/tests/neg.c ${TEST_OUT_DIR_DEFAULT}/neg.dot)
add_test(NAME mul COMMAND ${PROJECT_NAME} ${CMAKE_SOURCE_DIR}/tests/mul.c ${TEST_OUT_DIR_DEFAULT}/mul.dot)
add_test(NAME div COMMAND ${PROJECT_NAME} ${CMAKE_SOURCE_DIR}/tests/div.c ${TEST_OUT_DIR_DEFAULT}/div.dot)
add_test(NAME expr COMMAND ${PROJECT_NAME} ${CMAKE_SOURCE_DIR}/tests/expr.c ${TEST_OUT_DIR_DEFAULT}/expr.dot)
add_test(NAME cond COMMAND ${PROJECT_NAME} ${CMAKE_SOURCE_DIR}/tests/cond.c ${TEST_OUT_DIR_DEFAULT}/cond.dot)
add_test(NAME loops COMMAND ${PROJECT_NAME} ${CMAKE_SOURCE_DIR}/tests/loops.c ${TEST_OUT_DIR_DEFAULT}/loops.dot)
add_test(NAME compteur COMMAND ${PROJECT_NAME} ${CMAKE_SOURCE_DIR}/tests/compteur.c ${TEST_OUT_DIR_DEFAULT}/compteur.dot)
add_test(NAME break COMMAND ${PROJECT_NAME} ${CMAKE_SOURCE_DIR}/tests/break.c ${TEST_OUT_DIR_DEFAULT}/break.dot)
add_test(NAME functions COMMAND ${PROJECT_NAME} ${CMAKE_SOURCE_DIR}/tests/functions.c ${TEST_OUT_DIR_DEFAULT}/functions.dot)
add_test(NAME tableaux_error COMMAND ${PROJECT_NAME} ${CMAKE_SOURCE_DIR}/tests/tableaux.c ${TEST_OUT_DIR_DEFAULT}/tableaux.dot)
add_test(NAME tableaux-multi COMMAND ${PROJECT_NAME} ${CMAKE_SOURCE_DIR}/tests/tableaux-multi.c ${TEST_OUT_DIR_DEFAULT}/tableaux-multi.dot)

set_tests_properties(tableaux_error PROPERTIES WILL_FAIL TRUE)

# my tests

# variables
add_test(NAME my_vars COMMAND ${PROJECT_NAME} "${CMAKE_SOURCE_DIR}/myTests/variables/variables.c" "${TEST_OUT_DIR_MY}/variables.dot")
add_test(NAME my_vars_error_1 COMMAND ${PROJECT_NAME} "${CMAKE_SOURCE_DIR}/myTests/variables/variables-error-1.c" "${TEST_OUT_DIR_MY}/variables-error-1.dot")
add_test(NAME my_vars_error_2 COMMAND ${PROJECT_NAME} "${CMAKE_SOURCE_DIR}/myTests/variables/variables-error-2.c" "${TEST_OUT_DIR_MY}/variables-error-2.dot")
add_test(NAME my_vars_bloc_error_1 COMMAND ${PROJECT_NAME} "${CMAKE_SOURCE_DIR}/myTests/variables/variables-bloc-error-1.c" "${TEST_OUT_DIR_MY}/variables-bloc-error-1.dot")
add_test(NAME my_vars_bloc_error_2 COMMAND ${PROJECT_NAME} "${CMAKE_SOURCE_DIR}/myTests/variables/variables-bloc-error-2.c" "${TEST_OUT_DIR_MY}/variables-bloc-error-2.dot")
set_tests_properties(my_vars_error_1 PROPERTIES WILL_FAIL TRUE)
set_tests_properties(my_vars_error_2 PROPERTIES WILL_FAIL TRUE)
set_tests_properties(my_vars_bloc_error_1 PROPERTIES WILL_FAIL TRUE)
set_tests_properties(my_vars_bloc_error_2 PROPERTIES WILL_FAIL TRUE)

# expressions
add_test(NAME my_expr COMMAND ${PROJECT_NAME} ${CMAKE_SOURCE_DIR}/myTests/expressions/expression.c ${TEST_OUT_DIR_MY}/expression.dot)
add_test(NAME my_expr_error COMMAND ${PROJECT_NAME} ${CMAKE_SOURCE_DIR}/myTests/expressions/expression-error.c ${TEST_OUT_DIR_MY}/expression-error.dot)
set_tests_properties(my_expr_error PROPERTIES WILL_FAIL TRUE)

# loops
add_test(NAME my_loops COMMAND ${PROJECT_NAME} ${CMAKE_SOURCE_DIR}/myTests/loops/loops.c ${TEST_OUT_DIR_MY}/loops.dot)


# tableaux
add_test(NAME my_tableaux COMMAND ${PROJECT_NAME} ${CMAKE_SOURCE_DIR}/myTests/tableaux/tab.c ${TEST_OUT_DIR_MY}/tab.dot)
add_test(NAME my_tableaux_multi COMMAND ${PROJECT_NAME} ${CMAKE_SOURCE_DIR}/myTests/tableaux/tab-multi.c ${TEST_OUT_DIR_MY}/tab-multi.dot)

# functions
add_test(NAME my_functions COMMAND ${PROJECT_NAME} ${CMAKE_SOURCE_DIR}/myTests/functions/functions.c ${TEST_OUT_DIR_MY}/functions.dot)
add_test(NAME my_function_not_exists_error COMMAND ${PROJECT_NAME} "${CMAKE_SOURCE_DIR}/myTests/functions/function-not-exists.c" "${TEST_OUT_DIR_MY}/function-not-exists.dot")
add_test(NAME my_function_too_many_args_error COMMAND ${PROJECT_NAME} ${CMAKE_SOURCE_DIR}/myTests/functions/function-too-many-args.c ${TEST_OUT_DIR_MY}/function-too-many-args.dot)
add_test(NAME my_function_too_few_args_error COMMAND ${PROJECT_NAME} ${CMAKE_SOURCE_DIR}/myTests/functions/function-too-few-args.c ${TEST_OUT_DIR_MY}/function-too-few-args.dot)
set_tests_properties(my_function_not_exists_error PROPERTIES WILL_FAIL TRUE)
set_tests_properties(my_function_too_many_args_error PROPERTIES WILL_FAIL TRUE)
set_tests_properties(my_function_too_few_args_error PROPERTIES WILL_FAIL TRUE)

install(TARGETS ${PROJECT_NAME} DESTINATION bin)