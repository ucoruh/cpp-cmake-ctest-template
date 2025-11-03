#include "../header/file_utility.h"
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <ctime>

/**
 * @name   loadUsersFromBinaryFile
 *
 * @brief  Loads all users from a binary file into the provided hash table.
 *
 * @param  [out] ht        [HashTable*] Target hash table to populate.
 * @param  [in]  filename  [const char*] Path to binary user file.
 *
 * @retval [int] 1 on success; 0 on failure.
 *
 * @details
 *  - If the file does not exist, initializes with empty table and sets ID=1.
 *  - If the file exists, loads all users and updates global currentID.
 *  - Prevents duplicate insertion by checking username.
 *
 * @warning ht must be initialized before calling this function.
 */
int loadUsersFromBinaryFile(HashTable* ht, const char* filename) {
  FILE* file = std::fopen(filename, "rb");

  if (!file) {
    // Dosya yoksa boş başlangıç; ID'yi sıfırla
    currentID = 1;
    return 1; // başarı (boş dosya kabul edilir)
  }

  User tempUser{};
  int maxID = 0;

  while (std::fread(&tempUser, sizeof(User), 1, file) == 1) {
    User* existingUser = nullptr;

    // Eğer kullanıcı zaten yoksa tabloya ekle
    if (!findUserBrent(ht, tempUser.username, &existingUser) || existingUser == nullptr) {
      insertUserBrent(ht, tempUser.id, tempUser.username, tempUser.password);
    }

    if (tempUser.id > maxID) {
      maxID = tempUser.id;
    }
  }

  std::fclose(file);
  currentID = maxID + 1;
  return 1;
}

/**
 * @name   saveUsersToBinaryFile
 *
 * @brief  Saves all users from a hash table into a binary file.
 *
 * @param  [in] ht        [const HashTable*] Source hash table.
 * @param  [in] filename  [const char*]      Output file path.
 *
 * @retval [int] 1 on success; 0 on failure.
 *
 * @details
 *  - Overwrites the target file.
 *  - Iterates through all hash table slots and writes valid entries.
 */
int saveUsersToBinaryFile(const HashTable* ht, const char* filename) {
  FILE* file = std::fopen(filename, "wb");

  if (!file) {
    std::perror("Error opening file for writing");
    return 0;
  }

  for (int i = 0; i < TABLE_SIZE; ++i) {
    const User* user = ht->table[i];

    if (user) {
      std::fwrite(user, sizeof(User), 1, file);
    }
  }

  std::fclose(file);
  return 1;
}

/**
 * @name   getNextID
 *
 * @brief  Computes the next available ID by scanning a binary file.
 *
 * @param  [in] filename    [const char*] Path to binary file.
 * @param  [in] recordSize  [size_t] Size of each record (bytes).
 *
 * @retval [int] Next available ID (max + 1).
 *
 * @details
 *  - Assumes first field in record is `int id`.
 *  - Returns 1 if file does not exist or is empty.
 */
int getNextID(const char* filename, size_t recordSize) {
  FILE* file = std::fopen(filename, "rb");

  if (!file) {
    return 1; // dosya yoksa ilk ID 1
  }

  void *record = std::malloc(recordSize);

  if (!record) {
    std::perror("Memory allocation failed");
    std::fclose(file);
    return 1;
  }

  int maxID = 0;

  // her kaydın ilk alanı int ID olarak kabul edilir
  while (std::fread(record, recordSize, 1, file) == 1) {
    int recID = *reinterpret_cast<int *>(record);

    if (recID > maxID) {
      maxID = recID;
    }
  }

  std::free(record);
  std::fclose(file);
  return maxID + 1;
}

/**
 * @name   getFormattedDate
 *
 * @brief  Generates a formatted date string (YYYY-MM-DD) with optional offset.
 *
 * @param  [in] daysToAdd [int]  Days to add (can be negative).
 *
 * @retval [char*] Newly allocated date string (must be freed by caller).
 *
 * @details
 *  - Uses current local time as base.
 *  - Allocates 11 bytes (including null terminator).
 *  - Example: getFormattedDate(3) → "2025-11-02"
 */
