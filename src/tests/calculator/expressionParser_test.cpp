// Unit tests for Coruh::Calculator::ExpressionParser.
//
// Note: this translation unit intentionally does NOT define main(); it is
// compiled into the same calculator_tests executable as calculator_test.cpp,
// whose main() already calls RUN_ALL_TESTS() and picks up every TEST/TEST_F
// registered anywhere in the binary.

#include "gtest/gtest.h"
#include "../../calculator/header/expressionParser.h"  // Adjust this include path based on your project structure

#include <stdexcept>

using namespace Coruh::Calculator;

class ExpressionParserTest : public ::testing::Test {
protected:
    void SetUp() override {
        // Setup test data
    }

    void TearDown() override {
        // Clean up test data
    }
};

// ---------------------------------------------------------------------------
// Normal expressions
// ---------------------------------------------------------------------------

TEST_F(ExpressionParserTest, AddsTwoIntegers) {
    EXPECT_DOUBLE_EQ(ExpressionParser::evaluateInfix("2+3"), 5.0);
}

TEST_F(ExpressionParserTest, SubtractsTwoIntegers) {
    EXPECT_DOUBLE_EQ(ExpressionParser::evaluateInfix("10-4"), 6.0);
}

TEST_F(ExpressionParserTest, MultipliesTwoIntegers) {
    EXPECT_DOUBLE_EQ(ExpressionParser::evaluateInfix("6*7"), 42.0);
}

TEST_F(ExpressionParserTest, DividesTwoIntegers) {
    EXPECT_DOUBLE_EQ(ExpressionParser::evaluateInfix("20/4"), 5.0);
}

TEST_F(ExpressionParserTest, HandlesMultiDigitNumbers) {
    EXPECT_DOUBLE_EQ(ExpressionParser::evaluateInfix("123+456"), 579.0);
}

TEST_F(ExpressionParserTest, IgnoresWhitespaceBetweenTokens) {
    EXPECT_DOUBLE_EQ(ExpressionParser::evaluateInfix("  2  +  3  *  4  "), 14.0);
}

// ---------------------------------------------------------------------------
// Operator precedence and associativity
// ---------------------------------------------------------------------------

TEST_F(ExpressionParserTest, MultiplicationBindsTighterThanAddition) {
    EXPECT_DOUBLE_EQ(ExpressionParser::evaluateInfix("2+3*4"), 14.0);
    EXPECT_DOUBLE_EQ(ExpressionParser::evaluateInfix("2*3+4"), 10.0);
}

TEST_F(ExpressionParserTest, DivisionBindsTighterThanSubtraction) {
    EXPECT_DOUBLE_EQ(ExpressionParser::evaluateInfix("10-8/4"), 8.0);
}

TEST_F(ExpressionParserTest, SameLevelOperatorsAreLeftAssociative) {
    EXPECT_DOUBLE_EQ(ExpressionParser::evaluateInfix("2-3-4"), -5.0);
    EXPECT_DOUBLE_EQ(ExpressionParser::evaluateInfix("20/4/5"), 1.0);
}

// ---------------------------------------------------------------------------
// Parentheses
// ---------------------------------------------------------------------------

TEST_F(ExpressionParserTest, ParenthesesOverridePrecedence) {
    EXPECT_DOUBLE_EQ(ExpressionParser::evaluateInfix("(2+3)*4"), 20.0);
    EXPECT_DOUBLE_EQ(ExpressionParser::evaluateInfix("2*(3+4)"), 14.0);
}

TEST_F(ExpressionParserTest, NestedParenthesesAreSupported) {
    EXPECT_DOUBLE_EQ(ExpressionParser::evaluateInfix("((2+3)*(4-1))"), 15.0);
    EXPECT_DOUBLE_EQ(ExpressionParser::evaluateInfix("(((1+2)))"), 3.0);
}

// ---------------------------------------------------------------------------
// Decimal numbers
// ---------------------------------------------------------------------------

TEST_F(ExpressionParserTest, AddsDecimalNumbers) {
    EXPECT_DOUBLE_EQ(ExpressionParser::evaluateInfix("1.5+2.25"), 3.75);
}

TEST_F(ExpressionParserTest, HandlesLeadingAndTrailingDecimalPoint) {
    EXPECT_DOUBLE_EQ(ExpressionParser::evaluateInfix(".5+1"), 1.5);
    EXPECT_DOUBLE_EQ(ExpressionParser::evaluateInfix("5.+1"), 6.0);
}

TEST_F(ExpressionParserTest, DecimalPrecisionIsPreserved) {
    EXPECT_NEAR(ExpressionParser::evaluateInfix("0.1+0.2"), 0.3, 1e-9);
}

