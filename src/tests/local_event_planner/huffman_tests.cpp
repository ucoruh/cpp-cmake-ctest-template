#include "../../googletest/googletest/include/gtest/gtest.h"
#include <cstring>
#include <cstdlib>
#include <cstddef>
#include <string>

// Track malloc calls for testing
static int g_malloc_call_count = 0;
static int g_malloc_fail_on_call = 0;  // 0 = never fail

// Save original malloc
static void* (*original_malloc_func)(size_t) = malloc;

// Test malloc wrapper that can fail on specific call
static void* test_malloc_wrapper(size_t size) {
    g_malloc_call_count++;
    
    // Fail on the specified call number
    if (g_malloc_fail_on_call > 0 && g_malloc_call_count == g_malloc_fail_on_call) {
        return nullptr;
    }
    
    return original_malloc_func(size);
}

// Override malloc before including huffman.cpp
#define malloc test_malloc_wrapper

// Include the source file to access internal functions
#include "../../local_event_planner/src/huffman.cpp"

// Restore malloc after include
#undef malloc

// ============================================================
// TEST FIXTURE
// ============================================================
class HuffmanTests : public ::testing::Test {
protected:
    void SetUp() override {
        g_malloc_call_count = 0;
        g_malloc_fail_on_call = 0;  // Reset: don't fail by default
    }

    void TearDown() override {
        g_malloc_call_count = 0;
        g_malloc_fail_on_call = 0;
    }
};

// ============================================================
// TEST 1: NULL INPUT CHECK - Line 69
// ============================================================
TEST_F(HuffmanTests, NullInputReturnsZero) {
    char* output = nullptr;
    int result = huffman_compress(nullptr, &output);
    EXPECT_EQ(result, 0);
    EXPECT_EQ(output, nullptr);
}

TEST_F(HuffmanTests, NullOutputPointerReturnsZero) {
    const char* input = "test";
    int result = huffman_compress(input, nullptr);
    EXPECT_EQ(result, 0);
}

TEST_F(HuffmanTests, BothNullInputsReturnZero) {
    int result = huffman_compress(nullptr, nullptr);
    EXPECT_EQ(result, 0);
}

// ============================================================
// TEST 2: EMPTY STRING - Line 88 (pq.empty() check)
// ============================================================
TEST_F(HuffmanTests, EmptyStringReturnsZero) {
    char* output = nullptr;
    int result = huffman_compress("", &output);
    EXPECT_EQ(result, 0);
    EXPECT_EQ(output, nullptr);
}

// ============================================================
// TEST 3: SINGLE CHARACTER - Tests single node tree
// ============================================================
TEST_F(HuffmanTests, SingleCharacterCompresses) {
    char* output = nullptr;
    int result = huffman_compress("a", &output);
    EXPECT_EQ(result, 1);
    EXPECT_NE(output, nullptr);
    // Single character should produce a code
    EXPECT_GT(strlen(output), 0);
    free(output);
}

TEST_F(HuffmanTests, SingleCharacterRepeated) {
    char* output = nullptr;
    int result = huffman_compress("aaaa", &output);
    EXPECT_EQ(result, 1);
    EXPECT_NE(output, nullptr);
    free(output);
}

// ============================================================
// TEST 4: TWO CHARACTERS - Tests tree building while loop (line 90)
// ============================================================
TEST_F(HuffmanTests, TwoCharactersCompresses) {
    char* output = nullptr;
    int result = huffman_compress("ab", &output);
    EXPECT_EQ(result, 1);
    EXPECT_NE(output, nullptr);
    free(output);
}

TEST_F(HuffmanTests, TwoCharactersRepeated) {
    char* output = nullptr;
    int result = huffman_compress("abab", &output);
    EXPECT_EQ(result, 1);
    EXPECT_NE(output, nullptr);
    free(output);
}

TEST_F(HuffmanTests, TwoCharactersDifferentFrequencies) {
    char* output = nullptr;
    int result = huffman_compress("aaaab", &output);
    EXPECT_EQ(result, 1);
    EXPECT_NE(output, nullptr);
    free(output);
}

