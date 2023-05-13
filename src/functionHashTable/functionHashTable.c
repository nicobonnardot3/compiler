#include "functionHashTable.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define CAPACITY 50000

extern FunctionHashTable *functionHashTable;

unsigned long functionHashFunction(char *str) {
    unsigned long i = 0;

    for (int j = 0; str[j]; j++) i += str[j];

    return i % CAPACITY;
}

FunctionHashTable createFunctionHashTable() {
    FunctionHashTable table;
    table.size = CAPACITY;
    table.count = 0;
    table.functions = (FunctionHtItem **) calloc(table.size, sizeof(FunctionHtItem *));

    return table;
}

FunctionHtItem createFunctionHtItem(char *key, char *type, FunctionParam *params) {
    FunctionHtItem item;
    item.key = (char *) malloc(strlen(key) + 1);
    strcpy(item.key, key);
    item.type = (char *) malloc(strlen(type) + 1);
    strcpy(item.type, type);
    item.params = params;

    return item;
}

FunctionParam createParam(char *name, char *type) {
    FunctionParam params;
    params.name = (char *) malloc(strlen(name) + 1);
    strcpy(params.name, name);
    params.type = (char *) malloc(strlen(type) + 1);
    strcpy(params.type, type);

    return params;
}

void addFunction(FunctionHtItem *item) {
    if (functionHashTable->count == functionHashTable->size) {
        printf("Insert Error: Hash Table is full\n");
        return;
    }

    unsigned long index = functionHashFunction(item->key);
    while (functionHashTable->functions[index] != NULL && functionHashTable->functions[index]->key != NULL &&
           strcmp(functionHashTable->functions[index]->key, item->key) != 0) {
        index++;
    }

    FunctionHtItem *currentItem = functionHashTable->functions[index];

    if (currentItem != NULL) { printf("Warning: Index collision with key %s\n", item->key); }

    functionHashTable->functions[index] = item;
    functionHashTable->count++;
}

int verifyParams(FunctionHtItem *function, CallTree **nodes) {
    const int TOO_MANY_PARAMS = 1;
    const int MISSING_PARAMS = 2;
    const int WRONG_TYPE_BASE = 3;

    if (function == NULL) return 1;

    // get size of params
    int paramSize = 0;
    FunctionParam *param = function->params;
    while (param != NULL) {
        param = param->next;
        paramSize++;
    }

    if (paramSize == 0 && nodes == NULL) return 0;
    if (paramSize != 0 && nodes == NULL) return MISSING_PARAMS;

    printf("paramSize: %d\n", paramSize);

    int size = 0;
    while (nodes[size] != NULL) size++;

    printf("size: %d\n", size);


    FunctionParam *params = function->params;
    int i = 0;
    while (params != NULL) {
        if (nodes[i] == NULL) return MISSING_PARAMS;
        printf("node: %s\n", nodes[i]->name);
        printf("param: %s\n", params->name);
        if (strcmp(params->type, nodes[i]->type) != 0) return (WRONG_TYPE_BASE + i);
        params = params->next;
        i++;
    }

    // FunctionParam *params = function->params;
    // int i = 0;
    // while (i < size) {
    //     printf("%s\n", nodes[i]->name);
    //     if (params == NULL) return 2;
    //     if (nodes[i] == NULL) return 1;

    //     if (strcmp(params->type, nodes[i]->type) != 0) return (3 + i);
    //     params = params->next;
    //     i++;
    // }

    if (nodes[i] != NULL) return TOO_MANY_PARAMS;

    return 0;
}

FunctionHtItem *searchFunction(char *key) {
    unsigned long index = functionHashFunction(key);

    while (functionHashTable->functions[index] != NULL) {
        if (strcmp(functionHashTable->functions[index]->key, key) == 0) { return functionHashTable->functions[index]; }

        index++;
    }

    return NULL;
}