#include <cstdio>
#include <cstdlib>
#include <cstring>
#include "../../local_event_planner/header/create_event.h"


// Global XOR list
static XORList eventList;

// Global static ID counter (otomatik artar)
static int s_next_event_id = -1;

/**
 * @brief Initialize event list and next ID counter
 */
int init_event_list() {
  if (!xorlist_init(&eventList))
    return 0;

  // ilk defa başlatılıyorsa, dosyadan en son ID'yi al
  if (s_next_event_id < 0) {
    s_next_event_id = get_next_event_id(); // events.bin içinden (max + 1)

    if (s_next_event_id <= 0)
      s_next_event_id = 1; // fallback
  }

  return 1;
}

/**
 * @brief Create a new event (ID auto-increment)
 */
int create_event() {
  Event* e = (Event*)malloc(sizeof(Event));

  if (!e) {
    perror("Memory allocation failed");
    return 0;
  }

  // ⚙️ ID otomatik atama
  if (s_next_event_id < 0) {
    // init_event_list() çağrılmadıysa bile fallback
    s_next_event_id = get_next_event_id();

    if (s_next_event_id <= 0)
      s_next_event_id = 1;
  }

  e->id = s_next_event_id;
  printf("\n===== CREATE NEW EVENT =====\n");
  printf("(Assigned ID: %d)\n", e->id);
  // Kullanıcıdan diğer bilgileri al
  printf("Enter Event Title: ");
  fgets(e->title, sizeof(e->title), stdin);
  e->title[strcspn(e->title, "\n")] = '\0';
  printf("Enter Event Description: ");
  fgets(e->description, sizeof(e->description), stdin);
  e->description[strcspn(e->description, "\n")] = '\0';
  printf("Enter Event Date (YYYY-MM-DD): ");
  fgets(e->date, sizeof(e->date), stdin);
  e->date[strcspn(e->date, "\n")] = '\0';

  // 🔹 Uzun açıklamaları Huffman ile sıkıştır
  if (strlen(e->description) > 100) {
    char *compressed = nullptr;

    if (huffman_compress(e->description, &compressed) == 1) {
      strncpy(e->description, compressed, sizeof(e->description) - 1);
      e->description[sizeof(e->description) - 1] = '\0';
      free(compressed);
    }
  }

  // 🔹 RAM'e ekle
  if (!xorlist_insert_back(&eventList, e)) {
    printf("❌ Failed to insert event into memory.\n");
    free(e);
    return 0;
  }

  // 🔹 Dosyaya kaydet
  if (!save_event_to_file(e)) {
    printf("❌ Failed to save event to file.\n");
    // başarısızsa ID artmasın
    return 0;
  }

  // 🔹 ID’yi sıradaki kayıt için artır
  s_next_event_id++;
  // 🔹 Dosyadaki tüm kayıtları oku
  Event* all = nullptr;
  int count = load_all_events(&all);

  if (count <= 0) {
    printf("❌ Failed to load events from file.\n");
    return 0;
  }

  // 🔹 Tarihe göre sırala
  if (!heap_sort_by_date(all, count)) {
    printf("❌ Heap sort failed.\n");
    free(all);
    return 0;
  }

  // 🔹 Sıralı dosyaya kaydet
  if (!save_sorted_events(all, count)) {
    printf("❌ Failed to save sorted events.\n");
    free(all);
    return 0;
  }

  free(all);
  printf("\n✅ Event created successfully (ID: %d)\n", e->id);
  return 1;
}