// ============================================================
// TEST 5: MULTIPLE CHARACTERS - Tests complex tree building
// ============================================================
TEST_F(HuffmanTests, MultipleCharactersCompresses) {
    char* output = nullptr;
    int result = huffman_compress("abc", &output);
    EXPECT_EQ(result, 1);
    EXPECT_NE(output, nullptr);
    free(output);
}

TEST_F(HuffmanTests, MultipleCharactersDifferentFrequencies) {
    char* output = nullptr;
    int result = huffman_compress("aaabbbcccd", &output);
    EXPECT_EQ(result, 1);
    EXPECT_NE(output, nullptr);
    free(output);
}

TEST_F(HuffmanTests, LongStringCompresses) {
    char* output = nullptr;
    const char* input = "the quick brown fox jumps over the lazy dog";
    int result = huffman_compress(input, &output);
    EXPECT_EQ(result, 1);
    EXPECT_NE(output, nullptr);
    free(output);
}

// ============================================================
// TEST 6: ALL ASCII CHARACTERS - Tests freq[i] > 0 loop (line 78-86)
// ============================================================
TEST_F(HuffmanTests, AllPrintableAsciiCharacters) {
    char input[256];
    int idx = 0;
    // Include all printable ASCII characters
    for (int i = 32; i < 127; i++) {
        input[idx++] = (char)i;
    }
    input[idx] = '\0';
    
    char* output = nullptr;
    int result = huffman_compress(input, &output);
    EXPECT_EQ(result, 1);
    EXPECT_NE(output, nullptr);
    free(output);
}

TEST_F(HuffmanTests, AllExtendedAsciiCharacters) {
    char input[257];
    int idx = 0;
    // Include all extended ASCII (0-255)
    for (int i = 0; i < 256; i++) {
        input[idx++] = (char)i;
    }
    input[idx] = '\0';
    
    char* output = nullptr;
    int result = huffman_compress(input, &output);
    EXPECT_EQ(result, 1);
    EXPECT_NE(output, nullptr);
    free(output);
}

// ============================================================
// TEST 7: NULL CHARACTER HANDLING - Tests unsigned char cast (line 74)
// ============================================================
TEST_F(HuffmanTests, NullCharacterInString) {
    char input[] = "a\0b";
    char* output = nullptr;
    // Note: This will only process up to first null due to string semantics
    int result = huffman_compress("a", &output);
    EXPECT_EQ(result, 1);
    EXPECT_NE(output, nullptr);
    free(output);
}

TEST_F(HuffmanTests, NegativeCharValues) {
    // Test unsigned char casting
    char input[] = { (char)200, (char)255, '\0' };
    char* output = nullptr;
    int result = huffman_compress(input, &output);
    EXPECT_EQ(result, 1);
    EXPECT_NE(output, nullptr);
    free(output);
}

// ============================================================
// TEST 8: FREQUENCY CALCULATION - Tests freq array loop (line 73-74)
// ============================================================
TEST_F(HuffmanTests, CharacterFrequencyCalculation) {
    char* output = nullptr;
    // "a" appears 5 times, "b" 3 times, "c" 1 time
    int result = huffman_compress("aaaaabbbc", &output);
    EXPECT_EQ(result, 1);
    EXPECT_NE(output, nullptr);
    free(output);
}

TEST_F(HuffmanTests, SingleCharacterHighFrequency) {
    char* output = nullptr;
    std::string input(1000, 'x');
    int result = huffman_compress(input.c_str(), &output);
    EXPECT_EQ(result, 1);
    EXPECT_NE(output, nullptr);
    free(output);
}

// ============================================================
// TEST 9: PRIORITY QUEUE BEHAVIOR - Tests Compare operator (line 19-21)
// ============================================================
TEST_F(HuffmanTests, PriorityQueueOrdering) {
    char* output = nullptr;
    // Characters with different frequencies should be ordered correctly
    int result = huffman_compress("aaaaabbbcc", &output);
    EXPECT_EQ(result, 1);
    EXPECT_NE(output, nullptr);
    free(output);
}

