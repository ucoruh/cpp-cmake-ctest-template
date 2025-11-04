//#define ENABLE_LOCAL_EVENT_PLANNER_TEST  // Uncomment to run only this suite standalone if needed

#include "../../googletest/googletest/include/gtest/gtest.h"
#include <cstring>
#include <cstdlib>
#include <cstddef>
#include <string>
#include <vector>

// Track malloc calls for testing
static int g_malloc_call_count = 0;
static int g_malloc_fail_on_call = 0;  // 0 = never fail

// Save original malloc
static void *(*original_malloc_func)(size_t) = malloc;

// Test malloc wrapper that can fail on specific call
static void *test_malloc_wrapper(size_t size) {
  g_malloc_call_count++;

  // Fail on the specified call number
  if (g_malloc_fail_on_call > 0 && g_malloc_call_count == g_malloc_fail_on_call) {
    return nullptr;
  }

  return original_malloc_func(size);
}

// Override malloc before including xor_list.cpp
#define malloc test_malloc_wrapper

// Include the source file to access internal functions
#include "../../local_event_planner/src/xor_list.cpp"

// Restore malloc after include
#undef malloc

// ============================================================
// TEST FIXTURE
// ============================================================
class XORListTests : public ::testing::Test {
 protected:
  void SetUp() override {
    g_malloc_call_count = 0;
    g_malloc_fail_on_call = 0;  // Reset: don't fail by default
    ASSERT_EQ(1, xorlist_init(&list));
  }

  void TearDown() override {
    xorlist_free(&list, nullptr);
    g_malloc_call_count = 0;
    g_malloc_fail_on_call = 0;
  }

  XORList list;
};

// ============================================================
// HELPER FUNCTIONS
// ============================================================
namespace {
int callback_counter = 0;
std::vector<void *> callback_data;

int simple_callback(void* data) {
  callback_counter++;
  callback_data.push_back(data);
  return 1;  // Continue traversal
}

int callback_that_stops(void* data) {
  callback_counter++;
  callback_data.push_back(data);
  return 0;  // Stop traversal
}

int free_callback_count = 0;
int free_callback(void* data) {
  free_callback_count++;

  if (data) {
    free(data);
  }

  return 1;
}

void reset_callback_state() {
  callback_counter = 0;
  callback_data.clear();
  free_callback_count = 0;
}
}  // namespace

// ============================================================
// XORLIST_INIT TESTS
// ============================================================
TEST_F(XORListTests, InitNullPointerReturnsZero) {
  EXPECT_EQ(0, xorlist_init(nullptr));
}

TEST_F(XORListTests, InitSuccessSetsAllFieldsCorrectly) {
  XORList test_list;
  EXPECT_EQ(1, xorlist_init(&test_list));
  EXPECT_EQ(nullptr, test_list.head);
  EXPECT_EQ(nullptr, test_list.tail);
  EXPECT_EQ(0, test_list.size);
}

TEST_F(XORListTests, InitOverwritesExistingValues) {
  XORList test_list;
  // Set some garbage values
  test_list.head = (Node*)0x12345;
  test_list.tail = (Node*)0x67890;
  test_list.size = 999;
  EXPECT_EQ(1, xorlist_init(&test_list));
  EXPECT_EQ(nullptr, test_list.head);
  EXPECT_EQ(nullptr, test_list.tail);
  EXPECT_EQ(0, test_list.size);
}

// ============================================================
// XORLIST_INSERT_FRONT TESTS
// ============================================================
TEST_F(XORListTests, InsertFrontNullListReturnsZero) {
  int *data = (int*)malloc(sizeof(int));
  *data = 42;
  EXPECT_EQ(0, xorlist_insert_front(nullptr, data));
  free(data);
}

TEST_F(XORListTests, InsertFrontMallocFailureReturnsZero) {
  g_malloc_fail_on_call = 1;
  int *data = (int*)malloc(sizeof(int));
  *data = 42;
  EXPECT_EQ(0, xorlist_insert_front(&list, data));
  EXPECT_EQ(nullptr, list.head);
  EXPECT_EQ(nullptr, list.tail);
  EXPECT_EQ(0, list.size);
  free(data);
}

TEST_F(XORListTests, InsertFrontIntoEmptyList) {
  int *data = (int*)malloc(sizeof(int));
  *data = 42;
  EXPECT_EQ(1, xorlist_insert_front(&list, data));
  EXPECT_NE(nullptr, list.head);
  EXPECT_NE(nullptr, list.tail);
  EXPECT_EQ(list.head, list.tail);  // Single node
  EXPECT_EQ(1, list.size);
  EXPECT_EQ(data, list.head->data);
  EXPECT_EQ(nullptr, list.head->npx);  // XOR(NULL, NULL) = NULL
  free(data);
}

