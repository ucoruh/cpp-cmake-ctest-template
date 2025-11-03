#include "gtest/gtest.h"
#include "../../../local_event_planner/src/heap_sort.cpp"
#include "../../local_event_planner/header/event.h"
#include <cstring>

class HeapSortTest : public ::testing::Test {
protected:
    void SetUp() override {
        // Test setup
    }

    void TearDown() override {
        // Cleanup
    }

    // Helper function to create an event
    Event createEvent(int id, const char* title, const char* description, const char* date) {
        Event e;
        e.id = id;
        strncpy(e.title, title, sizeof(e.title) - 1);
        e.title[sizeof(e.title) - 1] = '\0';
        strncpy(e.description, description, sizeof(e.description) - 1);
        e.description[sizeof(e.description) - 1] = '\0';
        strncpy(e.date, date, sizeof(e.date) - 1);
        e.date[sizeof(e.date) - 1] = '\0';
        return e;
    }

    // Helper function to verify array is sorted by date
    bool isSortedByDateAscending(const Event* arr, int n) {
        if (!arr || n <= 1) return true;
        for (int i = 0; i < n - 1; ++i) {
            if (strcmp(arr[i].date, arr[i + 1].date) > 0) {
                return false;
            }
        }
        return true;
    }
};

// Test: NULL pointer input
TEST_F(HeapSortTest, NullPointerReturnsZero) {
    EXPECT_EQ(0, heap_sort_by_date(nullptr, 5));
}

// Test: Empty array (n = 0)
TEST_F(HeapSortTest, EmptyArrayReturnsZero) {
    Event arr[1];
    EXPECT_EQ(0, heap_sort_by_date(arr, 0));
}

// Test: Negative size
TEST_F(HeapSortTest, NegativeSizeReturnsZero) {
    Event arr[1];
    EXPECT_EQ(0, heap_sort_by_date(arr, -1));
}

// Test: Single element array (no sorting needed)
TEST_F(HeapSortTest, SingleElementArray) {
    Event arr[1];
    arr[0] = createEvent(1, "Event1", "Description1", "2024-01-15");

    EXPECT_EQ(1, heap_sort_by_date(arr, 1));
    EXPECT_EQ(1, arr[0].id);
    EXPECT_STREQ("2024-01-15", arr[0].date);
}

// Test: Two elements - already sorted
TEST_F(HeapSortTest, TwoElementsAlreadySorted) {
    Event arr[2];
    arr[0] = createEvent(1, "Event1", "Desc1", "2024-01-15");
    arr[1] = createEvent(2, "Event2", "Desc2", "2024-02-15");

    EXPECT_EQ(1, heap_sort_by_date(arr, 2));
    EXPECT_TRUE(isSortedByDateAscending(arr, 2));
    EXPECT_STREQ("2024-01-15", arr[0].date);
    EXPECT_STREQ("2024-02-15", arr[1].date);
}

// Test: Two elements - needs sorting
TEST_F(HeapSortTest, TwoElementsNeedsSorting) {
    Event arr[2];
    arr[0] = createEvent(2, "Event2", "Desc2", "2024-02-15");
    arr[1] = createEvent(1, "Event1", "Desc1", "2024-01-15");

    EXPECT_EQ(1, heap_sort_by_date(arr, 2));
    EXPECT_TRUE(isSortedByDateAscending(arr, 2));
    EXPECT_STREQ("2024-01-15", arr[0].date);
    EXPECT_STREQ("2024-02-15", arr[1].date);
}