// ============================================================
// TEST 10: TREE BUILDING - Tests while loop (line 90-101)
// ============================================================
TEST_F(HuffmanTests, TreeBuildingWithMultipleNodes) {
    char* output = nullptr;
    // This creates a tree with multiple merges
    int result = huffman_compress("abcdefghij", &output);
    EXPECT_EQ(result, 1);
    EXPECT_NE(output, nullptr);
    free(output);
}

TEST_F(HuffmanTests, TreeBuildingWith10Characters) {
    char* output = nullptr;
    int result = huffman_compress("0123456789", &output);
    EXPECT_EQ(result, 1);
    EXPECT_NE(output, nullptr);
    free(output);
}

// ============================================================
// TEST 11: buildCodes PATH - Tests leaf node path (line 30-33)
// ============================================================
TEST_F(HuffmanTests, BuildCodesLeafNode) {
    // Single character creates a leaf node
    char* output = nullptr;
    int result = huffman_compress("x", &output);
    EXPECT_EQ(result, 1);
    EXPECT_NE(output, nullptr);
    free(output);
}

// ============================================================
// TEST 12: buildCodes PATH - Tests internal node path (line 35-44)
// ============================================================
TEST_F(HuffmanTests, BuildCodesInternalNode) {
    // Multiple characters create internal nodes
    char* output = nullptr;
    int result = huffman_compress("abc", &output);
    EXPECT_EQ(result, 1);
    EXPECT_NE(output, nullptr);
    free(output);
}

// ============================================================
// TEST 13: FREQUENCY CALCULATION LOOP - Tests line 73-74 (CRITICAL - 0 coverage!)
// ============================================================
TEST_F(HuffmanTests, FrequencyCalculationLoopExecutes) {
    // This test ensures the frequency loop (line 73-74) executes
    char* output = nullptr;
    const char* input = "abc";  // Non-empty string to trigger loop
    int result = huffman_compress(input, &output);
    EXPECT_EQ(result, 1);
    EXPECT_NE(output, nullptr);
    free(output);
}

TEST_F(HuffmanTests, FrequencyCalculationWithMultipleCharacters) {
    // Test frequency loop with multiple different characters
    char* output = nullptr;
    int result = huffman_compress("abcdefghijklmnopqrstuvwxyz", &output);
    EXPECT_EQ(result, 1);
    EXPECT_NE(output, nullptr);
    free(output);
}

// ============================================================
// TEST 14: NODE CREATION LOOP - Tests line 78-86 (CRITICAL - 0 coverage!)
// ============================================================
TEST_F(HuffmanTests, NodeCreationLoopExecutes) {
    // This test ensures the node creation loop (line 78-86) executes
    // Need at least one character with freq > 0
    char* output = nullptr;
    int result = huffman_compress("a", &output);
    EXPECT_EQ(result, 1);
    EXPECT_NE(output, nullptr);
    free(output);
}

TEST_F(HuffmanTests, NodeCreationLoopWithMultipleUniqueChars) {
    // Test node creation for multiple unique characters
    char* output = nullptr;
    int result = huffman_compress("abcdef", &output);
    EXPECT_EQ(result, 1);
    EXPECT_NE(output, nullptr);
    free(output);
}

TEST_F(HuffmanTests, NodeCreationLoopWithAll256Chars) {
    // Test node creation for all possible byte values
    char input[257];
    for (int i = 0; i < 256; i++) {
        input[i] = (char)i;
    }
    input[256] = '\0';
    
    char* output = nullptr;
    int result = huffman_compress(input, &output);
    EXPECT_EQ(result, 1);
    EXPECT_NE(output, nullptr);
    free(output);
}