TEST_F(XORListTests, InsertFrontUpdatesHeadAndNpx) {
  int *data1 = (int*)malloc(sizeof(int));
  *data1 = 10;
  int *data2 = (int*)malloc(sizeof(int));
  *data2 = 20;
  // Insert first node
  EXPECT_EQ(1, xorlist_insert_front(&list, data1));
  Node* first_head = list.head;
  // Insert second node
  EXPECT_EQ(1, xorlist_insert_front(&list, data2));
  EXPECT_NE(nullptr, list.head);
  EXPECT_EQ(2, list.size);
  EXPECT_EQ(data2, list.head->data);
  EXPECT_NE(first_head, list.head);  // Head changed
  EXPECT_EQ(first_head, list.tail);   // Tail stayed the same
  // Verify npx: new head's npx should be XOR(NULL, old_head)
  // Old head's npx should be XOR(new_head, NULL)
  EXPECT_NE(nullptr, list.head->npx);
  free(data1);
  free(data2);
}

TEST_F(XORListTests, InsertFrontMultipleElements) {
  int values[] = {1, 2, 3, 4, 5};
  int *data[5];

  for (int i = 0; i < 5; i++) {
    data[i] = (int*)malloc(sizeof(int));
    *data[i] = values[i];
    EXPECT_EQ(1, xorlist_insert_front(&list, data[i]));
    EXPECT_EQ(i + 1, list.size);
  }

  EXPECT_EQ(5, list.size);
  EXPECT_NE(nullptr, list.head);
  EXPECT_NE(nullptr, list.tail);
  // Verify order by traversing forward (should be 5, 4, 3, 2, 1)
  reset_callback_state();
  xorlist_traverse_forward(&list, simple_callback);
  EXPECT_EQ(5, callback_counter);
  EXPECT_EQ(data[4], callback_data[0]);  // Last inserted (5)
  EXPECT_EQ(data[0], callback_data[4]);  // First inserted (1)

  for (int i = 0; i < 5; i++) {
    free(data[i]);
  }
}

// ============================================================
// XORLIST_INSERT_BACK TESTS
// ============================================================
TEST_F(XORListTests, InsertBackNullListReturnsZero) {
  int *data = (int*)malloc(sizeof(int));
  *data = 42;
  EXPECT_EQ(0, xorlist_insert_back(nullptr, data));
  free(data);
}

TEST_F(XORListTests, InsertBackMallocFailureReturnsZero) {
  g_malloc_fail_on_call = 1;
  int *data = (int*)malloc(sizeof(int));
  *data = 42;
  EXPECT_EQ(0, xorlist_insert_back(&list, data));
  EXPECT_EQ(nullptr, list.head);
  EXPECT_EQ(nullptr, list.tail);
  EXPECT_EQ(0, list.size);
  free(data);
}

TEST_F(XORListTests, InsertBackIntoEmptyList) {
  int *data = (int*)malloc(sizeof(int));
  *data = 42;
  EXPECT_EQ(1, xorlist_insert_back(&list, data));
  EXPECT_NE(nullptr, list.head);
  EXPECT_NE(nullptr, list.tail);
  EXPECT_EQ(list.head, list.tail);  // Single node
  EXPECT_EQ(1, list.size);
  EXPECT_EQ(data, list.tail->data);
  EXPECT_EQ(nullptr, list.tail->npx);  // XOR(NULL, NULL) = NULL
  free(data);
}

TEST_F(XORListTests, InsertBackUpdatesTailAndNpx) {
  int *data1 = (int*)malloc(sizeof(int));
  *data1 = 10;
  int *data2 = (int*)malloc(sizeof(int));
  *data2 = 20;
  // Insert first node
  EXPECT_EQ(1, xorlist_insert_back(&list, data1));
  Node* first_tail = list.tail;
  // Insert second node
  EXPECT_EQ(1, xorlist_insert_back(&list, data2));
  EXPECT_NE(nullptr, list.tail);
  EXPECT_EQ(2, list.size);
  EXPECT_EQ(data2, list.tail->data);
  EXPECT_NE(first_tail, list.tail);  // Tail changed
  EXPECT_EQ(first_tail, list.head);   // Head stayed the same
  // Verify npx: new tail's npx should be XOR(old_tail, NULL)
  EXPECT_NE(nullptr, list.tail->npx);
  free(data1);
  free(data2);
}

