//#define ENABLE_CALCULATOR_TEST  // Uncomment this line to enable the Calculator tests

#include "gtest/gtest.h"
#include "../../calculator/header/calculator.h"  // Adjust this include path based on your project structure

using namespace Coruh::Calculator;

class CalculatorTest : public ::testing::Test {
protected:
	void SetUp() override {
		// Setup test data
	}

	void TearDown() override {
		// Clean up test data
	}
};

TEST_F(CalculatorTest, TestAdd) {
	double result = Calculator::add(5.0, 3.0);
	EXPECT_DOUBLE_EQ(result, 8.0);
}

TEST_F(CalculatorTest, TestSubtract) {
	double result = Calculator::subtract(5.0, 3.0);
	EXPECT_DOUBLE_EQ(result, 2.0);
}

TEST_F(CalculatorTest, TestMultiply) {
	double result = Calculator::multiply(5.0, 3.0);
	EXPECT_DOUBLE_EQ(result, 15.0);
}

TEST_F(CalculatorTest, TestDivide) {
	double result = Calculator::divide(6.0, 3.0);
	EXPECT_DOUBLE_EQ(result, 2.0);
}

TEST_F(CalculatorTest, TestDivideByZero) {
	EXPECT_THROW(Calculator::divide(5.0, 0.0), std::invalid_argument);
}

/**
 * @brief The main function of the test program.
 *
 * @param argc The number of command-line arguments.
 * @param argv An array of command-line argument strings.
 * @return int The exit status of the program.
 */
int main(int argc, char** argv) {
#ifdef ENABLE_CALCULATOR_TEST
	::testing::InitGoogleTest(&argc, argv);
	return RUN_ALL_TESTS();
#else
	return 0;
#endif
}