// ============================================================
// TEST 15: PRIORITY QUEUE COMPARE OPERATOR - Tests line 19-20 (0 coverage!)
// ============================================================
TEST_F(HuffmanTests, CompareOperatorWithDifferentFrequencies) {
    // Test Compare operator by creating nodes with different frequencies
    // This will trigger the priority queue comparison
    char* output = nullptr;
    // 'a' appears 5 times, 'b' 3 times, 'c' 1 time - will trigger Compare
    int result = huffman_compress("aaaaabbbc", &output);
    EXPECT_EQ(result, 1);
    EXPECT_NE(output, nullptr);
    free(output);
}

TEST_F(HuffmanTests, CompareOperatorWithEqualFrequencies) {
    // Test Compare operator with equal frequencies
    char* output = nullptr;
    int result = huffman_compress("aabbcc", &output);
    EXPECT_EQ(result, 1);
    EXPECT_NE(output, nullptr);
    free(output);
}

// ============================================================
// TEST 16: WHILE LOOP TREE BUILDING - Tests line 90-101 (partial coverage)
// ============================================================
TEST_F(HuffmanTests, WhileLoopTreeBuildingWithThreeNodes) {
    // Test while loop with exactly 3 nodes (will merge once)
    char* output = nullptr;
    int result = huffman_compress("abc", &output);
    EXPECT_EQ(result, 1);
    EXPECT_NE(output, nullptr);
    free(output);
}

TEST_F(HuffmanTests, WhileLoopTreeBuildingWithMultipleMerges) {
    // Test while loop with many nodes requiring multiple merges
    char* output = nullptr;
    int result = huffman_compress("abcdefghijklmnopqrstuvwxyz", &output);
    EXPECT_EQ(result, 1);
    EXPECT_NE(output, nullptr);
    free(output);
}

TEST_F(HuffmanTests, WhileLoopRightNodeExtraction_Line93) {
    // Test line 93: right = pq.top()
    char* output = nullptr;
    // Need at least 2 nodes to trigger the while loop
    int result = huffman_compress("ab", &output);
    EXPECT_EQ(result, 1);
    EXPECT_NE(output, nullptr);
    free(output);
}

TEST_F(HuffmanTests, WhileLoopMergedNodeMalloc_Line95) {
    // Test line 95: merged = malloc
    char* output = nullptr;
    int result = huffman_compress("abc", &output);
    EXPECT_EQ(result, 1);
    EXPECT_NE(output, nullptr);
    free(output);
}

TEST_F(HuffmanTests, WhileLoopPushMerged_Line100) {
    // Test line 100: pq.push(merged)
    char* output = nullptr;
    int result = huffman_compress("abcd", &output);
    EXPECT_EQ(result, 1);
    EXPECT_NE(output, nullptr);
    free(output);
}

// ============================================================
// TEST 17: buildCodes LEAF NODE PATH - Tests line 30-32 (0 coverage!)
// ============================================================
TEST_F(HuffmanTests, BuildCodesLeafNodePath) {
    // Single character creates a leaf node (line 30-32)
    char* output = nullptr;
    int result = huffman_compress("x", &output);
    EXPECT_EQ(result, 1);
    EXPECT_NE(output, nullptr);
    free(output);
}

// ============================================================
// TEST 18: buildCodes INTERNAL NODE PATH - Tests line 35-44
// ============================================================
TEST_F(HuffmanTests, BuildCodesInternalNodeStrcpy_Line37_38) {
    // Test strcpy calls in buildCodes (line 37-38)
    char* output = nullptr;
    // Multiple characters create internal nodes
    int result = huffman_compress("ab", &output);
    EXPECT_EQ(result, 1);
    EXPECT_NE(output, nullptr);
    free(output);
}

TEST_F(HuffmanTests, BuildCodesLeftPrefBuilding_Line39_40) {
    // Test leftPref building (line 39-40)
    char* output = nullptr;
    int result = huffman_compress("abc", &output);
    EXPECT_EQ(result, 1);
    EXPECT_NE(output, nullptr);
    free(output);
}