TEST_F(XORListTests, InsertBackMultipleElements) {
  int values[] = {1, 2, 3, 4, 5};
  int *data[5];

  for (int i = 0; i < 5; i++) {
    data[i] = (int*)malloc(sizeof(int));
    *data[i] = values[i];
    EXPECT_EQ(1, xorlist_insert_back(&list, data[i]));
    EXPECT_EQ(i + 1, list.size);
  }

  EXPECT_EQ(5, list.size);
  EXPECT_NE(nullptr, list.head);
  EXPECT_NE(nullptr, list.tail);
  // Verify order by traversing forward (should be 1, 2, 3, 4, 5)
  reset_callback_state();
  xorlist_traverse_forward(&list, simple_callback);
  EXPECT_EQ(5, callback_counter);
  EXPECT_EQ(data[0], callback_data[0]);  // First inserted (1)
  EXPECT_EQ(data[4], callback_data[4]);  // Last inserted (5)

  for (int i = 0; i < 5; i++) {
    free(data[i]);
  }
}

TEST_F(XORListTests, InsertFrontAndBackMixed) {
  int *data1 = (int*)malloc(sizeof(int));
  *data1 = 1;
  int *data2 = (int*)malloc(sizeof(int));
  *data2 = 2;
  int *data3 = (int*)malloc(sizeof(int));
  *data3 = 3;
  int *data4 = (int*)malloc(sizeof(int));
  *data4 = 4;
  // Insert: front(1), back(2), front(3), back(4)
  EXPECT_EQ(1, xorlist_insert_front(&list, data1));
  EXPECT_EQ(1, xorlist_insert_back(&list, data2));
  EXPECT_EQ(1, xorlist_insert_front(&list, data3));
  EXPECT_EQ(1, xorlist_insert_back(&list, data4));
  EXPECT_EQ(4, list.size);
  // Forward order should be: 3, 1, 2, 4
  reset_callback_state();
  xorlist_traverse_forward(&list, simple_callback);
  EXPECT_EQ(4, callback_counter);
  EXPECT_EQ(data3, callback_data[0]);
  EXPECT_EQ(data1, callback_data[1]);
  EXPECT_EQ(data2, callback_data[2]);
  EXPECT_EQ(data4, callback_data[3]);
  // Backward order should be: 4, 2, 1, 3
  reset_callback_state();
  xorlist_traverse_backward(&list, simple_callback);
  EXPECT_EQ(4, callback_counter);
  EXPECT_EQ(data4, callback_data[0]);
  EXPECT_EQ(data2, callback_data[1]);
  EXPECT_EQ(data1, callback_data[2]);
  EXPECT_EQ(data3, callback_data[3]);
  free(data1);
  free(data2);
  free(data3);
  free(data4);
}

// ============================================================
// XORLIST_TRAVERSE_FORWARD TESTS
// ============================================================
TEST_F(XORListTests, TraverseForwardNullListReturnsZero) {
  EXPECT_EQ(0, xorlist_traverse_forward(nullptr, simple_callback));
}

TEST_F(XORListTests, TraverseForwardNullCallbackReturnsZero) {
  EXPECT_EQ(0, xorlist_traverse_forward(&list, nullptr));
}

TEST_F(XORListTests, TraverseForwardEmptyListReturnsZero) {
  reset_callback_state();
  EXPECT_EQ(0, xorlist_traverse_forward(&list, simple_callback));
  EXPECT_EQ(0, callback_counter);
  EXPECT_EQ(0, callback_data.size());
}

TEST_F(XORListTests, TraverseForwardSingleElement) {
  int *data = (int*)malloc(sizeof(int));
  *data = 42;
  EXPECT_EQ(1, xorlist_insert_front(&list, data));
  reset_callback_state();
  EXPECT_EQ(1, xorlist_traverse_forward(&list, simple_callback));
  EXPECT_EQ(1, callback_counter);
  EXPECT_EQ(1, callback_data.size());
  EXPECT_EQ(data, callback_data[0]);
  free(data);
}

TEST_F(XORListTests, TraverseForwardMultipleElements) {
  int values[] = {10, 20, 30, 40, 50};
  int *data[5];

  for (int i = 0; i < 5; i++) {
    data[i] = (int*)malloc(sizeof(int));
    *data[i] = values[i];
    EXPECT_EQ(1, xorlist_insert_back(&list, data[i]));
  }

  reset_callback_state();
  EXPECT_EQ(5, xorlist_traverse_forward(&list, simple_callback));
  EXPECT_EQ(5, callback_counter);
  EXPECT_EQ(5, callback_data.size());

  // Verify order
  for (int i = 0; i < 5; i++) {
    EXPECT_EQ(data[i], callback_data[i]);
  }

  for (int i = 0; i < 5; i++) {
    free(data[i]);
  }
}

