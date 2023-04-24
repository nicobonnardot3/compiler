#include "hashTable/HashTable.h"
#include "callTree/CallTree.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// ----- Vars -----
CallTree *callTree;
HashTable *varHashTable;
HashTable *functionHashTable;
int *list_index;

// ----- lex/yacc -----
int yyparse();
void yyerror(char const *s);

// ----- Utils -----
int processParsing();
int parseOperation(int a, int b, char *op);
void extractTableVar(char *str, char *input);
void extractVarIndex(char *str, int *index, char** src);

int main(void) {
    list_index = malloc(sizeof(int));
    *list_index = -1;

    varHashTable = (HashTable *) malloc(sizeof(HashTable));
    create_table(varHashTable, 50000);

    functionHashTable = (HashTable *) malloc(sizeof(HashTable));
    create_table(functionHashTable, 50000);

    // --------- Test Hash Table ---------
//    createVar(varHashTable, "a", "int");
//    updateVar(varHashTable, "a", 10);
//
//    createList(varHashTable, "testList", 10);
//    updateListVar(varHashTable, "testList", 1, 5);
//
//    unsigned long index = getIndex(varHashTable, "testList");
//
//    Ht_item* item = varHashTable->items[index];
//    print_item(item);

//    char str[255] = "";
//    int *index = (int *) malloc(sizeof(int));
//    char x[255] = "a,-1";
//    extractVarIndex(str, index, x);

    // --------- Test Call Tree ---------
//    CallTree *child = (CallTree *) malloc(sizeof(CallTree));
//    createCallTree(child, "child1");
//    addCode(child, "main");
//    addValue(child, 0);
//
//    CallTree *parent = (CallTree *) malloc(sizeof(CallTree));
//    createCallTree(parent, "Parent");
//
//    addParent(child, parent);
//    printTree(child);

    processParsing();
}

int processParsing() {
    return yyparse();
}

void extractVarName(char *dest, char *str) {
    int i = 0;
    while (str[i] != '=' && str[i] != ' ' && str[i] != ';' && str[i] != '[' && str[i] != ']' && str[i] != '\0') {
        i++;
    }
    strncat(dest, str, i);
}

void extractTableVar(char *str, char *input) {
    int i = 0;
    while (input[i] != '[') i++;
    int j = i;
    while (input[j] != ']') j++;

    char *indexString = malloc(sizeof j - i + 1);
    strncpy(indexString, input + i + 1, j - i + 1);
    strncpy(str, input, i);
    strcat(str, ",");
    strcat(str, indexString);
}

void extractVarIndex(char *str, int *index, char** src) {
    char newSrc[255];
    printf("src: %s\n", *src);
    strcpy(newSrc, *src);

    printf("newSrc = %s", newSrc);
    strcpy(str, strtok(newSrc, ","));
    *index = atoi(strtok(NULL, ","));

    printf("str: %s; index: %d\n", str, *index);
}

char *removeUnwantedChar(char *str) {
    if (str[strlen(str) - 1] == ';' || str[strlen(str) - 1] == ',') {
        str[strlen(str) - 1] = '\0';
    }
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