// Test: Multiple elements - unsorted
TEST_F(HeapSortTest, MultipleElementsUnsorted) {
    Event arr[5];
    arr[0] = createEvent(3, "Event3", "Desc3", "2024-03-15");
    arr[1] = createEvent(1, "Event1", "Desc1", "2024-01-15");
    arr[2] = createEvent(5, "Event5", "Desc5", "2024-05-15");
    arr[3] = createEvent(2, "Event2", "Desc2", "2024-02-15");
    arr[4] = createEvent(4, "Event4", "Desc4", "2024-04-15");

    EXPECT_EQ(1, heap_sort_by_date(arr, 5));
    EXPECT_TRUE(isSortedByDateAscending(arr, 5));

    EXPECT_STREQ("2024-01-15", arr[0].date);
    EXPECT_STREQ("2024-02-15", arr[1].date);
    EXPECT_STREQ("2024-03-15", arr[2].date);
    EXPECT_STREQ("2024-04-15", arr[3].date);
    EXPECT_STREQ("2024-05-15", arr[4].date);
}

// Test: Multiple elements - reverse sorted
TEST_F(HeapSortTest, MultipleElementsReverseSorted) {
    Event arr[5];
    arr[0] = createEvent(5, "Event5", "Desc5", "2024-05-15");
    arr[1] = createEvent(4, "Event4", "Desc4", "2024-04-15");
    arr[2] = createEvent(3, "Event3", "Desc3", "2024-03-15");
    arr[3] = createEvent(2, "Event2", "Desc2", "2024-02-15");
    arr[4] = createEvent(1, "Event1", "Desc1", "2024-01-15");

    EXPECT_EQ(1, heap_sort_by_date(arr, 5));
    EXPECT_TRUE(isSortedByDateAscending(arr, 5));

    EXPECT_STREQ("2024-01-15", arr[0].date);
    EXPECT_STREQ("2024-02-15", arr[1].date);
    EXPECT_STREQ("2024-03-15", arr[2].date);
    EXPECT_STREQ("2024-04-15", arr[3].date);
    EXPECT_STREQ("2024-05-15", arr[4].date);
}

// Test: Multiple elements - already sorted
TEST_F(HeapSortTest, MultipleElementsAlreadySorted) {
    Event arr[5];
    arr[0] = createEvent(1, "Event1", "Desc1", "2024-01-15");
    arr[1] = createEvent(2, "Event2", "Desc2", "2024-02-15");
    arr[2] = createEvent(3, "Event3", "Desc3", "2024-03-15");
    arr[3] = createEvent(4, "Event4", "Desc4", "2024-04-15");
    arr[4] = createEvent(5, "Event5", "Desc5", "2024-05-15");

    EXPECT_EQ(1, heap_sort_by_date(arr, 5));
    EXPECT_TRUE(isSortedByDateAscending(arr, 5));
}

// Test: Equal dates (should maintain stability where possible)
TEST_F(HeapSortTest, EqualDates) {
    Event arr[4];
    arr[0] = createEvent(3, "Event3", "Desc3", "2024-03-15");
    arr[1] = createEvent(1, "Event1", "Desc1", "2024-03-15");
    arr[2] = createEvent(4, "Event4", "Desc4", "2024-03-15");
    arr[3] = createEvent(2, "Event2", "Desc2", "2024-03-15");

    EXPECT_EQ(1, heap_sort_by_date(arr, 4));
    // All dates are equal, so array should still be processable
    EXPECT_STREQ("2024-03-15", arr[0].date);
    EXPECT_STREQ("2024-03-15", arr[1].date);
    EXPECT_STREQ("2024-03-15", arr[2].date);
    EXPECT_STREQ("2024-03-15", arr[3].date);
}

// Test: Different years
TEST_F(HeapSortTest, DifferentYears) {
    Event arr[3];
    arr[0] = createEvent(1, "Event1", "Desc1", "2025-01-01");
    arr[1] = createEvent(2, "Event2", "Desc2", "2023-12-31");
    arr[2] = createEvent(3, "Event3", "Desc3", "2024-06-15");

    EXPECT_EQ(1, heap_sort_by_date(arr, 3));
    EXPECT_TRUE(isSortedByDateAscending(arr, 3));
    EXPECT_STREQ("2023-12-31", arr[0].date);
    EXPECT_STREQ("2024-06-15", arr[1].date);
    EXPECT_STREQ("2025-01-01", arr[2].date);
}