TEST_F(XORListTests, TraverseForwardCallbackReturnsZeroStopsEarly) {
  int values[] = {10, 20, 30, 40, 50};
  int *data[5];

  for (int i = 0; i < 5; i++) {
    data[i] = (int*)malloc(sizeof(int));
    *data[i] = values[i];
    EXPECT_EQ(1, xorlist_insert_back(&list, data[i]));
  }

  reset_callback_state();
  EXPECT_EQ(1, xorlist_traverse_forward(&list, callback_that_stops));
  EXPECT_EQ(1, callback_counter);  // Only first element processed
  EXPECT_EQ(1, callback_data.size());
  EXPECT_EQ(data[0], callback_data[0]);

  for (int i = 0; i < 5; i++) {
    free(data[i]);
  }
}

TEST_F(XORListTests, TraverseForwardCountIncrementsCorrectly) {
  int values[] = {1, 2, 3};
  int *data[3];

  for (int i = 0; i < 3; i++) {
    data[i] = (int*)malloc(sizeof(int));
    *data[i] = values[i];
    EXPECT_EQ(1, xorlist_insert_back(&list, data[i]));
  }

  reset_callback_state();
  int count = xorlist_traverse_forward(&list, simple_callback);
  EXPECT_EQ(3, count);
  EXPECT_EQ(3, callback_counter);

  for (int i = 0; i < 3; i++) {
    free(data[i]);
  }
}

// ============================================================
// XORLIST_TRAVERSE_BACKWARD TESTS
// ============================================================
TEST_F(XORListTests, TraverseBackwardNullListReturnsZero) {
  EXPECT_EQ(0, xorlist_traverse_backward(nullptr, simple_callback));
}

TEST_F(XORListTests, TraverseBackwardNullCallbackReturnsZero) {
  EXPECT_EQ(0, xorlist_traverse_backward(&list, nullptr));
}

TEST_F(XORListTests, TraverseBackwardEmptyListReturnsZero) {
  reset_callback_state();
  EXPECT_EQ(0, xorlist_traverse_backward(&list, simple_callback));
  EXPECT_EQ(0, callback_counter);
  EXPECT_EQ(0, callback_data.size());
}

TEST_F(XORListTests, TraverseBackwardSingleElement) {
  int *data = (int*)malloc(sizeof(int));
  *data = 42;
  EXPECT_EQ(1, xorlist_insert_back(&list, data));
  reset_callback_state();
  EXPECT_EQ(1, xorlist_traverse_backward(&list, simple_callback));
  EXPECT_EQ(1, callback_counter);
  EXPECT_EQ(1, callback_data.size());
  EXPECT_EQ(data, callback_data[0]);
  free(data);
}

TEST_F(XORListTests, TraverseBackwardMultipleElements) {
  int values[] = {10, 20, 30, 40, 50};
  int *data[5];

  for (int i = 0; i < 5; i++) {
    data[i] = (int*)malloc(sizeof(int));
    *data[i] = values[i];
    EXPECT_EQ(1, xorlist_insert_back(&list, data[i]));
  }

  reset_callback_state();
  EXPECT_EQ(5, xorlist_traverse_backward(&list, simple_callback));
  EXPECT_EQ(5, callback_counter);
  EXPECT_EQ(5, callback_data.size());

  // Verify reverse order
  for (int i = 0; i < 5; i++) {
    EXPECT_EQ(data[4 - i], callback_data[i]);  // Reverse order
  }

  for (int i = 0; i < 5; i++) {
    free(data[i]);
  }
}

TEST_F(XORListTests, TraverseBackwardCallbackReturnsZeroStopsEarly) {
  int values[] = {10, 20, 30, 40, 50};
  int *data[5];

  for (int i = 0; i < 5; i++) {
    data[i] = (int*)malloc(sizeof(int));
    *data[i] = values[i];
    EXPECT_EQ(1, xorlist_insert_back(&list, data[i]));
  }

  reset_callback_state();
  EXPECT_EQ(1, xorlist_traverse_backward(&list, callback_that_stops));
  EXPECT_EQ(1, callback_counter);  // Only last element processed
  EXPECT_EQ(1, callback_data.size());
  EXPECT_EQ(data[4], callback_data[0]);  // Last element

  for (int i = 0; i < 5; i++) {
    free(data[i]);
  }
}