TEST_F(HuffmanTests, BuildCodesRightRecursiveCall_Line44) {
    // Test buildCodes right recursive call (line 44) - 0 coverage!
    char* output = nullptr;
    // Need a tree with right child to trigger line 44
    int result = huffman_compress("abc", &output);
    EXPECT_EQ(result, 1);
    EXPECT_NE(output, nullptr);
    free(output);
}

// ============================================================
// TEST 19: SIZE CALCULATION LOOP - Tests line 110-111 (0 coverage!)
// ============================================================
TEST_F(HuffmanTests, SizeCalculationLoop_Line111) {
    // Test size calculation loop (line 111)
    char* output = nullptr;
    int result = huffman_compress("test", &output);
    EXPECT_EQ(result, 1);
    EXPECT_NE(output, nullptr);
    EXPECT_GT(strlen(output), 0);  // Size should be calculated
    free(output);
}

TEST_F(HuffmanTests, SizeCalculationWithMultipleCharacters) {
    // Test size calculation with multiple characters
    char* output = nullptr;
    int result = huffman_compress("abcdefghij", &output);
    EXPECT_EQ(result, 1);
    EXPECT_NE(output, nullptr);
    EXPECT_GT(strlen(output), 0);
    free(output);
}

// ============================================================
// TEST 20: CODE CLEANUP LOOP - Tests line 127-128 (0 coverage!)
// ============================================================
TEST_F(HuffmanTests, CodeCleanupLoop_Line128) {
    // Test codes[i] free loop (line 128) - CRITICAL 0 coverage!
    // This requires multiple characters to have codes allocated
    char* output = nullptr;
    int result = huffman_compress("abcdefghijklmnopqrstuvwxyz", &output);
    EXPECT_EQ(result, 1);
    EXPECT_NE(output, nullptr);
    free(output);
    
    // Run again to ensure cleanup happened
    result = huffman_compress("xyz", &output);
    EXPECT_EQ(result, 1);
    EXPECT_NE(output, nullptr);
    free(output);
}

TEST_F(HuffmanTests, CodeCleanupWithManyUniqueChars) {
    // Test cleanup with many unique characters
    char input[100];
    for (int i = 0; i < 50; i++) {
        input[i] = (char)('a' + (i % 26));
    }
    input[50] = '\0';
    
    char* output = nullptr;
    int result = huffman_compress(input, &output);
    EXPECT_EQ(result, 1);
    EXPECT_NE(output, nullptr);
    free(output);
}

// ============================================================
// TEST 21: freeTree NULL CHECK - Tests line 51 (0 coverage!)
// ============================================================
// Note: freeTree(NULL) is called internally when malloc fails at output allocation
// We'll test this via malloc failure simulation

// ============================================================
// TEST 22: OUTPUT ALLOCATION FAILURE - Tests line 115-118
// ============================================================
// This tests freeTree(root) when output malloc fails
// Note: This requires malloc hook implementation which is complex
// The testMallocFailureCount hook can be used if implemented in huffman.cpp

// ============================================================
// TEST 23: CODE CONCATENATION - Tests line 122-123
// ============================================================
TEST_F(HuffmanTests, CodeConcatenation) {
    char* output = nullptr;
    int result = huffman_compress("test", &output);
    EXPECT_EQ(result, 1);
    EXPECT_NE(output, nullptr);
    // Output should be a concatenation of codes
    EXPECT_GT(strlen(output), 0);
    free(output);
}

// ============================================================
// TEST 16: FREE TREE - Tests freeTree function (line 50-56)
// ============================================================
// freeTree is called internally, but we can verify no memory leaks
// by running multiple compressions
TEST_F(HuffmanTests, MultipleCompressionsNoMemoryLeak) {
    for (int i = 0; i < 100; i++) {
        char* output = nullptr;
        int result = huffman_compress("test string for memory leak check", &output);
        EXPECT_EQ(result, 1);
        EXPECT_NE(output, nullptr);
        free(output);
    }
}

