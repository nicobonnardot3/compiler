#include "HashTable.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define CAPACITY 50000// Size of the HashTable.

void createVar(HashTable *table, char *key, char *type);
void updateVar(HashTable *table, char *str, int val);
int symbolVal(HashTable *table, char *str);
void print_table(HashTable *table);

unsigned long hash_function(char *str) {
    unsigned long i = 0;

    for (int j = 0; str[j]; j++)
        i += str[j];

    return i % CAPACITY;
}

void create_item(Ht_item *item, char *key, char *type, int size) {
    item->key = (char *) malloc(strlen(key) + 1);
    item->var = (Variable *) malloc(sizeof(Variable *));
    strcpy(item->key, key);
    Variable *var = item->var;
    var->type = type;
    if (strcmp(type, "int list")) {
        var->size = sizeof(int) * size;
        var->value = (int *) malloc(size * sizeof(int));
    } else {
        var->size = sizeof(int);
        var->value = NULL;
    }
}

void create_table(HashTable *table, int size) {
    table->size = size;
    table->count = 0;
    table->items = (Ht_item **) calloc(size, sizeof(Ht_item *));

    for (int i = 0; i < table->size; i++)
        table->items[i] = NULL;
}

void free_var(Variable *var) {
    free(var->value);
    free(var->size);
    free(var->type);
    free(var);
}

void free_item(Ht_item *item) {
    // Frees an item.
    free(item->key);
    free_var(item->var);
    free(item);
}

void free_table(HashTable *table) {
    // Frees the table.
    for (int i = 0; i < table->size; i++) {
        Ht_item *item = table->items[i];

        if (item != NULL)
            free_item(item);
    }

    free(table->items);
    free(table);
}

void print_table(HashTable *table) {
    printf("------------------- Hash Table -------------------\n");

    printf("Size: %d, Count: %d \n", table->size, table->count);

    for (int i = 0; i < table->size; i++) {
        Ht_item *item = table->items[i];
        if (item == NULL) continue;

        Variable *var = item->var;
        printf("Index: %d, Key: %s, type: %s, size: %llu\n", i, item->key, var->type, (var->size / sizeof(int)));
    }

    printf("--------------------------------------------------\n");
}

void print_item(Ht_item *item) {
    if (item == NULL) {
        printf("item is NULL\n");
        return;
    }

    Variable *var = item->var;
    if (var == NULL) {
        printf("Item exists but isn't initialized");
        return;
    }

    printf("----------------- item ----------------- \n   key: %s\n   value: %d\n----------------------------------------\n", item->key, var->value);
}

void createVar(HashTable *table, char *key, char *type) {
    Ht_item *item = (Ht_item *) malloc(sizeof(Ht_item));
    create_item(item, key, "int", 1);

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

    print_table(table);
}

void createList(HashTable *table, char *key, int size) {
    Ht_item *item = (Ht_item *) malloc(sizeof(Ht_item));
    create_item(item, key, "int List", size);

    if (item == NULL) return;

    // Computes the index.
    unsigned long index = hash_function(key);

    Ht_item *current_item = table->items[index];
    if (current_item == NULL) {
        table->items[index] = item;
        table->count++;
    }

    print_table(table);
}

void updateVar(HashTable *table, char *str, int value) {
    printf("Updating symbol: \"%s\" with value: %d \n", str, value);

    unsigned long index = hash_function(str);
    Ht_item *current_item = table->items[index];
    if (current_item == NULL) {
        printf("Symbol not found \n");
        return;
    }

    Variable *var = current_item->var;
    if (var == NULL) {
        printf("var \"%s\" is NULL", str);
        return;
    }

    var->value = value;
    print_table(table);
}

int symbolVal(HashTable *table, char *str) {
    unsigned long index = hash_function(str);
    Ht_item *current_item = table->items[index];

    print_item(current_item);

    if (current_item == NULL) {
        return NULL;
    }
    if (strcmp(current_item->key, str) == 0) {
        Variable *var = current_item->var;
        if (var == NULL)
            return NULL;

        return current_item->var->value;
    }
}