TEST_F(XORListTests, TraverseBackwardCountIncrementsCorrectly) {
  int values[] = {1, 2, 3};
  int *data[3];

  for (int i = 0; i < 3; i++) {
    data[i] = (int*)malloc(sizeof(int));
    *data[i] = values[i];
    EXPECT_EQ(1, xorlist_insert_back(&list, data[i]));
  }

  reset_callback_state();
  int count = xorlist_traverse_backward(&list, simple_callback);
  EXPECT_EQ(3, count);
  EXPECT_EQ(3, callback_counter);

  for (int i = 0; i < 3; i++) {
    free(data[i]);
  }
}

TEST_F(XORListTests, TraverseForwardAndBackwardConsistency) {
  int values[] = {1, 2, 3, 4};
  int *data[4];

  for (int i = 0; i < 4; i++) {
    data[i] = (int*)malloc(sizeof(int));
    *data[i] = values[i];
    EXPECT_EQ(1, xorlist_insert_back(&list, data[i]));
  }

  // Forward: 1, 2, 3, 4
  reset_callback_state();
  xorlist_traverse_forward(&list, simple_callback);
  std::vector<void *> forward_data = callback_data;
  // Backward: 4, 3, 2, 1
  reset_callback_state();
  xorlist_traverse_backward(&list, simple_callback);
  std::vector<void *> backward_data = callback_data;
  // Verify they are reverse of each other
  EXPECT_EQ(4, forward_data.size());
  EXPECT_EQ(4, backward_data.size());

  for (int i = 0; i < 4; i++) {
    EXPECT_EQ(forward_data[i], backward_data[3 - i]);
  }

  for (int i = 0; i < 4; i++) {
    free(data[i]);
  }
}

// ============================================================
// XORLIST_FREE TESTS
// ============================================================
TEST_F(XORListTests, FreeNullListReturnsZero) {
  EXPECT_EQ(0, xorlist_free(nullptr, nullptr));
}

TEST_F(XORListTests, FreeEmptyListReturnsZero) {
  EXPECT_EQ(0, xorlist_free(&list, nullptr));
  EXPECT_EQ(nullptr, list.head);
  EXPECT_EQ(nullptr, list.tail);
  EXPECT_EQ(0, list.size);
}

TEST_F(XORListTests, FreeSingleElementWithoutFreeFunc) {
  int *data = (int*)malloc(sizeof(int));
  *data = 42;
  EXPECT_EQ(1, xorlist_insert_front(&list, data));
  EXPECT_EQ(1, xorlist_free(&list, nullptr));
  EXPECT_EQ(nullptr, list.head);
  EXPECT_EQ(nullptr, list.tail);
  EXPECT_EQ(0, list.size);
  // Data should still exist (not freed)
  EXPECT_EQ(42, *data);
  free(data);
}

TEST_F(XORListTests, FreeSingleElementWithFreeFunc) {
  int *data = (int*)malloc(sizeof(int));
  *data = 42;
  EXPECT_EQ(1, xorlist_insert_front(&list, data));
  reset_callback_state();
  EXPECT_EQ(1, xorlist_free(&list, free_callback));
  EXPECT_EQ(1, free_callback_count);
  EXPECT_EQ(nullptr, list.head);
  EXPECT_EQ(nullptr, list.tail);
  EXPECT_EQ(0, list.size);
}

TEST_F(XORListTests, FreeMultipleElementsWithoutFreeFunc) {
  int values[] = {1, 2, 3, 4, 5};
  int *data[5];

  for (int i = 0; i < 5; i++) {
    data[i] = (int*)malloc(sizeof(int));
    *data[i] = values[i];
    EXPECT_EQ(1, xorlist_insert_back(&list, data[i]));
  }

  EXPECT_EQ(5, xorlist_free(&list, nullptr));
  EXPECT_EQ(nullptr, list.head);
  EXPECT_EQ(nullptr, list.tail);
  EXPECT_EQ(0, list.size);

  // Data should still exist
  for (int i = 0; i < 5; i++) {
    EXPECT_EQ(values[i], *data[i]);
    free(data[i]);
  }
}

TEST_F(XORListTests, FreeMultipleElementsWithFreeFunc) {
  int values[] = {1, 2, 3, 4, 5};
  int *data[5];

  for (int i = 0; i < 5; i++) {
    data[i] = (int*)malloc(sizeof(int));
    *data[i] = values[i];
    EXPECT_EQ(1, xorlist_insert_back(&list, data[i]));
  }

  reset_callback_state();
  EXPECT_EQ(5, xorlist_free(&list, free_callback));
  EXPECT_EQ(5, free_callback_count);
  EXPECT_EQ(nullptr, list.head);
  EXPECT_EQ(nullptr, list.tail);
  EXPECT_EQ(0, list.size);
}

