typedef struct Ht_item
{
    char* key;
    int value;
} Ht_item;

// Defines the HashTable.
typedef struct HashTable
{
    // Contains an array of pointers to items.
    Ht_item** items;
    int size;
    int count;
} HashTable;