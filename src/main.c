#include "functionHashTable/functionHashTable.h"
#include "hashTable/HashTable.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// ----- Vars -----
HashTableList *hashTableList;
FunctionHashTable *functionHashTable;

int *nodeIndex;
char *inputfile;
char *outputFile;
FunctionError *functionError;

// ----- lex/yacc -----
extern FILE *yyin;
int yyparse();
void yyerror(char const *s);

// ----- Utils -----
int processParsing();
int parseOperation(int a, int b, char *op);
void parseArgs(int argc, char **argv);


int main(int argc, char **argv) {
    // ----- Parse args -----
    parseArgs(argc, argv);

    // ----- Init vars -----
    nodeIndex = malloc(sizeof(int));
    *nodeIndex = 1;

    HashTable *varHashTable = (HashTable *) malloc(sizeof(HashTable));
    functionHashTable = (FunctionHashTable *) malloc(sizeof(FunctionHashTable));
    *functionHashTable = createFunctionHashTable();

    *varHashTable = create_table(50000);
    varHashTable->prev = NULL;
    hashTableList = (HashTableList *) malloc(sizeof(HashTableList));
    hashTableList->currentScope = varHashTable;
    hashTableList->size = 1;

    processParsing();

    printf("\033[1;32mCompiled successfully!\033[0m\n");
}

int processParsing() { return yyparse(); }

void printfHelpMessage() {
    printf("Usage: ./minigcc <input file> [output file]\n");
    printf("\tOutput file defaults to output.dot\n");
    printf("\tExample: ./minigcc test.c out.dot\n");
}

void parseArgs(int argc, char **argv) {
    if (argc == 1) {
        printf("\033[1;31mError: no input file specified\033[0m\n");
        printfHelpMessage();
        exit(1);
    }

    if (argc > 1) {
        if (strcmp(argv[1], "-h") == 0 || strcmp(argv[1], "--help") == 0) {
            printfHelpMessage();
            exit(0);
        } else if (strcmp(argv[1], "-v") == 0 || strcmp(argv[1], "--version") == 0) {
            printf("minigcc version 1.0.0\n");
            exit(0);
        }

        FILE *file = fopen(argv[1], "r");

        if (!file) {
            printf("\033[1;31mError: file not found\033[0m\n");
            exit(1);
        }

        yyin = file;
    }

    if (argc > 2) outputFile = argv[2];
    else
        outputFile = "output.dot";

    inputfile = argv[1];
}


int parseOperation(int a, int b, char *op) {
    if (strcmp("+", op) == 0) return a + b;
    if (strcmp("-", op) == 0) return a - b;
    if (strcmp("*", op) == 0) return a * b;
    if (strcmp("/", op) == 0) {
        if (b == 0) {
            char *error = (char *) malloc(sizeof(char) * 40);
            sprintf(error, "Error : divide by zero");
            yyerror(error);
        }
        return a / b;
    }
    if (strcmp("<<", op) == 0) return a << b;
    if (strcmp(">>", op) == 0) return a >> b;
    if (strcmp("&", op) == 0) return a & b;
    if (strcmp("|", op) == 0) return a | b;
    return 0;
}

void yyerror(char const *s) {
    extern int yylineno;
    extern int column;
    fprintf(stderr, "\033[1;31m%s: \e[0;31m\n\tat %s:%d:%d\n", s, inputfile, yylineno, column);
    fclose(yyin);
    exit(1);
}

void createError(char *error) { yyerror(error); }

void createFunctionError(char *error, int lineno, int column) {
    fprintf(stderr, "\033[1;31m%s: \e[0;31m\n\tat %s:%d:%d\n", error, inputfile, lineno, column);
    fclose(yyin);
    exit(1);
}
