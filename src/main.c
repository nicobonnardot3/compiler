#include "hashTable/HashTable.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

HashTable *hashTable;

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


int main(void) {
    hashTable = (HashTable *) malloc(sizeof(HashTable));
    create_table(hashTable, 50000);
    //    createSymbol(hashTable, "a");
    //    updateSymbol(hashTable, "a", 10);

    //    createList(varHashTable, "testList", 10);
    //
    processParsing();
}

int processParsing() {
    return yyparse();
}



void yyerror(char const *s) {
    fprintf(stderr, "%s\n", s);
}

void extractVarName(char *dest, char *str) {
    int i = 0;
    while (str[i] && str[i] != ' ' && str[i] != ';' && str[i] != '[' && str[i] != ']') {
        //    printf("%c: %b\n", str[i], str[i] && str[i] != ' ' && str[i] != ';');
        i++;
    }
    strncat(dest, str, i);
}

char *removeUnwantedChar(char *str) {
    if (str[strlen(str) - 1] == ';') {
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