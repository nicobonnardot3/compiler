#include "hashTable/HashTable.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

HashTable *hashTable;

int processParsing();

int parseOperation(int a, int b, char *op);

void createSymbol(HashTable *table, char *key);

void updateSymbol(HashTable *table, char *str, int val);

int symbolVal(char *str);

int yyparse();

void yyerror(char const *s);

extern void print_table(HashTable *table);

extern unsigned long hash_function(char *str);

extern void create_table(HashTable *table, int size);

extern void create_item(Ht_item *item, char *key);

extern void free_item(Ht_item *item);


int main(void) {
    hashTable = (HashTable *) malloc(sizeof(HashTable));
    create_table(hashTable, 50000);
    //    createSymbol(hashTable, "a");
    //    updateSymbol(hashTable, "a", 10);

    processParsing();
}

int processParsing() {
    return yyparse();
}

void createSymbol(HashTable *table, char *key) {
    Ht_item *item = (Ht_item *) malloc(sizeof(Ht_item));
    create_item(item, key);

    // Computes the index.
    unsigned long index = hash_function(key);

    Ht_item *current_item = table->items[index];

    if (current_item == NULL) {
        // Key does not exist.
        if (table->count == table->size) {
            // HashTable is full.
            printf("Insert Error: Hash Table is full\n");
            free_item(item);
            return;
        }

        // Insert directly.
        table->items[index] = item;
        table->count++;
    }

    print_table(hashTable);
}

void updateSymbol(HashTable *table, char *str, int value) {
    printf("Updating symbol: \"%s\" with value: %d \n", str, value);

    unsigned long index = hash_function(str);
    Ht_item *current_item = table->items[index];
    if (current_item == NULL) {
        printf("Symbol not found \n");
        return;
    }

    current_item->value = value;
    print_table(hashTable);
}

int symbolVal(char *str) {
    unsigned long index = hash_function(str);
    Ht_item *current_item = hashTable->items[index];

    if (current_item != NULL) {
        if (strcmp(current_item->key, str) == 0)
            return current_item->value;
    }

    return 0;
}

void yyerror(char const *s) {
    fprintf(stderr, "%s\n", s);
}

void extractVarName(char *dest, char *str) {
    int i = 0;
    while (str[i] && str[i] != ' ') {
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
    if (strcmp("+", op) != 0) return a + b;
    if (strcmp("-", op) != 0) return a - b;
    if (strcmp("*", op) != 0) return a * b;
    if (strcmp("/", op) != 0) return a / b;
    if (strcmp("<<", op) != 0) return a << b;
    if (strcmp(">>", op) != 0) return a >> b;
    if (strcmp("&", op) != 0) return a & b;
    if (strcmp("|", op) != 0) return a | b;
    if (strcmp("&&", op) != 0) return a && b;
    if (strcmp("||", op) != 0) return a || b;
    if (strcmp("<", op) != 0) return a < b;
    if (strcmp(">", op) != 0) return a > b;
    if (strcmp(">=", op) != 0) return a >= b;
    if (strcmp("<=", op) != 0) return a <= b;
    if (strcmp("==", op) != 0) return a == b;
    if (strcmp("!=", op) != 0) return a != b;
    return 0;
}