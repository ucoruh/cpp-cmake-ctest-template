/**
 * @file commonTypes.h
 * 
 * @brief Provides cross-platform type definitions
 */

#ifndef COMMON_TYPES_H
#define COMMON_TYPES_H

#include <stdexcept> // Include for standard exception classes

#if defined(_WIN32)
#include <cstddef>
#include <cstdint>    ///< Include for standard integer types on Windows
#include <inttypes.h> ///< Include for integer format macros on Windows
#elif defined(__linux__)
#include <cstddef>
#include <cstdint>
#include <stdint.h>   ///< Include for standard integer types on Linux
#include <inttypes.h> ///< Include for integer format macros on Linux
#elif defined(__APPLE__)
#include <cstddef>
#include <cstdint>
#include <stdint.h>   ///< Include for standard integer types on Apple platforms
#include <inttypes.h> ///< Include for integer format macros on Apple platforms
#endif

#endif // COMMON_TYPES_H
