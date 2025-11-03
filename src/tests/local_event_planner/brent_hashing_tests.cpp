//#define ENABLE_LOCAL_EVENT_PLANNER_TEST  // Uncomment to run only this suite standalone if needed

#include "gtest/gtest.h"
#include "../../../local_event_planner/src/brent_hashing.cpp"

#include <string>

namespace {

    int countNonNull(const HashTable& ht) {
        int count = 0;
        for (int i = 0; i < TABLE_SIZE; ++i) {
            if (ht.table[i] != NULL) {
                ++count;
            }
        }
        return count;
    }

    int findIndexByUsername(const HashTable& ht, const char* username) {
        for (int i = 0; i < TABLE_SIZE; ++i) {
            if (ht.table[i] && std::string(ht.table[i]->username) == std::string(username)) {
                return i;
            }
        }
        return -1;
    }

    void freeAll(HashTable& ht) {
        for (int i = 0; i < TABLE_SIZE; ++i) {
            if (ht.table[i] != NULL) {
                free(ht.table[i]);
                ht.table[i] = NULL;
            }
        }
    }

}  // namespace

class BrentHashingTest : public ::testing::Test {
protected:
    void SetUp() override {
        forceFailure = false;
        ASSERT_EQ(1, initBrentHashTable(&table));
    }

    void TearDown() override {
        freeAll(table);
    }

    HashTable table;
};

TEST_F(BrentHashingTest, InitSetsAllBucketsNull) {
    for (int i = 0; i < TABLE_SIZE; ++i) {
        EXPECT_EQ(nullptr, table.table[i]);
    }
}

TEST_F(BrentHashingTest, InsertSuccessIntoEmptyTable) {
    EXPECT_EQ(0, countNonNull(table));
    ASSERT_EQ(1, insertUserBrent(&table, 42, "alice", "pw"));
    EXPECT_EQ(1, countNonNull(table));

    User* found = nullptr;
    EXPECT_EQ(1, findUserBrent(&table, "alice", &found));
    ASSERT_NE(nullptr, found);
    EXPECT_EQ(42, found->id);
    EXPECT_STREQ("alice", found->username);
    EXPECT_STREQ("pw", found->password);
}

TEST_F(BrentHashingTest, ForceFailurePreventsInsertion) {
    forceFailure = true;
    EXPECT_EQ(0, insertUserBrent(&table, 1, "bob", "pw"));
    EXPECT_EQ(0, countNonNull(table));
}

TEST_F(BrentHashingTest, AllocationFailureReturnsZeroAndDoesNotModifyTable) {
    EXPECT_EQ(0, countNonNull(table));
    testForceMallocNull = true; // next allocation should return NULL
    EXPECT_EQ(0, insertUserBrent(&table, 55, "charlie", "pw"));
    EXPECT_EQ(0, countNonNull(table));
}

TEST_F(BrentHashingTest, UsernameAndPasswordAreTruncatedAndNullTerminated) {
    std::string longBase = std::string(80, 'u');
    std::string longPass = std::string(90, 'p');
    ASSERT_EQ(1, insertUserBrent(&table, 7, longBase.c_str(), longPass.c_str()));

    User* found = nullptr;
    int nonNullIdx = -1;
    for (int i = 0; i < TABLE_SIZE; ++i) {
        if (table.table[i] != NULL) { nonNullIdx = i; break; }
    }
    ASSERT_NE(-1, nonNullIdx);
    found = table.table[nonNullIdx];
    ASSERT_NE(nullptr, found);

    EXPECT_EQ(7, found->id);
    EXPECT_EQ(0, found->username[49]);
    EXPECT_EQ(0, found->password[49]);
}

TEST_F(BrentHashingTest, FindUserReturnsZeroOnInvalidArgs) {
    User* out = reinterpret_cast<User*>(0x1);
    EXPECT_EQ(0, findUserBrent(nullptr, "x", &out));
    EXPECT_EQ(0, findUserBrent(&table, nullptr, &out));
}

TEST_F(BrentHashingTest, FindUserNotFoundEarlyNull) {
    User* out = reinterpret_cast<User*>(0x1);
    EXPECT_EQ(0, findUserBrent(&table, "nobody", &out));
    EXPECT_EQ(nullptr, out);
}

TEST_F(BrentHashingTest, FindUserFullTableNoNullsReturnsZero) {
    for (int i = 0; i < TABLE_SIZE; ++i) {
        User* u = static_cast<User*>(malloc(sizeof(User)));
        ASSERT_NE(nullptr, u);
        u->id = i;
        snprintf(u->username, sizeof(u->username), "user_%03d", i);
        snprintf(u->password, sizeof(u->password), "pw_%03d", i);
        table.table[i] = u;
    }

    User* out = reinterpret_cast<User*>(0x1);
    EXPECT_EQ(0, findUserBrent(&table, "nonexistent_user", &out));
    EXPECT_EQ(nullptr, out);
}

