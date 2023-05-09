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
    callTree.type = malloc(sizeof(char) * 255);
    callTree.code = malloc(sizeof(char) * 255);
    strcpy(callTree.code, "");
    callTree.parent = NULL;

    return callTree;
}

void addParent(CallTree *callTree, CallTree *parentTree) {
    if (callTree == NULL) {
        printf("Call Tree is NULL\n");
        return;
    }

    if (parentTree == NULL) {
        printf("Parent Tree is NULL\n");
        return;
    }

    if (callTree->parent != NULL) {
        printf("Call Tree already has a parent\n");
        return;
    }

    callTree->parent = parentTree;
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

void addIndex(CallTree *callTree, int index) {
    if (callTree == NULL) {
        printf("Call Tree is NULL\n");
        return;
    }

    if (callTree->indexes == NULL) {
        callTree->indexes = malloc(sizeof(int));
        callTree->indexes[0] = index;
    } else {
        int *newIndexes = realloc(callTree->indexes, sizeof(int) * (sizeof(callTree->indexes) + 1));
        newIndexes[sizeof(callTree->indexes)] = index;
        callTree->indexes = newIndexes;
    }
}

// ------------------ aux ------------------
void printTree(CallTree *callTree) {
    if (callTree == NULL) {
        printf("Call Tree is NULL\n");
        return;
    };

    printf("Name: %s, Value: %d, Indexes: n/a, Code: \"%s\"\n", callTree->name, callTree->value, callTree->code);

    if (callTree->parent != NULL) {
        printf("Parent: %s\n\t", callTree->parent->name);
        printTree(callTree->parent);
    }
}
