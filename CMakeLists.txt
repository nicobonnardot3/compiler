cmake_minimum_required(VERSION 3.25)
project(compiler)

set(CMAKE_CXX_STANDARD 14)

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
SET(FlexOutput ${CMAKE_SOURCE_DIR}/src/lex.yy.c src/callTree/CallTree.h src/callTree/CallTree.c)
IF(FLEX_FOUND)
    ADD_CUSTOM_COMMAND(
            OUTPUT ${FlexOutput}
            COMMAND ${FLEX_EXECUTABLE}
            --outfile=${FlexOutput}
            ${CMAKE_SOURCE_DIR}/src/ANSI-C.l
            COMMENT "Generating lex scanner"
    )
ENDIF()

add_executable("${PROJECT_NAME}"
        src/hashTable/HashTable.c
        src/hashTable/HashTable.h
        src/callTree/CallTree.c
        src/callTree/CallTree.h
        ${BisonOutput}
        ${FlexOutput})

install(TARGETS ${PROJECT_NAME} DESTINATION bin)