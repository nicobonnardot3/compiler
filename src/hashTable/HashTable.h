typedef struct Variable {
    char *type;
    void *value;
    int size;
} Variable;


typedef struct Ht_item {
    char *key;
    int hasValue;
    Variable *var;
} Ht_item;

// Defines the HashTable.
typedef struct HashTable {
    // Contains an array of pointers to items.
    Ht_item **items;
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

Ht_item create_item(char *key, char *type, int size);
HashTable create_table(int size);
int initVar(char *key);
int initList(char *key, int *sizes);
void createScope();

// --------- update Functions ---------

int updateVar(char *str, int value);
int updateListVar(char *listKey, int index, int value);

// --------- getter Functions ---------

int symbolVal(char *str);
int tableValue(char *str, int index);
unsigned long getIndex(HashTable *table, char *key);

// --------- Free Functions ---------

void free_var(Variable *var);
void free_item(Ht_item *item);
void free_table(HashTable *table);

// --------- Scope Functions ---------

HashTable *findScope(char *str);
void deleteScope();

// --------- Print Functions ---------

void print_table(HashTable *table);
void print_item(Ht_item *item);
