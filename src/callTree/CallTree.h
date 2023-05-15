typedef struct CallTree {
    char *name;
    char *var_name;
    char *type;// int, void
    int value; // int if var or const, NULL otherwise
    int *indexes;
    char *code;
} CallTree;

CallTree createCallTree(char *name);
void addValue(CallTree *callTree, int value);
void addCode(CallTree *callTree, char *code);
void addIndex(CallTree *callTree, int *indexes);