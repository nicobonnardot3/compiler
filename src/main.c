#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "hashTable/HashTable.h"

HashTable *hashTable;

int processParsing();

int parseOperation(int a, int b, char op);

void createSymbol(HashTable *table, char *key);

void updateSymbol(char *str, int val);

int symbolVal(char *str);

int yyparse();

void yyerror(char const *s);

extern void print_table(HashTable *table);

extern unsigned long hash_function(char *str);

extern void create_table(HashTable *table, int size);

extern void create_item(Ht_item *item, char *key, int value);

extern void free_item(Ht_item *item);


int main(void) {
    hashTable = (HashTable *) malloc(sizeof(HashTable));
    create_table(hashTable, 50000);
//    createSymbol(hashTable, "testSymbol");

    processParsing();
}

int processParsing() {
    return yyparse();
}

void createSymbol(HashTable *table, char *key) {
    Ht_item *item = (Ht_item *) malloc(sizeof(Ht_item));
    create_item(item, key, 0);

    // Computes the index.
    int index = hash_function(key);

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

void updateSymbol(char *str, int val) {
    printf("Updating symbol \n");

    int index = hash_function(str);
    Ht_item *current_item = hashTable->items[index];
    if (current_item != NULL) {
        printf("Symbol not found \n");
        return;
    }

    current_item->value = val;
}

int symbolVal(char *str) {
    int index = hash_function(str);
    Ht_item *current_item = hashTable->items[index];

    if (current_item != NULL) {
        if (strcmp(current_item->key, str) == 0)
            return current_item->value;
    }

    return NULL;
}

void yyerror(char const *s) {
    fprintf(stderr, "%s\n", s);
}


int parseOperation(int a, int b, char op) {
    switch (op) {
        case '+':
            return a + b;
        case '-':
            return a - b;
        case '*':
            return a * b;
        case '/':
            return a / b;
        case '<<':
            return a << b;
        case '>>':
            return a >> b;
        case '&':
            return a & b;
        case '|':
            return a | b;

        case '&&':
            return a && b;
        case '||':
            return a || b;

        case '<':
            return a < b;
        case '>':
            return a > b;
        case '>=':
            return a >= b;
        case '<=':
            return a <= b;
        case '==':
            return a == b;
        case '!=':
            return a != b;
        default:
            return 0;
    }
}