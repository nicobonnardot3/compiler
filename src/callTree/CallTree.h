typedef struct CallTree {
    char *name;
    char *var_name;
    char *type;// int, void
    int value; // int if var or const, NULL otherwise
    int *indexes;
    char *code;
    struct CallTree *parent;// parent
} CallTree;

CallTree createCallTree(char *name);
void addParent(CallTree *callTree, CallTree *parentTree);
void addValue(CallTree *callTree, int value);
void addCode(CallTree *callTree, char *code);
void addIndex(CallTree *callTree, int *indexes);
void printTree(CallTree *callTree);