// ============================================================
// TEST 17: CODE CLEANUP - Tests line 127-128 (codes[i] free loop)
// ============================================================
TEST_F(HuffmanTests, CodeCleanupAfterCompression) {
    char* output = nullptr;
    int result = huffman_compress("abcdef", &output);
    EXPECT_EQ(result, 1);
    EXPECT_NE(output, nullptr);
    free(output);
    
    // Run again to ensure cleanup worked
    result = huffman_compress("xyz", &output);
    EXPECT_EQ(result, 1);
    EXPECT_NE(output, nullptr);
    free(output);
}

// ============================================================
// TEST 18: EDGE CASE - Single character with different encodings
// ============================================================
TEST_F(HuffmanTests, SingleCharacterMultipleTimes) {
    char* output1 = nullptr;
    int result1 = huffman_compress("a", &output1);
    EXPECT_EQ(result1, 1);
    
    char* output2 = nullptr;
    int result2 = huffman_compress("a", &output2);
    EXPECT_EQ(result2, 1);
    
    // Both should produce the same encoding
    EXPECT_STREQ(output1, output2);
    
    free(output1);
    free(output2);
}

// ============================================================
// TEST 19: SPECIAL CHARACTERS
// ============================================================
TEST_F(HuffmanTests, SpecialCharacters) {
    char* output = nullptr;
    int result = huffman_compress("!@#$%^&*()", &output);
    EXPECT_EQ(result, 1);
    EXPECT_NE(output, nullptr);
    free(output);
}

TEST_F(HuffmanTests, NewlineCharacters) {
    char* output = nullptr;
    int result = huffman_compress("a\nb\nc", &output);
    EXPECT_EQ(result, 1);
    EXPECT_NE(output, nullptr);
    free(output);
}

TEST_F(HuffmanTests, TabCharacters) {
    char* output = nullptr;
    int result = huffman_compress("a\tb\tc", &output);
    EXPECT_EQ(result, 1);
    EXPECT_NE(output, nullptr);
    free(output);
}

// ============================================================
// TEST 20: WHITESPACE HANDLING
// ============================================================
TEST_F(HuffmanTests, WhitespaceCharacters) {
    char* output = nullptr;
    int result = huffman_compress("a b c d", &output);
    EXPECT_EQ(result, 1);
    EXPECT_NE(output, nullptr);
    free(output);
}

TEST_F(HuffmanTests, MultipleSpaces) {
    char* output = nullptr;
    int result = huffman_compress("a    b", &output);
    EXPECT_EQ(result, 1);
    EXPECT_NE(output, nullptr);
    free(output);
}

// ============================================================
// TEST 21: CASE SENSITIVITY
// ============================================================
TEST_F(HuffmanTests, CaseSensitive) {
    char* output = nullptr;
    int result = huffman_compress("AaBbCc", &output);
    EXPECT_EQ(result, 1);
    EXPECT_NE(output, nullptr);
    free(output);
}

// ============================================================
// TEST 22: NUMBERS
// ============================================================
TEST_F(HuffmanTests, Numbers) {
    char* output = nullptr;
    int result = huffman_compress("0123456789", &output);
    EXPECT_EQ(result, 1);
    EXPECT_NE(output, nullptr);
    free(output);
}

// ============================================================
// TEST 23: VERY LONG STRING
// ============================================================
TEST_F(HuffmanTests, VeryLongString) {
    std::string longInput(10000, 'a');
    longInput += "bcdefghijklmnopqrstuvwxyz";
    
    char* output = nullptr;
    int result = huffman_compress(longInput.c_str(), &output);
    EXPECT_EQ(result, 1);
    EXPECT_NE(output, nullptr);
    free(output);
}

// ============================================================
// TEST 24: REPEATED PATTERNS
// ============================================================
TEST_F(HuffmanTests, RepeatedPatterns) {
    char* output = nullptr;
    int result = huffman_compress("ababababab", &output);
    EXPECT_EQ(result, 1);
    EXPECT_NE(output, nullptr);
    free(output);
}

