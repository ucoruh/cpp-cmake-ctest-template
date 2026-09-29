/**
 * @file calculatorapp.cpp
 * @brief A simple program to demonstrate the usage of the calculator library.
 *
 * Reads one infix expression from standard input, parses and evaluates it
 * with Coruh::Calculator::ExpressionParser (library code, unit tested under
 * src/tests/calculator), and prints the result. All expression parsing logic
 * lives in the calculator library, not here, so it can be unit tested.
 */

// Standard Libraries
#include <iostream>
#include <stdexcept>
#include <string>

#include "../../calculator/header/expressionParser.h"

using namespace Coruh::Calculator;

int main() {
    std::string infix;

    std::cout << "Enter an infix expression: ";
    std::getline(std::cin, infix);

    try {
        double result = ExpressionParser::evaluateInfix(infix);
        std::cout << "Result: " << result << std::endl;
    } catch(const std::invalid_argument& e) {
        std::cerr << "Error: " << e.what() << std::endl;
        return 1;
    }

    return 0;
}
