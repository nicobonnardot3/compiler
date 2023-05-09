#include "HashTable.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern HashTableList *hashTableList;

#define CAPACITY 50000

// hash function to get the index of the key
unsigned long hash_function(char *str) {
    unsigned long i = 0;

    for (int j = 0; str[j]; j++) i += str[j];

    return i % CAPACITY;
}

// Creates a new item to be inserted in the HashTable.
Ht_item create_item(char *key, char *type, int size) {
    Ht_item item;
    item.key = (char *) malloc(strlen(key) + 10);
    item.var = (Variable *) malloc(sizeof(Variable *));
    item.hasValue = 0;
    strcpy(item.key, key);
    Variable *var = item.var;
    var->type = type;
    if (strcmp(type, "int List") == 0) {
        var->size = sizeof(int) * size;
        var->value = (int *) calloc(size, sizeof(int));
    } else {
        var->size = sizeof(int);
        var->value = NULL;
    }
    return item;
}

// Creates a new HashTable.
HashTable create_table(int size) {
    HashTable table;
    table.size = size;
    table.count = 0;
    table.prev = NULL;
    table.items = (Ht_item **) calloc(size, sizeof(Ht_item *));

    for (int i = 0; i < table.size; i++) table.items[i] = NULL;
    return table;
}

// initialize a variable in the hash table's current scope
int initVar(char *key) {
    HashTable *table = hashTableList->currentScope;
    Ht_item *item = (Ht_item *) malloc(sizeof(Ht_item));
    *item = create_item(key, "int", 1);

    unsigned long index = hash_function(key);
    while (table->items[index] != NULL) index++;

    if (table->count >= table->size * 0.7 || index >= table->size) {
        table = (HashTable *) realloc(table, sizeof(HashTable) * table->size * 2);
    }

    printf("index: %lu\n", index);
    printf("table->size: %d\n", table->count);

    table->items[index] = item;
    table->count++;
    return index;
}

// initialize a list in the hash table's current scope
int initList(char *key, int *sizes) {
    HashTable *table = hashTableList->currentScope;
    Ht_item *item = (Ht_item *) malloc(sizeof(Ht_item));
    *item = create_item(key, "int List", sizes[0]);// TODO: add support for multiple dimensions

    unsigned long index = hash_function(key);
    while (table->items[index] != NULL) index++;

    if (table->count >= table->size * 0.7 || index >= table->size) {
        table = (HashTable *) realloc(table, sizeof(HashTable) * table->size * 2);
    }

    Ht_item *current_item = table->items[index];
    if (current_item == NULL) {
        table->items[index] = item;
        table->count++;
    } else {
        printf("Symbol \"%s\" already exists\n", key);
    }
    return index;
}

// Adds a new scope to the HashTableList.
void createScope() {
    HashTable *table = (HashTable *) malloc(sizeof(HashTable));
    *table = create_table(100);
    table->prev = hashTableList->currentScope;
    hashTableList->currentScope = table;
    hashTableList->size++;
}

// --------- update Functions ---------

// Updates the value of a variable in the HashTable.
int updateVar(char *str, int value) {
    HashTable *varScope = findScope(str);
    if (varScope == NULL) {
        printf("Symbol \"%s\" not found \n", str);
        return;
    }
    unsigned long index = getIndex(varScope, str);
    if (index == -1) return NULL;
    Ht_item *currentItem = varScope->items[index];

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
    return value;
}

// Updates the value of a list item in the HashTable.
int updateListVar(char *listKey, int index, int value) {
    HashTable *varScope = findScope(listKey);
    unsigned long tableIndex = getIndex(varScope, listKey);
    if (tableIndex == -1) return NULL;
    Ht_item *currentItem = varScope->items[tableIndex];

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
    if (var->value == NULL) {
        int *newList = (int *) calloc(size, sizeof(int));
        var->value = newList;
    }

    if (index >= size) {
        printf("index out of bounds");
        return;
    }

    int *list = var->value;
    list[index] = value;
    return value;
}


// --------- getter Functions ---------
// Returns the value of a variable in all scopes.
int symbolVal(char *str) {
    HashTable *table = findScope(str);

    unsigned long index = getIndex(table, str);
    if (index == -1) return NULL;
    Ht_item *currentItem = table->items[index];

    if (currentItem == NULL) return NULL;

    Variable *var = currentItem->var;
    if (var == NULL) return NULL;

    if (var->type != "int" || var->value == NULL) return NULL;
    return var->value;
}

// Returns the value of a list item in all scopes.
int tableValue(char *str, int index) {
    HashTable *table = findScope(str);
    unsigned long hashTableIndex = getIndex(table, str);
    if (hashTableIndex == -1) return NULL;
    Ht_item *currentItem = table->items[hashTableIndex];

    if (currentItem == NULL) return NULL;

    Variable *var = currentItem->var;
    if (var == NULL) return NULL;

    int size = var->size / sizeof(int);

    if (var->type != "int List" || var->value == NULL || index >= size) return NULL;

    int *value = var->value;
    return value[index];
}

// Returns the index of a variable in the HashTable.
unsigned long getIndex(HashTable *table, char *key) {
    unsigned long index = hash_function(key);
    while (table->items[index] != NULL && strcmp(table->items[index]->key, key) != 0) {
        index++;
        if (index >= table->size) index = -1;
    }

    return index;
}


// --------- Free Functions ---------
// Frees a variable.
void free_var(Variable *var) {
    free(var->value);
    free(var->size);
    free(var->type);
    free(var);
}

// Frees an item.
void free_item(Ht_item *item) {
    // Frees an item.
    free(item->key);
    free_var(item->var);
    free(item);
}

// Frees a HashTable.
void free_table(HashTable *table) {
    for (int i = 0; i < table->size; i++) {
        Ht_item *item = table->items[i];

        if (item != NULL) free_item(item);
    }

    free(table->items);
    free(table);
}


// --------- Scope Functions ---------

// Finds the scope of a variable.
HashTable *findScope(char *str) {
    HashTable *table = hashTableList->currentScope;
    while (table != NULL) {
        unsigned long index = getIndex(table, str);
        Ht_item *currentItem = table->items[index];

        if (currentItem != NULL) return table;

        table = table->prev;
    }
    return NULL;
}

// Deletes the current scope.
void deleteScope() {
    if (hashTableList->currentScope->prev != NULL) {
        free_table(hashTableList->currentScope);
        hashTableList->currentScope = hashTableList->currentScope->prev;
    }
}

// --------- Print Functions ---------
// Prints the given table
void print_table(HashTable *table) {
    printf("------------------- Hash Table -------------------\n");

    printf("Size: %d, Count: %d \n", table->size, table->count);

    for (int i = 0; i < table->size; i++) {
        Ht_item *item = table->items[i];
        if (item == NULL) continue;

        Variable *var = item->var;
        int value = var->value;
        if (strcmp(var->type, "int") == 0)
            printf("Index: %d, Key: %s, type: %s, value: %d\n", i, item->key, var->type, value);
        else
            print_item(item);
    }

    printf("--------------------------------------------------\n");
}

// Prints the given item
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
        printf("----------------- item ----------------- \n   key: %s\n   value: "
               "%d\n----------------------------------------\n",
               item->key, *(value));
        return;
    }
    int size = var->size / sizeof(int);
    int *list = var->value;
    printf("----------------- table item -----------------\n");
    printf("Key: %s, size: %d\n", item->key, size);
    for (int i = 0; i < size; i++) printf("Index: %d, value: %d\n", i, *(list + i));

    printf("----------------------------------------\n");
}
