#include "functionHashTable/functionHashTable.h"
#include "hashTable/HashTable.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// ----- Vars -----
CallTree *tree;
CallTree **declarationTree;
CallTree **functionTree;


HashTableList *hashTableList;
HashTable varHashTable;
FunctionHashTable *functionHashTable;

int *nodeIndex;
char *outputFile;

// ----- lex/yacc -----
extern FILE *yyin;
int yyparse();
void yyerror(char const *s);

// ----- Utils -----
int processParsing();
int parseOperation(int a, int b, char *op);
void extractTableVar(char *str, char *input);
void extractVarIndex(char *str, int *index, char **src);
void printList(CallTree **list);


int main(int argc, char **argv) {
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

    if (argc > 1) {
        FILE *file = fopen(argv[1], "r");

        if (!file) {
            printf("Error: file not found\n");
            return 1;
        }

        yyin = file;
    }

    if (argc > 2) {
        outputFile = (char *) malloc(sizeof(char) * (strlen(argv[2]) + 1));
        outputFile = argv[2];
    } else {
        outputFile = (char *) malloc(sizeof(char) * (strlen("output.dot") + 1));
        outputFile = "output.dot";
    }

    processParsing();

    printf("Compiled successfully\n");
}

int processParsing() { return yyparse(); }

char *extractVarName(char *str) {
    int i = 0;
    int size = strlen(str);
    if (size < 2) return str;
    while (i < size &&
           (str[i] != '=' && str[i] != ' ' && str[i] != ';' && str[i] != '[' && str[i] != ']' && str[i] != '\0' &&
            str[i] != ',' && str[i] != '(' && str[i] != ')' && str[i] != '{' && str[i] != '}' && str[i] != '+' &&
            str[i] != '-' && str[i] != '*' && str[i] != '/' && str[i] != '&' && str[i] != '|' && str[i] != '<' &&
            str[i] != '>' && str[i] != '!' && str[i] != '=' && str[i] != '\n')) {
        i++;
    }


    char *newStr = (char *) malloc(sizeof(char) * (i + 2));
    strncpy(newStr, str, i);

    newStr[i] = '\0';
    return newStr;
}

void extractTableVar(char *str, char *input) {
    int i = 0;
    while (input[i] != '[') i++;

    strncpy(str, input, i);
}

void extractVarIndex(char *str, int *index, char **src) {
    char newSrc[255];
    printf("src: %s\n", *src);
    strcpy(newSrc, *src);

    printf("newSrc = %s", newSrc);
    strcpy(str, strtok(newSrc, ","));
}

char *removeUnwantedChar(char *str) {
    if (str[strlen(str) - 1] == ';' || str[strlen(str) - 1] == ',') { str[strlen(str) - 1] = '\0'; }
    return str;
}

int parseOperation(int a, int b, char *op) {
    if (strcmp("+", op) == 0) return a + b;
    if (strcmp("-", op) == 0) return a - b;
    if (strcmp("*", op) == 0) return a * b;
    if (strcmp("/", op) == 0) return a / b;
    if (strcmp("<<", op) == 0) return a << b;
    if (strcmp(">>", op) == 0) return a >> b;
    if (strcmp("&", op) == 0) return a & b;
    if (strcmp("|", op) == 0) return a | b;
    if (strcmp("&&", op) == 0) return a && b;
    if (strcmp("||", op) == 0) return a || b;
    if (strcmp("<", op) == 0) return a < b;
    if (strcmp(">", op) == 0) return a > b;
    if (strcmp(">=", op) == 0) return a >= b;
    if (strcmp("<=", op) == 0) return a <= b;
    if (strcmp("==", op) == 0) return a == b;
    if (strcmp("!=", op) == 0) return a != b;
    return 0;
}

void yyerror(char const *s) {
    extern int yylineno;
    extern int column;
    fprintf(stderr, "%s: \n\tLine: %d\n\tColumn: %d \n", s, yylineno, column);
}

void printList(CallTree **list) {
    printf("-------- List --------\n");
    printf("List size: %lu\n", sizeof(list));
    int i = 0;
    while (list[i] != NULL) {
        printTree(list[i]);
        i++;
    }
    printf("-------- End List --------\n");
}
