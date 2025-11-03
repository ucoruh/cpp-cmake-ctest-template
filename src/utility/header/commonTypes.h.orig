/**
 * @file commonTypes.h
 *
 * @brief Provides cross-platform type definitions
 */

#ifndef COMMON_TYPES_H
#define COMMON_TYPES_H

#include <stdexcept> // Include for standard exception classes
#include <stack>
#include <string>
#include <sstream>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <iostream>
#include <fstream>
#include <memory>

#if defined(_WIN32)
#include <cstddef>
#include <cstdint>    ///< Include for standard integer types on Windows
#include <inttypes.h> ///< Include for integer format macros on Windows
#include <conio.h>
#include <windows.h>
#elif defined(__linux__)
#include <cstddef>
#include <cstdint>
#include <stdint.h>   ///< Include for standard integer types on Linux
#include <inttypes.h> ///< Include for integer format macros on Linux
#include <termios.h>
#include <unistd.h>
#elif defined(__APPLE__)
#include <cstddef>
#include <cstdint>
#include <stdint.h>   ///< Include for standard integer types on Apple platforms
#include <inttypes.h> ///< Include for integer format macros on Apple platforms
#include <termios.h>
#include <unistd.h>
#endif

#endif // COMMON_TYPES_H