TEST_F(XORListTests, FreeResetsListFields) {
  int *data1 = (int*)malloc(sizeof(int));
  *data1 = 10;
  int *data2 = (int*)malloc(sizeof(int));
  *data2 = 20;
  EXPECT_EQ(1, xorlist_insert_front(&list, data1));
  EXPECT_EQ(1, xorlist_insert_back(&list, data2));
  EXPECT_NE(nullptr, list.head);
  EXPECT_NE(nullptr, list.tail);
  EXPECT_EQ(2, list.size);
  xorlist_free(&list, nullptr);
  EXPECT_EQ(nullptr, list.head);
  EXPECT_EQ(nullptr, list.tail);
  EXPECT_EQ(0, list.size);
  free(data1);
  free(data2);
}

TEST_F(XORListTests, FreeAfterMultipleOperations) {
  // Insert front and back alternately
  int *data[10];

  for (int i = 0; i < 10; i++) {
    data[i] = (int*)malloc(sizeof(int));
    *data[i] = i;

    if (i % 2 == 0) {
      EXPECT_EQ(1, xorlist_insert_front(&list, data[i]));
    } else {
      EXPECT_EQ(1, xorlist_insert_back(&list, data[i]));
    }
  }

  EXPECT_EQ(10, list.size);
  reset_callback_state();
  EXPECT_EQ(10, xorlist_free(&list, free_callback));
  EXPECT_EQ(10, free_callback_count);
  EXPECT_EQ(nullptr, list.head);
  EXPECT_EQ(nullptr, list.tail);
  EXPECT_EQ(0, list.size);
}

TEST_F(XORListTests, FreeWithNullDataPointers) {
  // Insert NULL data pointers
  EXPECT_EQ(1, xorlist_insert_front(&list, nullptr));
  EXPECT_EQ(1, xorlist_insert_back(&list, nullptr));
  reset_callback_state();
  EXPECT_EQ(2, xorlist_free(&list, free_callback));
  EXPECT_EQ(2, free_callback_count);  // Callback called even for NULL
  EXPECT_EQ(nullptr, list.head);
  EXPECT_EQ(nullptr, list.tail);
  EXPECT_EQ(0, list.size);
}

// ============================================================
// EDGE CASES AND COMPREHENSIVE SCENARIOS
// ============================================================
TEST_F(XORListTests, InsertFrontAfterFree) {
  int *data1 = (int*)malloc(sizeof(int));
  *data1 = 1;
  EXPECT_EQ(1, xorlist_insert_front(&list, data1));
  xorlist_free(&list, nullptr);
  free(data1);
  // Re-initialize
  EXPECT_EQ(1, xorlist_init(&list));
  int *data2 = (int*)malloc(sizeof(int));
  *data2 = 2;
  EXPECT_EQ(1, xorlist_insert_front(&list, data2));
  EXPECT_EQ(1, list.size);
  EXPECT_EQ(data2, list.head->data);
  free(data2);
}

TEST_F(XORListTests, InsertBackAfterFree) {
  int *data1 = (int*)malloc(sizeof(int));
  *data1 = 1;
  EXPECT_EQ(1, xorlist_insert_back(&list, data1));
  xorlist_free(&list, nullptr);
  free(data1);
  // Re-initialize
  EXPECT_EQ(1, xorlist_init(&list));
  int *data2 = (int*)malloc(sizeof(int));
  *data2 = 2;
  EXPECT_EQ(1, xorlist_insert_back(&list, data2));
  EXPECT_EQ(1, list.size);
  EXPECT_EQ(data2, list.tail->data);
  free(data2);
}

TEST_F(XORListTests, LargeNumberOfElements) {
  const int N = 100;
  int *data[N];

  for (int i = 0; i < N; i++) {
    data[i] = (int*)malloc(sizeof(int));
    *data[i] = i;
    EXPECT_EQ(1, xorlist_insert_back(&list, data[i]));
  }

  EXPECT_EQ(N, list.size);
  // Verify forward traversal
  reset_callback_state();
  EXPECT_EQ(N, xorlist_traverse_forward(&list, simple_callback));
  EXPECT_EQ(N, callback_counter);
  // Verify backward traversal
  reset_callback_state();
  EXPECT_EQ(N, xorlist_traverse_backward(&list, simple_callback));
  EXPECT_EQ(N, callback_counter);
  // Free all
  reset_callback_state();
  EXPECT_EQ(N, xorlist_free(&list, free_callback));
  EXPECT_EQ(N, free_callback_count);
}

