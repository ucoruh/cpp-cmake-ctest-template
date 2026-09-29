/**
 * @file expressionParser.h
 *
 * @brief Converts an infix arithmetic expression to postfix (Reverse Polish
 *        Notation) and evaluates it, on top of the Calculator functions.
 */

#ifndef EXPRESSION_PARSER_H
#define EXPRESSION_PARSER_H

#include <string>

namespace Coruh
{
    namespace Calculator
    {
        /**
            @class ExpressionParser
            @brief Parses and evaluates infix arithmetic expressions built from
                   +, -, *, /, parentheses, and (possibly decimal) numbers.

            This class used to live inline inside the calculatorapp sample
            application; it was moved into the library so it can be unit
            tested with googletest independently of the interactive app.
        */
        class ExpressionParser
        {
        public:
            /**
             * @brief Converts an infix expression to postfix (RPN) notation
             *        using the shunting-yard algorithm.
             *
             * @param infix The infix expression, e.g. "2 + 3 * (4 - 1)".
             * @return The postfix form, tokens separated by single spaces,
             *         e.g. "2 3 4 1 - * +".
             * @throws std::invalid_argument If the expression is empty, has
             *         an unmatched '(' or ')', is missing an operand or an
             *         operator, has a number with more than one decimal
             *         point or a decimal point with no digits, or contains
             *         a character that is not a digit, '.', an operator, a
             *         parenthesis, or whitespace.
             */
            static std::string toPostfix(const std::string& infix);

            /**
             * @brief Evaluates a postfix (RPN) expression as produced by
             *        toPostfix().
             *
             * @param postfix The postfix expression, tokens separated by
             *        whitespace.
             * @return The numeric result.
             * @throws std::invalid_argument If there are not enough operands
             *         for an operator, the expression does not reduce to a
             *         single value, or a division by zero is attempted.
             */
            static double evaluatePostfix(const std::string& postfix);

            /**
             * @brief Convenience helper: parses and evaluates an infix
             *        expression in one call (toPostfix() + evaluatePostfix()).
             *
             * @param infix The infix expression.
             * @return The numeric result.
             * @throws std::invalid_argument See toPostfix() and
             *         evaluatePostfix().
             */
            static double evaluateInfix(const std::string& infix);

        private:
            /// True for '+', '-', '*', '/'.
            static bool isOperator(char c);

            /// Operator precedence: 2 for '*','/'; 1 for '+','-'; 0 otherwise.
            static int precedence(char c);
        };
    }
}

#endif // EXPRESSION_PARSER_H