char *getFormattedDate(int daysToAdd) {
  char *dateStr = static_cast<char *>(std::malloc(11)); // "YYYY-MM-DD" + '\0'

  if (!dateStr) {
    std::perror("Memory allocation failed");
    std::exit(EXIT_FAILURE);
  }

  std::time_t now = std::time(nullptr);
  std::tm* ltm = std::localtime(&now);
  ltm->tm_mday += daysToAdd;
  std::mktime(ltm); // normalize date
  std::snprintf(dateStr, 11, "%04d-%02d-%02d",
                1900 + ltm->tm_year, 1 + ltm->tm_mon, ltm->tm_mday);
  return dateStr;
}





// ============================================================================
//  EVENT FILE OPERATIONS SECTION
// ============================================================================

/**
 * @name   save_event_to_file
 *
 * @brief  Appends a single Event record to "events.bin".
 *
 * @param  [in] e [const Event*] Pointer to the event to save.
 *
 * @retval [int] 1 on success; 0 on failure.
 *
 * @details
 *  Opens the file in append-binary mode ("ab"), writes one record,
 *  and closes it immediately. Creates file if missing.
 */
int save_event_to_file(const Event* e) {
  FILE* file = std::fopen("events.bin", "ab");

  if (!file) {
    std::perror("Failed to open events.bin");
    return 0;
  }

  size_t written = std::fwrite(e, sizeof(Event), 1, file);
  std::fclose(file);
  return (written == 1);
}

/**
 * @name   load_all_events
 *
 * @brief  Loads all Event records from "events.bin" into dynamic memory.
 *
 * @param  [out] arr [Event**] Receives pointer to allocated array.
 *
 * @retval [int] Number of loaded records; 0 if none or failure.
 *
 * @details
 *  Allocates memory for all events found in the file. Caller must free(*arr).
 */
int load_all_events(Event** arr) {
  FILE* file = std::fopen("events.bin", "rb");

  if (!file) {
    *arr = NULL;
    return 0;
  }

  std::fseek(file, 0, SEEK_END);
  long size = std::ftell(file);
  std::rewind(file);
  int count = (int)(size / sizeof(Event));

  if (count <= 0) {
    std::fclose(file);
    *arr = NULL;
    return 0;
  }

  *arr = (Event*)std::malloc(sizeof(Event) * count);

  if (!*arr) {
    std::perror("Memory allocation failed");
    std::fclose(file);
    return 0;
  }

  size_t readCount = std::fread(*arr, sizeof(Event), count, file);
  std::fclose(file);
  return (int)readCount;
}

/**
 * @name   save_sorted_events
 *
 * @brief  Saves a sorted Event array into "events_sorted.bin".
 *
 * @param  [in] arr   [const Event*] Sorted Event array.
 * @param  [in] count [int] Number of records.
 *
 * @retval [int] 1 on success; 0 on failure.
 *
 * @details
 *  Overwrites the destination file with the provided array.
 */
int save_sorted_events(const Event* arr, int count) {
  FILE* file = std::fopen("events_sorted.bin", "wb");

  if (!file) {
    std::perror("Failed to open events_sorted.bin");
    return 0;
  }

  size_t written = std::fwrite(arr, sizeof(Event), count, file);
  std::fclose(file);
  return (written == (size_t)count);
}

/**
 * @name   get_next_event_id
 *
 * @brief  Determines the next available Event ID automatically.
 *
 * @retval [int] Next event ID (starting from 1 if file empty or missing)
 *
 * @details
 *  - Scans "events.bin" and returns (maxID + 1).
 *  - If the file does not exist or is empty, returns 1.
 *  - Used by create_event() to auto-increment IDs.
 */
int get_next_event_id(void) {
  FILE* file = std::fopen("events.bin", "rb");

  if (!file)
    return 1;  // file yoksa ID = 1'den başla

  int maxID = 0;
  Event temp{};

  while (std::fread(&temp, sizeof(Event), 1, file) == 1) {
    if (temp.id > maxID)
      maxID = temp.id;
  }

  std::fclose(file);
  return maxID + 1;
}