TEST_F(XORListTests, MallocFailureOnSecondInsert) {
  int *data1 = (int*)malloc(sizeof(int));
  *data1 = 1;
  EXPECT_EQ(1, xorlist_insert_front(&list, data1));
  g_malloc_fail_on_call = 2;  // Fail on second malloc
  int *data2 = (int*)malloc(sizeof(int));
  *data2 = 2;
  EXPECT_EQ(0, xorlist_insert_front(&list, data2));
  // List should still have only one element
  EXPECT_EQ(1, list.size);
  EXPECT_EQ(data1, list.head->data);
  free(data1);
  free(data2);
}

TEST_F(XORListTests, MallocFailureOnSecondInsertBack) {
  int *data1 = (int*)malloc(sizeof(int));
  *data1 = 1;
  EXPECT_EQ(1, xorlist_insert_back(&list, data1));
  g_malloc_fail_on_call = 2;  // Fail on second malloc
  int *data2 = (int*)malloc(sizeof(int));
  *data2 = 2;
  EXPECT_EQ(0, xorlist_insert_back(&list, data2));
  // List should still have only one element
  EXPECT_EQ(1, list.size);
  EXPECT_EQ(data1, list.tail->data);
  free(data1);
  free(data2);
}

TEST_F(XORListTests, TraverseAfterInsertFrontAndBack) {
  // Complex insertion pattern
  int *data[6];

  for (int i = 0; i < 6; i++) {
    data[i] = (int*)malloc(sizeof(int));
    *data[i] = i;
  }

  // Pattern: F, B, F, B, F, B
  EXPECT_EQ(1, xorlist_insert_front(&list, data[0]));  // 0
  EXPECT_EQ(1, xorlist_insert_back(&list, data[1]));   // 0, 1
  EXPECT_EQ(1, xorlist_insert_front(&list, data[2]));  // 2, 0, 1
  EXPECT_EQ(1, xorlist_insert_back(&list, data[3]));   // 2, 0, 1, 3
  EXPECT_EQ(1, xorlist_insert_front(&list, data[4]));  // 4, 2, 0, 1, 3
  EXPECT_EQ(1, xorlist_insert_back(&list, data[5]));  // 4, 2, 0, 1, 3, 5
  EXPECT_EQ(6, list.size);
  // Forward: 4, 2, 0, 1, 3, 5
  reset_callback_state();
  xorlist_traverse_forward(&list, simple_callback);
  EXPECT_EQ(6, callback_counter);
  EXPECT_EQ(data[4], callback_data[0]);
  EXPECT_EQ(data[2], callback_data[1]);
  EXPECT_EQ(data[0], callback_data[2]);
  EXPECT_EQ(data[1], callback_data[3]);
  EXPECT_EQ(data[3], callback_data[4]);
  EXPECT_EQ(data[5], callback_data[5]);
  // Backward: 5, 3, 1, 0, 2, 4
  reset_callback_state();
  xorlist_traverse_backward(&list, simple_callback);
  EXPECT_EQ(6, callback_counter);
  EXPECT_EQ(data[5], callback_data[0]);
  EXPECT_EQ(data[3], callback_data[1]);
  EXPECT_EQ(data[1], callback_data[2]);
  EXPECT_EQ(data[0], callback_data[3]);
  EXPECT_EQ(data[2], callback_data[4]);
  EXPECT_EQ(data[4], callback_data[5]);

  for (int i = 0; i < 6; i++) {
    free(data[i]);
  }
}

// Test with function pointer for callback that stops after two elements
int callback_stop_after_two(void* data) {
  callback_counter++;
  callback_data.push_back(data);
  return callback_counter < 2;
}

TEST_F(XORListTests, CallbackStopsAtSecondElement) {
  int values[] = {10, 20, 30, 40};
  int *data[4];

  for (int i = 0; i < 4; i++) {
    data[i] = (int*)malloc(sizeof(int));
    *data[i] = values[i];
    EXPECT_EQ(1, xorlist_insert_back(&list, data[i]));
  }

  reset_callback_state();
  int count = xorlist_traverse_forward(&list, callback_stop_after_two);
  EXPECT_EQ(2, count);
  EXPECT_EQ(2, callback_data.size());
  EXPECT_EQ(data[0], callback_data[0]);
  EXPECT_EQ(data[1], callback_data[1]);

  for (int i = 0; i < 4; i++) {
    free(data[i]);
  }
}