// Test: Different months same year
TEST_F(HeapSortTest, DifferentMonthsSameYear) {
    Event arr[4];
    arr[0] = createEvent(3, "Event3", "Desc3", "2024-03-15");
    arr[1] = createEvent(1, "Event1", "Desc1", "2024-01-15");
    arr[2] = createEvent(4, "Event4", "Desc4", "2024-04-15");
    arr[3] = createEvent(2, "Event2", "Desc2", "2024-02-15");

    EXPECT_EQ(1, heap_sort_by_date(arr, 4));
    EXPECT_TRUE(isSortedByDateAscending(arr, 4));
    EXPECT_STREQ("2024-01-15", arr[0].date);
    EXPECT_STREQ("2024-02-15", arr[1].date);
    EXPECT_STREQ("2024-03-15", arr[2].date);
    EXPECT_STREQ("2024-04-15", arr[3].date);
}

// Test: Different days same month
TEST_F(HeapSortTest, DifferentDaysSameMonth) {
    Event arr[4];
    arr[0] = createEvent(4, "Event4", "Desc4", "2024-03-25");
    arr[1] = createEvent(1, "Event1", "Desc1", "2024-03-10");
    arr[2] = createEvent(3, "Event3", "Desc3", "2024-03-20");
    arr[3] = createEvent(2, "Event2", "Desc2", "2024-03-05");

    EXPECT_EQ(1, heap_sort_by_date(arr, 4));
    EXPECT_TRUE(isSortedByDateAscending(arr, 4));
    EXPECT_STREQ("2024-03-05", arr[0].date);
    EXPECT_STREQ("2024-03-10", arr[1].date);
    EXPECT_STREQ("2024-03-20", arr[2].date);
    EXPECT_STREQ("2024-03-25", arr[3].date);
}

// Test: Large array (10 elements) to test heapify recursion
TEST_F(HeapSortTest, LargeArray) {
    Event arr[10];
    arr[0] = createEvent(9, "Event9", "Desc9", "2024-09-15");
    arr[1] = createEvent(5, "Event5", "Desc5", "2024-05-15");
    arr[2] = createEvent(8, "Event8", "Desc8", "2024-08-15");
    arr[3] = createEvent(2, "Event2", "Desc2", "2024-02-15");
    arr[4] = createEvent(7, "Event7", "Desc7", "2024-07-15");
    arr[5] = createEvent(1, "Event1", "Desc1", "2024-01-15");
    arr[6] = createEvent(10, "Event10", "Desc10", "2024-10-15");
    arr[7] = createEvent(3, "Event3", "Desc3", "2024-03-15");
    arr[8] = createEvent(6, "Event6", "Desc6", "2024-06-15");
    arr[9] = createEvent(4, "Event4", "Desc4", "2024-04-15");

    EXPECT_EQ(1, heap_sort_by_date(arr, 10));
    EXPECT_TRUE(isSortedByDateAscending(arr, 10));

    // Verify first and last
    EXPECT_STREQ("2024-01-15", arr[0].date);
    EXPECT_STREQ("2024-10-15", arr[9].date);
}

// Test: Edge case - left child is larger (tests heapify left branch)
TEST_F(HeapSortTest, LeftChildLarger) {
    Event arr[3];
    // Arrange so that left child (index 1) is larger than root (index 0)
    arr[0] = createEvent(1, "Event1", "Desc1", "2024-02-15");
    arr[1] = createEvent(2, "Event2", "Desc2", "2024-03-15");
    arr[2] = createEvent(3, "Event3", "Desc3", "2024-01-15");

    EXPECT_EQ(1, heap_sort_by_date(arr, 3));
    EXPECT_TRUE(isSortedByDateAscending(arr, 3));
}

