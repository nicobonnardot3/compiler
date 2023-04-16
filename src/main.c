#include "hashTable/HashTable.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

HashTable *varHashTable;
HashTable *functionHashTable;
int *list_index;

int processParsing();

int parseOperation(int a, int b, char *op);

int yyparse();

void yyerror(char const *s);

extern void print_table(HashTable *table);

extern void print_item(Ht_item *item);

extern unsigned long hash_function(char *str);

extern void create_table(HashTable *table, int size);

extern void create_item(Ht_item *item, char *key);

extern void free_item(Ht_item *item);

extern void createVar(HashTable *table, char *key, char *type);

extern void updateVar(HashTable *table, char *str, int val);

extern int symbolVal(HashTable *table, char *str);

extern void createList(HashTable *table, char *key, int size);

extern void updateListVar(HashTable *table, char *listKey, int index, int value);

extern unsigned long getIndex(HashTable *table, char *key);


int main(void) {
    list_index = malloc(sizeof(int));

    varHashTable = (HashTable *) malloc(sizeof(HashTable));
    create_table(varHashTable, 50000);

    functionHashTable = (HashTable *) malloc(sizeof(HashTable));
    create_table(functionHashTable, 50000);


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

    processParsing();
}

int processParsing() {
    return yyparse();
}

void extractVarName(char *dest, char *str) {
    int i = 0;
    while (str[i] && str[i] != ' ' && str[i] != ';' && str[i] != '[' && str[i] != ']' && str[i] != '\0') {
        i++;
    }
    strncat(dest, str, i);
}

void extractTableVar(char *str, int *index, char *input) {
    int i = 0;
    while (input[i] != '[') i++;
    int j = i;
    while (input[j] != ']') j++;


    char *indexString = malloc(sizeof j - i + 1);
    strncpy(indexString, input + i + 1, j - i + 1);
    strncpy(str, input, i);
    *index = atoi(indexString);
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