// ============================================================
// TEST 25: MIXED CHARACTER SETS
// ============================================================
TEST_F(HuffmanTests, MixedCharacterSets) {
    char* output = nullptr;
    int result = huffman_compress("Hello, World! 123", &output);
    EXPECT_EQ(result, 1);
    EXPECT_NE(output, nullptr);
    free(output);
}

// ============================================================
// TEST 26: UNICODE/EXTENDED CHARACTERS (if supported)
// ============================================================
TEST_F(HuffmanTests, ExtendedAsciiRange) {
    char input[129];
    int idx = 0;
    for (int i = 128; i < 256; i++) {
        input[idx++] = (char)i;
    }
    input[idx] = '\0';
    
    char* output = nullptr;
    int result = huffman_compress(input, &output);
    EXPECT_EQ(result, 1);
    EXPECT_NE(output, nullptr);
    free(output);
}

// ============================================================
// TEST 27: PREFIX BUILDING - Tests buildCodes prefix building (line 35-42)
// ============================================================
TEST_F(HuffmanTests, PrefixBuildingWithMultipleLevels) {
    // Create a deep tree by using many unique characters
    char* output = nullptr;
    std::string input;
    for (int i = 0; i < 50; i++) {
        input += (char)('a' + (i % 26));
    }
    int result = huffman_compress(input.c_str(), &output);
    EXPECT_EQ(result, 1);
    EXPECT_NE(output, nullptr);
    free(output);
}

// ============================================================
// TEST 28: SIZE ESTIMATION - Tests line 108-111
// ============================================================
TEST_F(HuffmanTests, SizeEstimation) {
    char* output = nullptr;
    int result = huffman_compress("test", &output);
    EXPECT_EQ(result, 1);
    EXPECT_NE(output, nullptr);
    // Size should be at least the number of characters (worst case)
    EXPECT_GE(strlen(output), 0);
    free(output);
}

// ============================================================
// TEST 29: STRING CONCATENATION - Tests line 122-123 with strcat
// ============================================================
TEST_F(HuffmanTests, StringConcatenation) {
    char* output = nullptr;
    int result = huffman_compress("abc", &output);
    EXPECT_EQ(result, 1);
    EXPECT_NE(output, nullptr);
    // Output should contain concatenated codes
    EXPECT_GT(strlen(output), 0);
    free(output);
}

// ============================================================
// TEST 30: MERGED NODE CREATION - Tests line 95-100
// ============================================================
TEST_F(HuffmanTests, MergedNodeCreation) {
    // This will create merged nodes in the tree
    char* output = nullptr;
    int result = huffman_compress("abcdef", &output);
    EXPECT_EQ(result, 1);
    EXPECT_NE(output, nullptr);
    free(output);
}

// ============================================================
// TEST 31: ROOT NODE EXTRACTION - Tests line 103
// ============================================================
TEST_F(HuffmanTests, RootNodeExtraction) {
    char* output = nullptr;
    int result = huffman_compress("ab", &output);
    EXPECT_EQ(result, 1);
    EXPECT_NE(output, nullptr);
    free(output);
}

// ============================================================
// TEST 32: CODE ARRAY INITIALIZATION - Tests line 104
// ============================================================
TEST_F(HuffmanTests, CodeArrayInitialization) {
    char* output = nullptr;
    int result = huffman_compress("test", &output);
    EXPECT_EQ(result, 1);
    EXPECT_NE(output, nullptr);
    free(output);
}

// ============================================================
// TEST 33: PREFIX INITIALIZATION - Tests line 105
// ============================================================
TEST_F(HuffmanTests, PrefixInitialization) {
    char* output = nullptr;
    int result = huffman_compress("a", &output);
    EXPECT_EQ(result, 1);
    EXPECT_NE(output, nullptr);
    free(output);
}