// Test: Edge case - right child is larger (tests heapify right branch)
TEST_F(HeapSortTest, RightChildLarger) {
    Event arr[3];
    // Arrange so that right child (index 2) is larger than root and left
    arr[0] = createEvent(1, "Event1", "Desc1", "2024-01-15");
    arr[1] = createEvent(2, "Event2", "Desc2", "2024-02-15");
    arr[2] = createEvent(3, "Event3", "Desc3", "2024-03-15");

    EXPECT_EQ(1, heap_sort_by_date(arr, 3));
    EXPECT_TRUE(isSortedByDateAscending(arr, 3));
}

// Test: Edge case - right child is largest (tests heapify right > left comparison)
TEST_F(HeapSortTest, RightChildLargest) {
    Event arr[3];
    // Arrange: root < left < right
    arr[0] = createEvent(1, "Event1", "Desc1", "2024-01-15");
    arr[1] = createEvent(2, "Event2", "Desc2", "2024-02-15");
    arr[2] = createEvent(3, "Event3", "Desc3", "2024-03-15");

    EXPECT_EQ(1, heap_sort_by_date(arr, 3));
    EXPECT_TRUE(isSortedByDateAscending(arr, 3));
}

// Test: Deep heapify recursion (tests heapify recursion path)
TEST_F(HeapSortTest, DeepHeapifyRecursion) {
    Event arr[7];
    // Create a structure that requires deep heapify recursion
    arr[0] = createEvent(1, "Event1", "Desc1", "2024-07-15");
    arr[1] = createEvent(2, "Event2", "Desc2", "2024-06-15");
    arr[2] = createEvent(3, "Event3", "Desc3", "2024-05-15");
    arr[3] = createEvent(4, "Event4", "Desc4", "2024-04-15");
    arr[4] = createEvent(5, "Event5", "Desc5", "2024-03-15");
    arr[5] = createEvent(6, "Event6", "Desc6", "2024-02-15");
    arr[6] = createEvent(7, "Event7", "Desc7", "2024-01-15");

    EXPECT_EQ(1, heap_sort_by_date(arr, 7));
    EXPECT_TRUE(isSortedByDateAscending(arr, 7));
}

// Test: Heapify path where largest == i (no swap needed)
TEST_F(HeapSortTest, HeapifyNoSwapNeeded) {
    Event arr[3];
    // Already a heap: root is largest
    arr[0] = createEvent(3, "Event3", "Desc3", "2024-03-15");
    arr[1] = createEvent(1, "Event1", "Desc1", "2024-01-15");
    arr[2] = createEvent(2, "Event2", "Desc2", "2024-02-15");

    EXPECT_EQ(1, heap_sort_by_date(arr, 3));
    EXPECT_TRUE(isSortedByDateAscending(arr, 3));
}

// Test: Heapify with left child out of bounds (left >= n)
TEST_F(HeapSortTest, HeapifyLeftOutOfBounds) {
    Event arr[2];
    // Only 2 elements, so left child of index 0 is at index 1, right is at index 2 (out of bounds)
    arr[0] = createEvent(2, "Event2", "Desc2", "2024-02-15");
    arr[1] = createEvent(1, "Event1", "Desc1", "2024-01-15");

    EXPECT_EQ(1, heap_sort_by_date(arr, 2));
    EXPECT_TRUE(isSortedByDateAscending(arr, 2));
}

// Test: Heapify with right child out of bounds (right >= n)
TEST_F(HeapSortTest, HeapifyRightOutOfBounds) {
    Event arr[2];
    // Test right child out of bounds scenario
    arr[0] = createEvent(2, "Event2", "Desc2", "2024-02-15");
    arr[1] = createEvent(1, "Event1", "Desc1", "2024-01-15");

    EXPECT_EQ(1, heap_sort_by_date(arr, 2));
    EXPECT_TRUE(isSortedByDateAscending(arr, 2));
}