TEST_F(XORListTests, TraverseForwardStopsAfterTwoElements) {
  int values[] = {10, 20, 30, 40, 50};
  int *data[5];

  for (int i = 0; i < 5; i++) {
    data[i] = (int*)malloc(sizeof(int));
    *data[i] = values[i];
    EXPECT_EQ(1, xorlist_insert_back(&list, data[i]));
  }

  reset_callback_state();
  int count = xorlist_traverse_forward(&list, callback_stop_after_two);
  EXPECT_EQ(2, count);
  EXPECT_EQ(2, callback_counter);
  EXPECT_EQ(data[0], callback_data[0]);
  EXPECT_EQ(data[1], callback_data[1]);

  for (int i = 0; i < 5; i++) {
    free(data[i]);
  }
}

TEST_F(XORListTests, TraverseBackwardStopsAfterTwoElements) {
  int values[] = {10, 20, 30, 40, 50};
  int *data[5];

  for (int i = 0; i < 5; i++) {
    data[i] = (int*)malloc(sizeof(int));
    *data[i] = values[i];
    EXPECT_EQ(1, xorlist_insert_back(&list, data[i]));
  }

  reset_callback_state();
  int count = xorlist_traverse_backward(&list, callback_stop_after_two);
  EXPECT_EQ(2, count);
  EXPECT_EQ(2, callback_counter);
  EXPECT_EQ(data[4], callback_data[0]);  // Last element
  EXPECT_EQ(data[3], callback_data[1]);   // Second to last

  for (int i = 0; i < 5; i++) {
    free(data[i]);
  }
}

// ============================================================
// XOR OPERATION VERIFICATION TESTS
// ============================================================
TEST_F(XORListTests, VerifyXorPointerOperations) {
  // Insert two elements to verify XOR pointer operations
  int *data1 = (int*)malloc(sizeof(int));
  *data1 = 1;
  int *data2 = (int*)malloc(sizeof(int));
  *data2 = 2;
  EXPECT_EQ(1, xorlist_insert_front(&list, data1));
  Node* first_head = list.head;
  EXPECT_EQ(1, xorlist_insert_front(&list, data2));
  // Verify we can traverse correctly using XOR operations
  Node* curr = list.head;
  Node* prev = nullptr;
  Node* next = nullptr;
  // First node should point to second node
  next = (Node*)((uintptr_t)prev ^ (uintptr_t)curr->npx);
  EXPECT_NE(nullptr, next);
  // Continue traversal manually
  prev = curr;
  curr = next;
  EXPECT_EQ(first_head, curr);  // Should be the second node we inserted
  free(data1);
  free(data2);
}

TEST_F(XORListTests, VerifyBackwardXorPointerOperations) {
  // Insert two elements
  int *data1 = (int*)malloc(sizeof(int));
  *data1 = 1;
  int *data2 = (int*)malloc(sizeof(int));
  *data2 = 2;
  EXPECT_EQ(1, xorlist_insert_back(&list, data1));
  Node* first_tail = list.tail;
  EXPECT_EQ(1, xorlist_insert_back(&list, data2));
  // Verify backward traversal using XOR operations
  Node* curr = list.tail;
  Node* next = nullptr;
  Node* prev = nullptr;
  // Last node should point to previous node
  prev = (Node*)((uintptr_t)curr->npx ^ (uintptr_t)next);
  EXPECT_NE(nullptr, prev);
  EXPECT_EQ(first_tail, prev);  // Should be the first node we inserted
  free(data1);
  free(data2);
}

// ============================================================
// COMPREHENSIVE INTEGRATION TEST
// ============================================================
TEST_F(XORListTests, CompleteWorkflowTest) {
  // Initialize
  XORList test_list;
  EXPECT_EQ(1, xorlist_init(&test_list));
  // Insert elements front and back
  int *data[10];

  for (int i = 0; i < 10; i++) {
    data[i] = (int*)malloc(sizeof(int));
    *data[i] = i * 10;

    if (i % 2 == 0) {
      EXPECT_EQ(1, xorlist_insert_front(&test_list, data[i]));
    } else {
      EXPECT_EQ(1, xorlist_insert_back(&test_list, data[i]));
    }
  }

  EXPECT_EQ(10, test_list.size);
  // Traverse forward
  reset_callback_state();
  EXPECT_EQ(10, xorlist_traverse_forward(&test_list, simple_callback));
  EXPECT_EQ(10, callback_counter);
  // Traverse backward
  reset_callback_state();
  EXPECT_EQ(10, xorlist_traverse_backward(&test_list, simple_callback));
  EXPECT_EQ(10, callback_counter);
  // Free with callback
  reset_callback_state();
  EXPECT_EQ(10, xorlist_free(&test_list, free_callback));
  EXPECT_EQ(10, free_callback_count);
  EXPECT_EQ(nullptr, test_list.head);
  EXPECT_EQ(nullptr, test_list.tail);
  EXPECT_EQ(0, test_list.size);
}

