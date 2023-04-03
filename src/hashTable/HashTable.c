#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "HashTable.h"

#define CAPACITY 50000 // Size of the HashTable.

unsigned long hash_function(char* str)
{
    unsigned long i = 0;

    for (int j = 0; str[j]; j++)
        i += str[j];

    return i % CAPACITY;
}

Ht_item* create_item(char* key, int value)
{
    // Creates a pointer to a new HashTable item.
    Ht_item* item = (Ht_item*) malloc(sizeof(Ht_item));
    item->key = (char*) malloc(strlen(key) + 1);
    item->value = (int) malloc(sizeof(int));
    strcpy(item->key, key);
    item->value = value;
    return item;
}

HashTable* create_table(int size)
{
    // Creates a new HashTable.
    HashTable* table = (HashTable*) malloc(sizeof(HashTable));
    table->size = size;
    table->count = 0;
    table->items = (Ht_item**) calloc(table->size, sizeof(Ht_item*));

    for (int i = 0; i < table->size; i++)
        table->items[i] = NULL;

    printf("Created HashTable with size %d and count %d", table->size, table->count);     

    return table;
}

void free_item(Ht_item* item)
{
    // Frees an item.
    free(item->key);
    free(item->value);
    free(item);
}

void free_table(HashTable* table)
{
    // Frees the table.
    for (int i = 0; i < table->size; i++)
    {
        Ht_item* item = table->items[i];

        if (item != NULL)
            free_item(item);
    }

    free(table->items);
    free(table);
}

void print_table(HashTable* table)
{
    printf("\nHash Table\n-------------------\n");

    printf("Size:%d, Count:%d \n", table->size, table->count);

    for (int i = 0; i < table->size; i++)
    {
        if (table->items[i])
        {
            printf("Index:%d, Key:%s, Value:%s\n", i, table->items[i] -> key, table->items[i]->value);
            continue;
        }
        
    }

    printf("-------------------\n\n");
}

void print_item(Ht_item* item)
{
    printf("\nHash Table Item\n-------------------\n");

    if (item != NULL) {
        printf("Key:%s, Value:%d\n", item->key, item->value);
    }
    else {
        printf("Item is NULL\n");
    }

    printf("-------------------\n\n");
}
