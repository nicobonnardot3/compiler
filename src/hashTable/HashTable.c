#include "HashTable.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int calculateIndex(int *sizes, int *indexes);
extern HashTableList *hashTableList;
extern void yyerror(const char *s);

#define CAPACITY 50000

// hash function to get the index of the key
unsigned long hash_function(char *str) {
    unsigned long i = 0;

    for (int j = 0; str[j]; j++) i += str[j];

    return i % CAPACITY;
}

// Creates a new item to be inserted in the HashTable.
HtItem create_item(char *key, char *type, int *sizes) {
    HtItem item;
    item.key = (char *) malloc(strlen(key) + 10);
    item.var = (Variable *) malloc(sizeof(Variable));
    item.hasValue = 0;
    strcpy(item.key, key);
    Variable *var = item.var;
    var->type = type;
    if (strcmp(type, "int List") == 0) {
        var->sizes = sizes;
        int size = calculateIndex(sizes, sizes) + 1;
        var->size = size;
    } else {
        var->sizes = 0;
        var->size = 0;
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
    table.items = (HtItem **) calloc(size, sizeof(HtItem *));

    for (int i = 0; i < table.size; i++) table.items[i] = NULL;
    return table;
}

// initialize a variable in the hash table's current scope
int initVar(char *key) {
    HashTable *table = hashTableList->currentScope;
    HtItem *item = (HtItem *) malloc(sizeof(HtItem));
    *item = create_item(key, "int", NULL);

    unsigned long index = hash_function(key);
    while (table->items[index] != NULL) index++;

    if (table->count >= table->size * 0.7 || index >= table->size) {
        table = (HashTable *) realloc(table, sizeof(HashTable) * table->size * 2);
    }

    table->items[index] = item;
    table->count++;
    return index;
}

// initialize a list in the hash table's current scope
int initList(char *key, int *sizes) {
    HashTable *table = hashTableList->currentScope;
    HtItem *item = (HtItem *) malloc(sizeof(HtItem));
    *item = create_item(key, "int List", sizes);

    unsigned long index = hash_function(key);
    while (table->items[index] != NULL) index++;

    if (table->count >= table->size * 0.7 || index >= table->size) {
        table = (HashTable *) realloc(table, sizeof(HashTable) * table->size * 2);
    }

    HtItem *current_item = table->items[index];
    if (current_item == NULL) {
        table->items[index] = item;
        table->count++;
    } else {
        printf("Symbol \"%s\" already exists\n", key);
    }

    // initialize the list with 0s
    Variable *var = item->var;
    int size = var->size / sizeof(int);
    int *value = (int *) malloc(sizeof(int) * size);
    for (int i = 0; i < size; i++) value[i] = 0;
    var->value = value;
    return index;
}

// Adds a new scope to the HashTableList.
void createScope() {
    HashTable *table = (HashTable *) malloc(sizeof(HashTable));
    *table = create_table(50000);
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
    if (index == -1) return;
    HtItem *currentItem = varScope->items[index];

    if (currentItem == NULL) {
        printf("Symbol \"%s\" not found \n", str);
        return;
    }

    Variable *var = currentItem->var;
    if (var == NULL) {
        printf("var \"%s\" is NULL", str);
        return;
    }

    int *newVal = (int *) malloc(sizeof(int));
    *newVal = value;
    var->value = newVal;
    return value;
}

// Updates the value of a list item in the HashTable.
int updateListVar(char *listKey, int *indexes, int value) {
    HashTable *varScope = findScope(listKey);
    unsigned long tableIndex = getIndex(varScope, listKey);
    if (tableIndex == -1) return NULL;
    HtItem *currentItem = varScope->items[tableIndex];

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

    int index = calculateIndex(var->sizes, indexes);


    if (index >= var->size) {
        char *error = (char *) malloc(100);
        sprintf(error, "index out of bounds");
        yyerror(error);
        exit(1);
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
    HtItem *currentItem = table->items[index];

    if (currentItem == NULL) return NULL;

    Variable *var = currentItem->var;
    if (var == NULL) return NULL;

    if (strcmp(var->type, "int") == 1 || var->value == NULL) return NULL;
    return var->value;
}

// Returns 1 if the variable exists in the HashTable, 0 otherwise.
int symbolhasValue(char *str) {
    HashTable *table = findScope(str);

    unsigned long index = getIndex(table, str);
    if (index == -1) return 0;
    HtItem *currentItem = table->items[index];

    if (currentItem == NULL) return 0;

    Variable *var = currentItem->var;
    if (var == NULL) return 0;

    if (strcmp(var->type, "int") == 1 || var->value == NULL) return 0;
    return 1;
}

int symbolIsDeclared(char *str) {
    HashTable *table = findScope(str);
    unsigned long index = getIndex(table, str);
    if (index == -1) return 0;
    while (table->items[index] != NULL) {
        if (strcmp(table->items[index]->key, str) == 0) return 1;
        index++;
    }
    return 0;
}


// Returns the value of a list item in all scopes.
int tableValue(char *str, int *indexes) {
    HashTable *table = findScope(str);
    unsigned long hashTableIndex = getIndex(table, str);
    if (hashTableIndex == -1) return NULL;
    HtItem *currentItem = table->items[hashTableIndex];

    if (currentItem == NULL) return NULL;

    Variable *var = currentItem->var;
    if (var == NULL) return 0;

    int index = calculateIndex(var->sizes, indexes);

    if (strcmp(var->type, "int List") == 1 || var->value == NULL || index >= var->size) return 0;

    int *value = (int *) calloc(var->size, sizeof(int));
    *value = var->value;
    if (value == NULL) return 0;
    return value[index];
}

// Returns 1 if the list item value exists in the HashTable, 0 otherwise.
int tableitemHasValue(char *str, int *indexes) {
    HashTable *table = findScope(str);
    unsigned long hashTableIndex = getIndex(table, str);
    if (hashTableIndex == -1) return 0;
    HtItem *currentItem = table->items[hashTableIndex];

    if (currentItem == NULL) return 0;

    Variable *var = currentItem->var;
    if (var == NULL) return 0;

    // int size = var->size / sizeof(int);

    int index = calculateIndex(var->sizes, indexes);

    if (strcmp(var->type, "int List") == 1 || var->value == NULL || index >= calculateIndex(var->sizes, var->sizes))
        return 0;

    // int *value = var->value;
    // if (value[index] == NULL) return 0;

    return 1;
}

// Returns the index of a variable in the HashTable.
unsigned long getIndex(HashTable *table, char *key) {
    if (table == NULL) return -1;
    unsigned long index = hash_function(key);
    while (table->items[index] != NULL && strcmp(table->items[index]->key, key) != 0) {
        index++;
        if (index >= table->size) index = -1;
    }

    return index;
}

// --------- Scope Functions ---------

// Finds the scope of a variable.
HashTable *findScope(char *str) {
    HashTable *table = hashTableList->currentScope;
    while (table != NULL) {
        unsigned long index = getIndex(table, str);
        HtItem *currentItem = table->items[index];

        if (currentItem != NULL) return table;

        table = table->prev;
    }
    return NULL;
}

// Check if a variable exists in the current scope.
int inCurrentScope(char *str) {
    HashTable *table = hashTableList->currentScope;
    unsigned long index = getIndex(table, str);
    HtItem *currentItem = table->items[index];
    if (currentItem == NULL) return 0;
    return 1;
}

// Deletes the current scope.
void deleteScope() {
    if (hashTableList->currentScope->prev != NULL) {
        // free_table(hashTableList->currentScope);
        hashTableList->currentScope = hashTableList->currentScope->prev;
    }
}

// --------- Aux Functions ---------

// Calculate the index of an item in a multidimensional array
int calculateIndex(int *sizes, int *indexes) {
    if (indexes == NULL) return -1;
    int index = 0;

    if (sizeof(sizes) != sizeof(indexes)) return -1;

    int size = 0;
    while (sizes[size] != -1) size++;
    if (size == 1) return indexes[0];

    for (int i = 0; i < size + 1; i++) {
        int mult = sizes[i];
        for (int j = i + 1; j < size; j++) { mult *= sizes[j]; }

        index += indexes[i] * mult;
    }

    return index;
}
