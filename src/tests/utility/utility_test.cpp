//#define ENABLE_UTILITY_TEST

#include "gtest/gtest.h"
#include "../../utility/header/commonTypes.h"
#include "../../utility/header/mathUtility.h"

#include <fstream>
#include <sys/stat.h>
#include <cstdio>
#ifdef _WIN32
#include <direct.h>
#elif __linux__
#include <unistd.h>
#endif


using namespace Coruh::Utility;

class MathUtilityTest : public ::testing::Test {
protected:
	void SetUp() override {
		//Setup test data
	}

	void TearDown() override {
		// Clean up test data
	}
};



TEST_F(MathUtilityTest, CalculateMean) {
	// Test data
	const double data[] = { 1.0, 2.0, 3.0, 4.0, 5.0 };
	const int datalen = sizeof(data) / sizeof(data[0]);

	// Perform the calculation
	double result = MathUtility::calculateMean(data, datalen);

	// Check the result
	EXPECT_DOUBLE_EQ(result, 3.0);
}


TEST_F(MathUtilityTest, CalculateMedianOdd) {
	// Test data
	const double data[] = { 1.0, 2.0, 3.0, 4.0, 5.0 };
	const int datalen = sizeof(data) / sizeof(data[0]);

	// Perform the calculation
	double result = MathUtility::calculateMedian(data, datalen);

	// Check the result
	EXPECT_DOUBLE_EQ(result, 3.0);
}

TEST_F(MathUtilityTest, CalculateMedianEven) {
	// Test data
	const double data[] = { 1.0, 2.0, 3.0, 4.0 };
	const int datalen = sizeof(data) / sizeof(data[0]);

	// Perform the calculation
	double result = MathUtility::calculateMedian(data, datalen);

	// Check the result
	EXPECT_DOUBLE_EQ(result, 2.5);
}

TEST_F(MathUtilityTest, CompareDoubleLessTest) {
	// Test data
	const double val1 = 2.0;
	const double val2 = 4.0;

	// Perform the comparison
	int result = MathUtility::compareDouble(&val1, &val2);

	// Check the result
	EXPECT_EQ(result, -1);
}

TEST_F(MathUtilityTest, CompareDoubleGreaterTest) {
	// Test data
	const double val1 = 4.0;
	const double val2 = 2.0;

	// Perform the comparison
	int result = MathUtility::compareDouble(&val1, &val2);

	// Check the result
	EXPECT_EQ(result, 1);
}

TEST_F(MathUtilityTest, CompareDoubleEqualTest) {
	// Test data
	const double val1 = 3.0;
	const double val2 = 3.0;

	// Perform the comparison
	int result = MathUtility::compareDouble(&val1, &val2);

	// Check the result
	EXPECT_EQ(result, 0);
}

TEST_F(MathUtilityTest, CalculateMinMaxTest_1) {
	// Test data
	const double data[] = { 1.0, 2.0, 3.0, 4.0, 5.0 };
	const int datalen = sizeof(data) / sizeof(data[0]);
	double min, max;

	// Perform the calculation
	MathUtility::calculateMinMax(data, datalen, &min, &max);

	// Check the result
	EXPECT_DOUBLE_EQ(min, 1.0);
	EXPECT_DOUBLE_EQ(max, 5.0);
}

TEST_F(MathUtilityTest, CalculateMinMaxTest_2) {
	double data[] = { 3.14, 1.0, -2.5, 7.2, -5.0 };
	double min, max;

	MathUtility::calculateMinMax(data, sizeof(data) / sizeof(data[0]), &min, &max);

	EXPECT_DOUBLE_EQ(min, -5.0);
	EXPECT_DOUBLE_EQ(max, 7.2);
}


/**
 * @brief The main function of the test program.
 *
 * @param argc The number of command-line arguments.
 * @param argv An array of command-line argument strings.
 * @return int The exit status of the program.
 */
int main(int argc, char** argv) {
#ifdef ENABLE_UTILITY_TEST
	::testing::InitGoogleTest(&argc, argv);
	return RUN_ALL_TESTS();
#else
	return 0;
#endif
}