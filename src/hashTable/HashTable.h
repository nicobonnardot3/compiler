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