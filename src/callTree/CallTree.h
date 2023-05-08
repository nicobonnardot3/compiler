typedef struct CallTree {
    char *name;
    char *type;// int, void
    int value; // int if var or const, NULL otherwise
    int **indexes;
    char *code;
    struct CallTree *parent;// parent
} CallTree;

void createCallTree(CallTree *callTree, char *name);
void addParent(CallTree *callTree, CallTree *parentTree);
void addValue(CallTree *callTree, int value);
void addCode(CallTree *callTree, char *code);
void addIndex(CallTree *callTree, int index);
void printTree(CallTree *callTree);