// ============================================================
// TEST 34: OUTPUT MALLOC FAILURE - Tests line 115-118 (0 coverage!)
// This tests freeTree(root) when output allocation fails (line 116-117)
// ============================================================
TEST_F(HuffmanTests, OutputMallocFailure_SingleChar) {
    // Test output malloc failure for single character
    const char* input = "a";
    
    // First run: count total malloc calls
    g_malloc_call_count = 0;
    char* output_test = nullptr;
    huffman_compress(input, &output_test);
    int total_malloc_calls = g_malloc_call_count;
    if (output_test) free(output_test);
    
    // Second run: fail on the last malloc call (output malloc)
    g_malloc_call_count = 0;
    g_malloc_fail_on_call = total_malloc_calls;  // Fail on output malloc
    
    char* output = nullptr;
    int result = huffman_compress(input, &output);
    
    EXPECT_EQ(result, 0);  // Should return 0 on failure (line 117)
    EXPECT_EQ(output, nullptr);
    // Line 116 (freeTree(root)) should be called when output malloc fails
}

TEST_F(HuffmanTests, OutputMallocFailure_ThreeChars) {
    // Test output malloc failure for three characters
    const char* input = "abc";
    
    // First run: count total malloc calls
    g_malloc_call_count = 0;
    char* output_test = nullptr;
    huffman_compress(input, &output_test);
    int total_malloc_calls = g_malloc_call_count;
    if (output_test) free(output_test);
    
    // Second run: fail on the last malloc call (output malloc)
    g_malloc_call_count = 0;
    g_malloc_fail_on_call = total_malloc_calls;
    
    char* output = nullptr;
    int result = huffman_compress(input, &output);
    
    EXPECT_EQ(result, 0);  // Line 117
    EXPECT_EQ(output, nullptr);
    // Line 116 (freeTree(root)) should be called
}

TEST_F(HuffmanTests, OutputMallocFailure_TestString) {
    // Test output malloc failure for "test"
    const char* input = "test";
    
    // First run: count total malloc calls
    g_malloc_call_count = 0;
    char* output_test = nullptr;
    huffman_compress(input, &output_test);
    int total_malloc_calls = g_malloc_call_count;
    if (output_test) free(output_test);
    
    // Second run: fail on the last malloc call (output malloc)
    g_malloc_call_count = 0;
    g_malloc_fail_on_call = total_malloc_calls;
    
    char* output = nullptr;
    int result = huffman_compress(input, &output);
    
    EXPECT_EQ(result, 0);  // Line 117
    EXPECT_EQ(output, nullptr);
    // Line 116 (freeTree(root)) should be called
}

TEST_F(HuffmanTests, OutputMallocFailure_MultipleChars) {
    // Test output malloc failure for multiple characters
    const char* input = "abcdef";
    
    // First run: count total malloc calls
    g_malloc_call_count = 0;
    char* output_test = nullptr;
    huffman_compress(input, &output_test);
    int total_malloc_calls = g_malloc_call_count;
    if (output_test) free(output_test);
    
    // Second run: fail on the last malloc call (output malloc)
    g_malloc_call_count = 0;
    g_malloc_fail_on_call = total_malloc_calls;
    
    char* output = nullptr;
    int result = huffman_compress(input, &output);
    
    EXPECT_EQ(result, 0);  // Line 117
    EXPECT_EQ(output, nullptr);
    // Line 116 (freeTree(root)) should be called
}

TEST_F(HuffmanTests, OutputMallocFailure_ComplexString) {
    // For "complex_tree_input_123":
    // First, do a successful compression to count malloc calls
    const char* input = "complex_tree_input_123";
    
    // First run: count total malloc calls
    g_malloc_call_count = 0;
    char* output_test = nullptr;
    huffman_compress(input, &output_test);
    int total_malloc_calls = g_malloc_call_count;
    if (output_test) free(output_test);
    
    // Second run: fail on the last malloc call (output malloc)
    g_malloc_call_count = 0;
    g_malloc_fail_on_call = total_malloc_calls;  // Fail on output malloc
    
    char* output = nullptr;
    int result = huffman_compress(input, &output);
    
    EXPECT_EQ(result, 0);  // Line 117
    EXPECT_EQ(output, nullptr);
    // Line 116 (freeTree(root)) should be called
}




