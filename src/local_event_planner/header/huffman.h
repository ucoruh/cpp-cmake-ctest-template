
#pragma once

/**
 * @brief Compresses a given string using a simple Huffman encoding.
 * @param input  Input text.
 * @param output Pointer to char* that will receive allocated compressed result.
 * @retval 1 on success; 0 on failure.
 *
 * @note Caller must free(*output) after use.
 */
extern int testMallocFailureCount; // Test hook: fail on Nth malloc call (0 = disabled)
int huffman_compress(const char* input, char** output);