// ---------------------------------------------------------------------------
// Error cases: toPostfix() / evaluateInfix() input validation
// ---------------------------------------------------------------------------

TEST_F(ExpressionParserTest, EmptyExpressionThrows) {
    EXPECT_THROW(ExpressionParser::evaluateInfix(""), std::invalid_argument);
}

TEST_F(ExpressionParserTest, WhitespaceOnlyExpressionThrows) {
    EXPECT_THROW(ExpressionParser::evaluateInfix("   "), std::invalid_argument);
}

TEST_F(ExpressionParserTest, ExpressionEndingWithOperatorThrows) {
    EXPECT_THROW(ExpressionParser::evaluateInfix("2+"), std::invalid_argument);
}

TEST_F(ExpressionParserTest, MissingLeftOperandThrows) {
    EXPECT_THROW(ExpressionParser::evaluateInfix("*5"), std::invalid_argument);
    EXPECT_THROW(ExpressionParser::evaluateInfix("/5"), std::invalid_argument);
}

TEST_F(ExpressionParserTest, TwoNumbersWithoutOperatorThrows) {
    EXPECT_THROW(ExpressionParser::evaluateInfix("2 3"), std::invalid_argument);
}

TEST_F(ExpressionParserTest, MissingOperatorBeforeParenthesisThrows) {
    EXPECT_THROW(ExpressionParser::evaluateInfix("2(3+4)"), std::invalid_argument);
}

TEST_F(ExpressionParserTest, EmptyParenthesesThrow) {
    EXPECT_THROW(ExpressionParser::evaluateInfix("()"), std::invalid_argument);
}

TEST_F(ExpressionParserTest, OperatorBeforeClosingParenthesisThrows) {
    EXPECT_THROW(ExpressionParser::evaluateInfix("(2+)"), std::invalid_argument);
}

TEST_F(ExpressionParserTest, UnmatchedClosingParenthesisThrows) {
    EXPECT_THROW(ExpressionParser::evaluateInfix("2+3)"), std::invalid_argument);
}

TEST_F(ExpressionParserTest, UnmatchedOpeningParenthesisThrows) {
    EXPECT_THROW(ExpressionParser::evaluateInfix("(2+3"), std::invalid_argument);
}

TEST_F(ExpressionParserTest, TwoDecimalPointsInOneNumberThrows) {
    EXPECT_THROW(ExpressionParser::evaluateInfix("1.2.3"), std::invalid_argument);
}

TEST_F(ExpressionParserTest, LoneDecimalPointThrows) {
    EXPECT_THROW(ExpressionParser::evaluateInfix("."), std::invalid_argument);
    EXPECT_THROW(ExpressionParser::evaluateInfix("2+."), std::invalid_argument);
}

TEST_F(ExpressionParserTest, UnexpectedCharacterThrows) {
    try {
        ExpressionParser::evaluateInfix("2+a");
        FAIL() << "Expected std::invalid_argument";
    } catch(const std::invalid_argument& e) {
        EXPECT_NE(std::string(e.what()).find('a'), std::string::npos);
    }
}

TEST_F(ExpressionParserTest, UnsupportedOperatorCharacterThrows) {
    EXPECT_THROW(ExpressionParser::evaluateInfix("2^3"), std::invalid_argument);
}

TEST_F(ExpressionParserTest, DivisionByZeroThrows) {
    EXPECT_THROW(ExpressionParser::evaluateInfix("5/0"), std::invalid_argument);
}

// ---------------------------------------------------------------------------
// Error cases: evaluatePostfix() called directly with a malformed postfix
// string (defends the library entry point, not just the infix parser).
// ---------------------------------------------------------------------------

TEST_F(ExpressionParserTest, EvaluatePostfixWithTooFewOperandsThrows) {
    EXPECT_THROW(ExpressionParser::evaluatePostfix("3 +"), std::invalid_argument);
}

TEST_F(ExpressionParserTest, EvaluatePostfixWithLeftoverOperandsThrows) {
    EXPECT_THROW(ExpressionParser::evaluatePostfix("3 4"), std::invalid_argument);
}

TEST_F(ExpressionParserTest, EvaluatePostfixWithInvalidTokenThrows) {
    EXPECT_THROW(ExpressionParser::evaluatePostfix("x"), std::invalid_argument);
}

// ---------------------------------------------------------------------------
// toPostfix() output shape (spot-check, not just the final numeric result)
// ---------------------------------------------------------------------------

TEST_F(ExpressionParserTest, ToPostfixProducesReversePolishNotation) {
    EXPECT_EQ(ExpressionParser::toPostfix("2+3*4"), "2 3 4 * + ");
    EXPECT_EQ(ExpressionParser::toPostfix("(2+3)*4"), "2 3 + 4 * ");
}