TEST_F(BrentHashingTest, CollisionPathMovesExistingAndPlacesNewAtPrimaryIndex) {
    freeAll(table);
    ASSERT_EQ(1, initBrentHashTable(&table));

    const char* user1 = "user1";
    ASSERT_EQ(1, insertUserBrent(&table, 100, user1, "pw1"));
    int user1_original_index = findIndexByUsername(table, user1);
    ASSERT_NE(-1, user1_original_index);

    bool foundCollision = false;
    std::string user2_name;
    int user2_id = 200;

    for (int attempt = 0; attempt < 1000 && !foundCollision; ++attempt) {
        user2_name = "user2_" + std::to_string(attempt);

        int user1_before = findIndexByUsername(table, user1);

        int insert_result = insertUserBrent(&table, user2_id + attempt, user2_name.c_str(), "pw2");
        ASSERT_EQ(1, insert_result);

        int user2_index = findIndexByUsername(table, user2_name.c_str());
        int user1_after = findIndexByUsername(table, user1);

        if (user2_index == user1_original_index) {
            foundCollision = true;
            EXPECT_NE(user1_original_index, user1_after);
            EXPECT_NE(-1, user1_after);

            User* found1 = nullptr;
            User* found2 = nullptr;
            EXPECT_EQ(1, findUserBrent(&table, user1, &found1));
            EXPECT_EQ(1, findUserBrent(&table, user2_name.c_str(), &found2));
            EXPECT_NE(nullptr, found1);
            EXPECT_NE(nullptr, found2);
            break;
        }

        int user2_idx = findIndexByUsername(table, user2_name.c_str());
        if (user2_idx != -1) {
            free(table.table[user2_idx]);
            table.table[user2_idx] = NULL;
        }
    }
}

TEST_F(BrentHashingTest, FindIndexByUsernameReturnsMinusOneWhenNotFound) {
    // Test the return -1 path in findIndexByUsername helper function
    // This covers line 26 in the test file
    ASSERT_EQ(1, insertUserBrent(&table, 123, "existing_user", "pw"));
    
    // Try to find a user that doesn't exist
    int index = findIndexByUsername(table, "nonexistent_user");
    EXPECT_EQ(-1, index);
    
    // Verify existing user can still be found
    int existingIndex = findIndexByUsername(table, "existing_user");
    EXPECT_NE(-1, existingIndex);
    EXPECT_GE(existingIndex, 0);
    EXPECT_LT(existingIndex, TABLE_SIZE);
}

TEST_F(BrentHashingTest, FullTableProbeSequence) {
    freeAll(table);
    ASSERT_EQ(1, initBrentHashTable(&table));

    for (int i = 0; i < TABLE_SIZE - 3; ++i) {
        std::string username = "user_" + std::to_string(i);
        ASSERT_EQ(1, insertUserBrent(&table, 1000 + i, username.c_str(), "pw"));
    }

    EXPECT_GT(countNonNull(table), TABLE_SIZE - 5);

    ASSERT_EQ(1, insertUserBrent(&table, 9999, "final_user", "final_pw"));

    User* found = nullptr;
    EXPECT_EQ(1, findUserBrent(&table, "final_user", &found));
    EXPECT_NE(nullptr, found);
    EXPECT_STREQ("final_user", found->username);
}

TEST_F(BrentHashingTest, FindUserFullTableNotFound) {
    freeAll(table);
    ASSERT_EQ(1, initBrentHashTable(&table));

    for (int i = 0; i < TABLE_SIZE; ++i) {
        std::string username = "filluser_" + std::to_string(i);
        ASSERT_EQ(1, insertUserBrent(&table, 1000 + i, username.c_str(), "pw"));
    }

    EXPECT_EQ(TABLE_SIZE, countNonNull(table));

    User* result = nullptr;
    EXPECT_EQ(0, findUserBrent(&table, "nonexistent_user_12345", &result));
    EXPECT_EQ(nullptr, result);
}

TEST_F(BrentHashingTest, InsertUserWithEmptyStrings) {
    ASSERT_EQ(1, insertUserBrent(&table, 999, "", ""));

    User* found = nullptr;
    EXPECT_EQ(1, findUserBrent(&table, "", &found));
    ASSERT_NE(nullptr, found);
    EXPECT_STREQ("", found->username);
    EXPECT_STREQ("", found->password);
}

TEST_F(BrentHashingTest, InsertUserWithSpecialCharacters) {
    const char* specialUser = "user@domain.com";
    const char* specialPass = "p@$$w0rd!";

    ASSERT_EQ(1, insertUserBrent(&table, 777, specialUser, specialPass));

    User* found = nullptr;
    EXPECT_EQ(1, findUserBrent(&table, specialUser, &found));
    ASSERT_NE(nullptr, found);
    EXPECT_STREQ(specialUser, found->username);
    EXPECT_STREQ(specialPass, found->password);
}

TEST_F(BrentHashingTest, WorstCaseProbeSequence) {
    freeAll(table);
    ASSERT_EQ(1, initBrentHashTable(&table));

    for (int i = 0; i < TABLE_SIZE; ++i) {
        std::string username = "stress" + std::to_string(i);
        int result = insertUserBrent(&table, 5000 + i, username.c_str(), "pw");
        ASSERT_EQ(1, result);
    }

    EXPECT_EQ(TABLE_SIZE, countNonNull(table));
}