// Test: compareDate function - a < b (returns -1)
TEST_F(HeapSortTest, CompareDateLessThan) {
    Event arr[2];
    arr[0] = createEvent(2, "Event2", "Desc2", "2024-02-15");
    arr[1] = createEvent(1, "Event1", "Desc1", "2024-01-15");

    EXPECT_EQ(1, heap_sort_by_date(arr, 2));
    EXPECT_STREQ("2024-01-15", arr[0].date);
    EXPECT_STREQ("2024-02-15", arr[1].date);
}

// Test: compareDate function - a > b (returns 1)
TEST_F(HeapSortTest, CompareDateGreaterThan) {
    Event arr[2];
    arr[0] = createEvent(1, "Event1", "Desc1", "2024-01-15");
    arr[1] = createEvent(2, "Event2", "Desc2", "2024-02-15");

    EXPECT_EQ(1, heap_sort_by_date(arr, 2));
    EXPECT_STREQ("2024-01-15", arr[0].date);
    EXPECT_STREQ("2024-02-15", arr[1].date);
}

// Test: compareDate function - a == b (returns 0)
TEST_F(HeapSortTest, CompareDateEqual) {
    Event arr[3];
    arr[0] = createEvent(2, "Event2", "Desc2", "2024-03-15");
    arr[1] = createEvent(1, "Event1", "Desc1", "2024-03-15");
    arr[2] = createEvent(3, "Event3", "Desc3", "2024-01-15");

    EXPECT_EQ(1, heap_sort_by_date(arr, 3));
    EXPECT_TRUE(isSortedByDateAscending(arr, 3));
    // Both should have same date
    EXPECT_STREQ("2024-03-15", arr[1].date);
    EXPECT_STREQ("2024-03-15", arr[2].date);
}

// Test: Build heap loop - i = n/2 - 1 down to 0
TEST_F(HeapSortTest, BuildHeapLoop) {
    Event arr[6];
    // Create array that requires full heap build
    arr[0] = createEvent(6, "Event6", "Desc6", "2024-06-15");
    arr[1] = createEvent(5, "Event5", "Desc5", "2024-05-15");
    arr[2] = createEvent(4, "Event4", "Desc4", "2024-04-15");
    arr[3] = createEvent(3, "Event3", "Desc3", "2024-03-15");
    arr[4] = createEvent(2, "Event2", "Desc2", "2024-02-15");
    arr[5] = createEvent(1, "Event1", "Desc1", "2024-01-15");

    EXPECT_EQ(1, heap_sort_by_date(arr, 6));
    EXPECT_TRUE(isSortedByDateAscending(arr, 6));
}

// Test: Extract elements loop - i = n-1 down to 0
TEST_F(HeapSortTest, ExtractElementsLoop) {
    Event arr[4];
    arr[0] = createEvent(4, "Event4", "Desc4", "2024-04-15");
    arr[1] = createEvent(3, "Event3", "Desc3", "2024-03-15");
    arr[2] = createEvent(2, "Event2", "Desc2", "2024-02-15");
    arr[3] = createEvent(1, "Event1", "Desc1", "2024-01-15");

    EXPECT_EQ(1, heap_sort_by_date(arr, 4));
    EXPECT_TRUE(isSortedByDateAscending(arr, 4));
}

// Test: isSortedByDateAscending returns false for unsorted array (covers line 34)
TEST_F(HeapSortTest, IsSortedByDateAscendingReturnsFalseForUnsorted) {
    Event arr[3];
    // Create an unsorted array to test the false return path
    arr[0] = createEvent(2, "Event2", "Desc2", "2024-03-15");
    arr[1] = createEvent(1, "Event1", "Desc1", "2024-01-15");
    arr[2] = createEvent(3, "Event3", "Desc3", "2024-02-15");
    
    // This should return false because array is not sorted
    EXPECT_FALSE(isSortedByDateAscending(arr, 3));
}