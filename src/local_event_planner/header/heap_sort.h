#pragma once
#include "../../local_event_planner/header/event.h"   // Event yapısını kullanmak için

/**
 * @brief Sorts an array of Event structures by ascending date using Heap Sort.
 *
 * @param arr Pointer to an array of Event structures.
 * @param n   Number of elements in the array.
 *
 * @retval 1 on success
 * @retval 0 on failure (e.g. null pointer or empty array)
 *
 * @details
 *  - Sorting is based on the string comparison of the `date` field ("YYYY-MM-DD").
 *  - Uses a max-heap construction followed by element extraction.
 *  - Time complexity: O(n log n)
 *  - Space complexity: O(1)
 *
 * @warning
 *  - The input array is modified in-place.
 *  - All date strings must follow the same fixed-length format (YYYY-MM-DD).
 */
int heap_sort_by_date(struct Event* arr, int n);
