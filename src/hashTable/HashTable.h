typedef struct Ht_items {
    char *key;
    int value;
} Ht_item;

// Defines the HashTable.
typedef struct HashTables {
    // Contains an array of pointers to items.
    Ht_item **items;
    int size;
    int count;
} HashTable;