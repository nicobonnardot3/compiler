#include "../callTree/CallTree.h"

typedef struct FunctionParam {
    char *name;
    char *type;
    struct FunctionParam *next;
} FunctionParam;

typedef struct FunctionHtItem {
    char *key;
    char *type;
    FunctionParam *params;
} FunctionHtItem;

typedef struct FunctionHashTable {
    FunctionHtItem **functions;
    int size;
    int count;
} FunctionHashTable;

typedef struct FunctionError {
    char *message;
    char *name;
    CallTree **nodes;
    struct FunctionError *prev;
} FunctionError;

unsigned long functionHashFunction(char *str);
FunctionHashTable createFunctionHashTable();
FunctionHtItem createFunctionHtItem(char *key, char *type, FunctionParam *params);
FunctionParam createParam(char *name, char *type);
FunctionHtItem *searchFunction(char *key);
void addFunction(FunctionHtItem *item);
int verifyParams(FunctionHtItem *function, CallTree **node);