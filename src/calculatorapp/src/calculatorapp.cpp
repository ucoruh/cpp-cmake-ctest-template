/**
 * @file calculatorapp.cpp
 * @brief A simple program to demonstrate the usage of the calculator model class.
 *
 * This program process infix notations and calculate operations
 *
 */

 // Standard Libraries
#include <iostream>
#include <stack>
#include <string>
#include <sstream>
#include <stdexcept>
#include "../../calculator/header/calculator.h"  // Adjust this include path based on your project structure

using namespace Coruh::Calculator;

bool isOperator(char c) {
    return (c == '+' || c == '-' || c == '*' || c == '/');
}

int precedence(char c) {
    if(c == '+' || c == '-') return 1;
    if(c == '*' || c == '/') return 2;
    return 0;
}

std::string infixToPostfix(const std::string& infix) {
    std::stack<char> s;
    std::ostringstream postfix;

    for(char c : infix) {
        if(std::isdigit(c)) {
            postfix << c;
        } else if(isOperator(c)) {
            while(!s.empty() && precedence(s.top()) >= precedence(c)) {
                postfix << ' ' << s.top();
                s.pop();
            }
            postfix << ' ';
            s.push(c);
        } else if(c == '(') {
            s.push(c);
        } else if(c == ')') {
            while(!s.empty() && s.top() != '(') {
                postfix << ' ' << s.top();
                s.pop();
            }
            s.pop();
        }
    }

    while(!s.empty()) {
        postfix << ' ' << s.top();
        s.pop();
    }

    return postfix.str();
}

double evaluatePostfix(const std::string& postfix) {
    std::stack<double> s;
    std::istringstream iss(postfix);
    std::string token;

    while(iss >> token) {
        if(isOperator(token[0])) {
            double b = s.top(); s.pop();
            double a = s.top(); s.pop();
            double result;

            switch(token[0]) {
                case '+': result = Calculator::add(a, b); break;
                case '-': result = Calculator::subtract(a, b); break;
                case '*': result = Calculator::multiply(a, b); break;
                case '/': 
                    if (b == 0) {
                        throw std::invalid_argument("Division by zero is not allowed.");
                    }
                    result = Calculator::divide(a, b); break;
            }

            s.push(result);
        } else {
            s.push(std::stod(token));
        }
    }

    return s.top();
}

int main() {
    std::string infix;

    std::cout << "Enter an infix expression: ";
    std::getline(std::cin, infix);

    try {
        std::string postfix = infixToPostfix(infix);
        double result = evaluatePostfix(postfix);
        std::cout << "Result: " << result << std::endl;
    } catch(const std::invalid_argument& e) {
        std::cerr << "Error: " << e.what() << std::endl;
    }

    return 0;
}
