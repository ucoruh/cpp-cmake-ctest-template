

#ifndef BRENT_HASHING_H
#define BRENT_HASHING_H

#define TABLE_SIZE 100
#include <string.h>
#include "commonTypes.h"


extern int currentID;
extern bool forceFailure;

typedef struct User {
	int id;
	char username[50];
	char password[50];
} User;

typedef struct HashTable {
	User* table[TABLE_SIZE];
} HashTable;

static unsigned int hash(const char* key);
int initBrentHashTable(HashTable* ht);
int insertUserBrent(HashTable* ht, int id, const char* username, const char* password);
int findUserBrent(HashTable* ht, const char* username, User** result);

#endif //BRENT_HASHING_H