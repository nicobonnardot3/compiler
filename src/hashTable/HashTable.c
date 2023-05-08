#include "HashTable.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define CAPACITY 50000

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
    if (strcmp(type, "int List") == 0) {
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
        int value = var->value;
        if (strcmp(var->type, "int") == 0) printf("Index: %d, Key: %s, type: %s, value: %d\n", i, item->key, var->type, value);
        else
            print_item(item);
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

    if (strcmp(var->type, "int") == 0) {
        int *value = var->value;
        printf("----------------- item ----------------- \n   key: %s\n   value: %d\n----------------------------------------\n", item->key, *(value));
        return;
    }
    int size = var->size / sizeof(int);
    int *list = var->value;
    printf("----------------- table item -----------------\n");
    printf("Key: %s, size: %d\n", item->key, size);
    for (int i = 0; i < size; i++)
        printf("Index: %d, value: %d\n", i, *(list + i));

    printf("----------------------------------------\n");
}

void createVar(HashTable *table, char *key, char *type) {
    if (table->count == table->size) {
        printf("Insert Error: Hash Table is full\n");
        return;
    }

    Ht_item *item = (Ht_item *) malloc(sizeof(Ht_item));
    create_item(item, key, type, 1);

    unsigned long index = hash_function(key);

    while (table->items[index] != NULL)
        index++;

    table->items[index] = item;
    table->count++;

    print_table(table);
}

void createList(HashTable *table, char *key, int size) {
    Ht_item *item = (Ht_item *) malloc(sizeof(Ht_item));
    create_item(item, key, "int List", size);


    if (item == NULL) return;

    // Computes the index.
    unsigned long index = hash_function(key);

    while (table->items[index] != NULL)
        index++;


    Ht_item *current_item = table->items[index];
    if (current_item == NULL) {
        table->items[index] = item;
        table->count++;
    }

    print_table(table);
}

void updateVar(HashTable *table, char *str, int value) {
    printf("Updating symbol: \"%s\" with value: %d \n", str, value);

    unsigned long index = getIndex(table, str);
    Ht_item *currentItem = table->items[index];

    if (currentItem == NULL) {
        printf("Symbol not found \n");
        return;
    }

    Variable *var = currentItem->var;
    if (var == NULL) {
        printf("var \"%s\" is NULL", str);
        return;
    }

    var->value = value;
    //    print_table(table);
}

void updateListVar(HashTable *table, char *listKey, int index, int value) {
    printf("Updating %s[%d] with value: %d\n", listKey, index, value);

    unsigned long tableIndex = getIndex(table, listKey);
    Ht_item *currentItem = table->items[tableIndex];

    if (currentItem == NULL) {
        printf("item is NULL");
        return;
    }

    Variable *var = currentItem->var;

    if (var == NULL) {
        printf("variable for %s is NULL", currentItem->key);
        return;
    }

    int size = var->size / sizeof(int);
    if (var->value == 0) {
        int newList[size];
        var->value = *newList;
    }

    int *list = var->value;
    int *item = list + index;
    *item = value;

    print_table(table);
}

int symbolVal(HashTable *table, char *str) {
    unsigned long index = getIndex(table, str);
    Ht_item *currentItem = table->items[index];

    if (currentItem == NULL)
        return NULL;

    Variable *var = currentItem->var;
    if (var == NULL)
        return NULL;

    int *value = var->value;

    if (value == NULL) return 0;
    return *value;
}

int tableValue(HashTable *table, char *str, int index) {
    unsigned long hashTableIndex = getIndex(table, str);
    Ht_item *currentItem = table->items[hashTableIndex];

    if (currentItem == NULL)
        return NULL;

    Variable *var = currentItem->var;
    if (var == NULL)
        return NULL;

    int *x = var->value + index;
    return *x;
}

unsigned long getIndex(HashTable *table, char *key) {
    unsigned long index = hash_function(key);
    while (table->items[index] != NULL && strcmp(table->items[index]->key, key) != 0)
        index++;

    return index;
}