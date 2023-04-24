typedef struct Variables {
    char *type;
    void *value;
    int size;
} Variable;


typedef struct Ht_items {
    char *key;
    Variable *var;
} Ht_item;

// Defines the HashTable.
typedef struct HashTables {
    // Contains an array of pointers to items.
    Ht_item **items;
    int size;
    int count;
} HashTable;

unsigned long hash_function(char *str);
void create_table(HashTable *table, int size);
void free_item(Ht_item *item);
void createVar(HashTable *table, char *key, char *type);
void createList(HashTable *table, char *key, int size);
unsigned long getIndex(HashTable *table, char *key);
void updateVar(HashTable *table, char *str, int val);
int symbolVal(HashTable *table, char *str);
void print_table(HashTable *table);
void print_item(Ht_item *item);