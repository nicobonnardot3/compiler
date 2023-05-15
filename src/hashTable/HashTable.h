typedef struct Variable {
    char *type;
    int *sizes;
    void *value;
    int size;
} Variable;


typedef struct HtItem {
    char *key;
    int hasValue;
    Variable *var;
} HtItem;

// Defines the HashTable.
typedef struct HashTable {
    // Contains an array of pointers to items.
    HtItem **items;
    int size;
    int count;
    struct HashTable *prev;
} HashTable;


// List of hash tables to take into account the scope.
typedef struct HashTableList {
    HashTable *currentScope;
    int size;
} HashTableList;


unsigned long hash_function(char *str);

HtItem create_item(char *key, char *type, int *sizes);
HashTable create_table(int size);
int initVar(char *key);
int initList(char *key, int *sizes);
void createScope();

// --------- update Functions ---------

int updateVar(char *str, int value);
int updateListVar(char *listKey, int *indexes, int value);

// --------- getter Functions ---------

int symbolVal(char *str);
int symbolhasValue(char *str);
int symbolIsDeclared(char *str);
int tableValue(char *str, int *indexes);
int tableitemHasValue(char *str, int *indexes);
unsigned long getIndex(HashTable *table, char *key);

// --------- Scope Functions ---------

HashTable *findScope(char *str);
int inCurrentScope(char *str);
void deleteScope();