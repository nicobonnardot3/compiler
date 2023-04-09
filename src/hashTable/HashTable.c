#include "HashTable.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define CAPACITY 50000// Size of the HashTable.

void print_table(HashTable *table);

unsigned long hash_function(char *str) {
    unsigned long i = 0;

    for (int j = 0; str[j]; j++)
        i += str[j];

    return i % CAPACITY;
}

void create_item(Ht_item *item, char *key) {
    item->key = (char *) malloc(strlen(key) + 1);
    item->value = () malloc(sizeof(int));
    strcpy(item->key, key);
    item->value = NULL;
}

void create_table(HashTable *table, int size) {
    table->size = size;
    table->count = 0;
    table->items = (Ht_item **) calloc(size, sizeof(Ht_item *));

    for (int i = 0; i < table->size; i++)
        table->items[i] = NULL;
}

void free_item(Ht_item *item) {
    // Frees an item.
    free(item->key);
    free(item->value);
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
    printf("\n-------------------\nHash Table\n");

    printf("Size: %d, Count: %d \n", table->size, table->count);

    for (int i = 0; i < table->size; i++) {
        if (table->items[i]) {
            printf("Index: %d, Key: \"%s\", Value: %d\n", i, table->items[i]->key, table->items[i]->value);
            continue;
        }
    }

    printf("-------------------\n\n");
}