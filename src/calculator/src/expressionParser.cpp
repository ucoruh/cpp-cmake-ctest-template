#include "../header/expressionParser.h"
#include "../header/calculator.h"

#include <cctype>
#include <sstream>
#include <stack>
#include <stdexcept>

using namespace Coruh::Calculator;

bool ExpressionParser::isOperator(char c) {
    return (c == '+' || c == '-' || c == '*' || c == '/');
}

int ExpressionParser::precedence(char c) {
    if(c == '+' || c == '-') return 1;
    if(c == '*' || c == '/') return 2;
    return 0;
}

std::string ExpressionParser::toPostfix(const std::string& infix) {
    std::stack<char> s;
    std::ostringstream postfix;
    bool expectOperand = true;  // true at the start, after an operator and after '('

    for(size_t i = 0; i < infix.size(); ++i) {
        char c = infix[i];

        if(std::isdigit(static_cast<unsigned char>(c)) || c == '.') {
            if(!expectOperand) {
                throw std::invalid_argument("Missing operator between numbers.");
            }
            // read the whole number (digits and at most one decimal point)
            std::string number;
            bool seenDot = false;
            while(i < infix.size() && (std::isdigit(static_cast<unsigned char>(infix[i])) || infix[i] == '.')) {
                if(infix[i] == '.') {
                    if(seenDot) {
                        throw std::invalid_argument("A number has more than one decimal point.");
                    }
                    seenDot = true;
                }
                number += infix[i++];
            }
            --i;
            if(number == ".") {
                throw std::invalid_argument("A decimal point without digits is not a number.");
            }
            postfix << number << ' ';
            expectOperand = false;
        } else if(isOperator(c)) {
            if(expectOperand) {
                throw std::invalid_argument("An operator is missing its left operand.");
            }
            while(!s.empty() && s.top() != '(' && precedence(s.top()) >= precedence(c)) {
                postfix << s.top() << ' ';
                s.pop();
            }
            s.push(c);
            expectOperand = true;
        } else if(c == '(') {
            if(!expectOperand) {
                throw std::invalid_argument("Missing operator before '('.");
            }
            s.push(c);
        } else if(c == ')') {
            if(expectOperand) {
                throw std::invalid_argument("Empty parentheses or an operator before ')'.");
            }
            while(!s.empty() && s.top() != '(') {
                postfix << s.top() << ' ';
                s.pop();
            }
            if(s.empty()) {
                throw std::invalid_argument("Unmatched ')'.");
            }
            s.pop();  // discard '('
        } else if(!std::isspace(static_cast<unsigned char>(c))) {
            throw std::invalid_argument(std::string("Unexpected character '") + c + "'.");
        }
    }

    if(expectOperand) {
        throw std::invalid_argument(infix.find_first_not_of(" \t\r\n") == std::string::npos
                                    ? "The expression is empty."
                                    : "The expression ends with an operator.");
    }

    while(!s.empty()) {
        if(s.top() == '(') {
            throw std::invalid_argument("Unmatched '('.");
        }
        postfix << s.top() << ' ';
        s.pop();
    }

    return postfix.str();
}

double ExpressionParser::evaluatePostfix(const std::string& postfix) {
    std::stack<double> s;
    std::istringstream iss(postfix);
    std::string token;

    while(iss >> token) {
        if(token.size() == 1 && isOperator(token[0])) {
            if(s.size() < 2) {
                throw std::invalid_argument("Not enough operands for '" + token + "'.");
            }
            double b = s.top(); s.pop();
            double a = s.top(); s.pop();
            double result = 0.0;

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
            try {
                s.push(std::stod(token));
            } catch(const std::exception&) {
                throw std::invalid_argument("'" + token + "' is not a valid number.");
            }
        }
    }

    if(s.size() != 1) {
        throw std::invalid_argument("The expression is not well formed.");
    }
    return s.top();
}

double ExpressionParser::evaluateInfix(const std::string& infix) {
    return evaluatePostfix(toPostfix(infix));
}
