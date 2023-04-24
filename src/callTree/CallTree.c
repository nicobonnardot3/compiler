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

    callTree->name = name;
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

    callTree->code = code;
}

// ------------------ aux ------------------
void printTree(CallTree *callTree) {
    if (callTree == NULL) {
        printf("Call Tree is NULL\n");
        return;
    };

    printf("Name: %s, Value: %d, Indexes: n/a, Code: \"%s\"\n", callTree->name, callTree->value, callTree->code);

    if (callTree->parent != NULL) {
        printTree(callTree->parent);
    }
}