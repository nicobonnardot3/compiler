typedef struct CallTree {
    char *name;
    char *var_name;
    char *type;
    int value;
    int *indexes;
    char *code;
} CallTree;

CallTree createCallTree(char *name);
void addValue(CallTree *callTree, int value);
void addCode(CallTree *callTree, char *code);
void addIndex(CallTree *callTree, int *indexes);