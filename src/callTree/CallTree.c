#include "CallTree.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// ------------------ IMPLEMENTATION ------------------
CallTree createCallTree(char *name) {
    CallTree callTree;

    callTree.name = strdup(name);
    callTree.value = NULL;
    callTree.indexes = NULL;
    callTree.type = (char *) malloc(sizeof(char) * 255);
    callTree.code = (char *) malloc(sizeof(char) * 255);
    strcpy(callTree.code, "");

    return callTree;
}


void addValue(CallTree *callTree, int value) {
    if (callTree == NULL) {
        printf("Call Tree is NULL\n");
        return;
    }

    callTree->value = value;
}

void addCode(CallTree *callTree, char *code) {
    if (callTree == NULL) {
        printf("Call Tree is NULL\n");
        return;
    }

    if (code == NULL) {
        printf("Code is NULL\n");
        return;
    }

    callTree->code = realloc(callTree->code, sizeof(char) * strlen(code) + 10);
    char *newCode = malloc(sizeof(char) * strlen(code) + 10);
    strcpy(newCode, code);
    callTree->code = newCode;
}

void addIndex(CallTree *callTree, int *indexes) {
    if (callTree == NULL) {
        printf("Call Tree is NULL\n");
        return;
    }

    int size = sizeof(indexes) / sizeof(sizeof(int));
    callTree->indexes = (int *) calloc(size + 1, sizeof(int));
    memcpy(callTree->indexes, indexes, (size) * sizeof(int));
    callTree->indexes[size] = NULL;
}

// ------------------ aux ------------------
void printTree(CallTree *callTree) {
    if (callTree == NULL) {
        printf("Call Tree is NULL\n");
        return;
    };

    printf("Name: %s, Value: %d, Indexes: n/a, Code: \"%s\"\n", callTree->name, callTree->value, callTree->code);
}
