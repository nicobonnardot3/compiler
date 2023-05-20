#include "functionHashTable/functionHashTable.h"
#include "hashTable/HashTable.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

// ----- Vars -----
HashTableList *hashTableList;
FunctionHashTable *functionHashTable;

int *nodeIndex;
char *inputfile;
char *outputFile;
char cwd[255];
int topdf = 0;
FunctionError *functionError;

// ----- lex/yacc -----
extern FILE *yyin;
int yyparse();
void yyerror(char const *s);

// ----- Utils -----
int parseOperation(int a, int b, char *op);
void parseArgs(int argc, char **argv);
void printfHelpMessage();
void createError(char *error);
void createFunctionError(char *error, int lineno, int column);
void outputToPdf();


int main(int argc, char **argv) {
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

    yyparse();

    printf("\033[1;32mCompiled successfully!\033[0m\n");


    if (topdf == 1) outputToPdf();

    return 0;
}

void printfHelpMessage() {
    printf("Usage: ./minigcc [options] <input file> [output file]\n\n");
    printf("\tOptions:\n");
    printf("\t\t-h, --help\t\tPrints this help message\n");
    printf("\t\t-v, --version\t\tPrints the version\n");
    printf("\t\t-toPdf\t\t\tConverts the output file to pdf\n\n");
    printf("\tOutput file defaults to output.dot\n");
    printf("\tExample: ./minigcc test.c out.dot\n");
}

void outputToPdf() {
    // ----- Output to pdf -----
    printf("\033[1;32mOutputing to pdf\033[0m\n");

    if (getcwd(cwd, sizeof(cwd)) == NULL) {
        printf("\033[1;31mError: could not get current working directory\033[0m\n");
        exit(1);
    }

    char *pdfOutputFile = malloc(sizeof(char) * (strlen(outputFile) + 5));
    strcpy(pdfOutputFile, outputFile);
    strtok(pdfOutputFile, ".");
    strcat(pdfOutputFile, ".pdf");

    char *command = malloc(sizeof(char) * (strlen(outputFile) + 100));
    sprintf(command, "dot -Tpdf %s -o %s", outputFile, pdfOutputFile);
    if (system(command) == -1) {
        printf("\033[1;31mError: could not convert to pdf\033[0m\n");
        exit(1);
    }

    printf("\033[1;32mOutputed to %s/%s\033[0m\n", cwd, pdfOutputFile);
}

void parseArgs(int argc, char **argv) {
    if (argc == 1) {
        printf("\033[1;31mError: no input file specified\033[0m\n");
        printfHelpMessage();
        exit(1);
    }

    int i = 1;
    if (argc > i) {
        if (argv[1][0] == '-') i++;
        if (strcmp(argv[1], "-h") == 0 || strcmp(argv[1], "--help") == 0) {
            printfHelpMessage();
            exit(0);
        } else if (strcmp(argv[1], "-v") == 0 || strcmp(argv[1], "--version") == 0) {
            printf("minigcc version 1.0.0\n");
            exit(0);
        } else if (strcmp(argv[1], "-toPdf") == 0) {
            topdf = 1;
        }

        FILE *file = fopen(argv[i], "r");
        if (!file) {
            printf("\033[1;31mError: file not found\033[0m\n");
            exit(1);
        }

        yyin = file;
    }

    if (argc > i + 1) outputFile = argv[i + 1];
    else
        outputFile = "output.dot";

    inputfile = argv[1];
}


int parseOperation(int a, int b, char *op) {
    if (strcmp("+", op) == 0) return a + b;
    if (strcmp("-", op) == 0) return a - b;
    if (strcmp("*", op) == 0) return a * b;
    if (strcmp("/", op) == 0) {
        if (b == 0) { yyerror("Error : divide by zero"); }
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
