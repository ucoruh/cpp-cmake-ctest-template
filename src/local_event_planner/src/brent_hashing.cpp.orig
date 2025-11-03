#include "../header/brent_hashing.h"

/**
 *  @name   currentID
 *
 *  @brief  Auto-increment user identifier used when creating new users.
 *
 *  @details
 *  Stores the next candidate user ID. Typically advanced by persistence
 *  layer after loading/saving users.
 *
 *  @note   Global state; not thread-safe.
 */
int currentID = 1;

/**
 *  @name   forceFailure
 *
 *  @brief  Test hook to force insert failures.
 *
 *  @details
 *  When set to true, insertUserBrent(...) will return failure (0) without
 *  modifying the table. Useful for unit tests of error paths.
 *
 *  @note   Global state; not thread-safe.
 */
bool forceFailure = false;

/**
 *  @name   hash
 *
 *  @brief  Computes a simple additive/shift hash for a C-string key.
 *
 *  @param  [in] key [\b const char*]  Null-terminated username/key to hash.
 *
 *  @retval [\b unsigned int] Bucket index in range [0, TABLE_SIZE).
 *
 *  @details
 *  Iteratively left-shifts the running value by 5 and adds the next byte,
 *  then reduces modulo TABLE_SIZE. Intended for internal use in this module.
 *
 *  @warning key must be non-NULL and point to a valid null-terminated string.
 */
static unsigned int hash(const char* key)
{
	unsigned int hash = 0;
	while (*key) 
	{
		hash = (hash << 5) + *key++;
	}
	return hash % TABLE_SIZE;
}

/**
 *  @name   initBrentHashTable
 *
 *  @brief  Initializes all buckets of the Brent hash table to NULL.
 *
 *  @param  [in,out] ht [\b HashTable*]  Table instance to initialize.
 *
 *  @retval [\b int] 1 on success; 0 on invalid argument.
 *
 *  @details
 *  Performs a linear pass over TABLE_SIZE slots and clears them.
 *
 *  @complexity O(TABLE_SIZE)
 *
 *  @warning ht must be a valid, allocated pointer.
 */
int initBrentHashTable(HashTable* ht)
{
	for (int i = 0; i < TABLE_SIZE; i++) 
	{
		ht->table[i] = NULL;
	}
	return 1;
}

/**
 *  @name   insertUserBrent
 *
 *  @brief  Inserts a new User into the table using a Brent-style probe choice.
 *
 *  @param  [in,out] ht        [\b HashTable*]  Target hash table.
 *  @param  [in]     id        [\b int]         User identifier to store.
 *  @param  [in]     username  [\b const char*] Null-terminated username key.
 *  @param  [in]     password  [\b const char*] Null-terminated password value.
 *
 *  @retval [\b int] 1 on success; 0 on failure (e.g., allocation fail, forced fail).
 *
 *  @details
 *  Computes the primary index from @p username. If the slot is occupied,
 *  linearly probes to find either the first empty slot or a position where
 *  relocating the current occupant (one step ahead) reduces probe distance
 *  (a simplified Brent heuristic). Allocates a new User and places it at
 *  the resolved index; existing occupant may be shifted.
 *
 *  @note
 *  - Respects the global @c forceFailure test flag.
 *  - Truncates @p username/@p password to fit fixed-size fields in User.
 *
 *  @complexity
 *  - Average: Amortized O(1)
 *  - Worst-case: O(TABLE_SIZE)
 *
 *  @warning
 *  - @p ht, @p username, and @p password must be valid pointers.
 *  - Does not check for duplicate usernames; callers should guard if needed.
 *  - Not thread-safe.
 */
int insertUserBrent(HashTable* ht, int id, const char* username, const char* password)
{
	if (forceFailure)
	{
		return 0;
	}
	unsigned int index = hash(username);

	if (ht->table[index] != NULL)
	{
		unsigned int i = 1;
		unsigned int bestIndex = index;
		unsigned int bestDist = i;

		while (i < TABLE_SIZE)
		{
			unsigned int probeIndex = (index + i) % TABLE_SIZE;

			if (ht->table[probeIndex] == NULL)
			{
				bestIndex = probeIndex;
				bestDist = i;
				break;
			}

			unsigned int secondaryIndex = (probeIndex + 1) % TABLE_SIZE;
			if (ht->table[secondaryIndex] == NULL)
			{
				bestIndex = secondaryIndex;
				bestDist = i;
				break;
			}
			i++;
		}

		if (bestIndex != index)
		{
			ht->table[bestIndex] = ht->table[index];
		}
	}

	User* newUser = (User*)malloc(sizeof(User));
	if (!newUser)
	{
		return 0;
	}

	newUser->id = id;
	strncpy(newUser->username, username, sizeof(newUser->username) - 1);
	newUser->username[sizeof(newUser->username) - 1] = '\0';
	strncpy(newUser->password, password, sizeof(newUser->password) - 1);
	newUser->password[sizeof(newUser->password) - 1] = '\0';

	ht->table[index] = newUser;
	return 1;
}

/**
 *  @name   findUserBrent
 *
 *  @brief  Looks up a user by username using linear probing from the hash index.
 *
 *  @param  [in]      ht       [\b HashTable*]   Hash table to query.
 *  @param  [in]      username [\b const char*]  Null-terminated username key.
 *  @param  [out]     result   [\b User**]       If non-NULL, receives a pointer to the found User; set to NULL if not found.
 *
 *  @retval [\b int] 1 if found; 0 if not found or on invalid args.
 *
 *  @details
 *  Starts at the primary hash index and linearly probes until it either
 *  encounters a NULL bucket (not found) or a matching username (found).
 *
 *  @complexity
 *  - Average: Amortized O(1)
 *  - Worst-case: O(TABLE_SIZE)
 *
 *  @warning
 *  - @p ht and @p username must be non-NULL.
 *  - Returned @p *result (if any) points to internal storage; do not free it.
 */
int findUserBrent(HashTable* ht, const char* username, User** result)
{
	if (!ht || !username)
	{
		return 0; 
	}

	unsigned int index = hash(username);

	for (unsigned int i = 0; i < TABLE_SIZE; i++)
	{
		unsigned int probeIndex = (index + i) % TABLE_SIZE;

		if (ht->table[probeIndex] == NULL)
		{
			if (result)
			{
				*result = NULL;
			}
			return 0;
		}

		if (strcmp(ht->table[probeIndex]->username, username) == 0)
		{
			if (result)
			{
				*result = ht->table[probeIndex];
			}
			return 1;
		}
	}

	if (result)
	{
		*result = NULL;
	}
	return 0;
}