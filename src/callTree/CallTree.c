#include "CallTree.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// ------------------ IMPLEMENTATION ------------------
void createCallTree(CallTree *callTree, char *name) {
    if (callTree == NULL) {
        printf("Call Tree is NULL\n");
        return;
    }

    callTree->name = malloc(sizeof(char) * 255);
    strcpy(callTree->name, name);
    callTree->value = NULL;
    callTree->indexes = NULL;
    callTree->code = malloc(sizeof(char) * 255);
    callTree->type = malloc(sizeof(char) * 5);
    strcpy(callTree->code, "");
    callTree->parent = NULL;
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

    strcpy(callTree->code, code);
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