# Set the minimum required CMake version
cmake_minimum_required(VERSION 3.12)
project(calculatorapp)

set(ROOT src)

# Print useful information
message(STATUS "[${ROOT}] CMake version ${CMAKE_VERSION}")
message(STATUS "[${ROOT}] System ${CMAKE_SYSTEM_NAME}")
message(STATUS "[${ROOT}] Processor ${CMAKE_SYSTEM_PROCESSOR}")

# GoogleTest requires at least C++11
if(NOT "${CMAKE_CXX_STANDARD}")
  set(CMAKE_CXX_STANDARD 11)
  message(STATUS "[${ROOT}] Default C++ Standard Selected: ${CMAKE_CXX_STANDARD}")
endif()

message(STATUS "[${ROOT}] C++ standard version: ${CMAKE_CXX_STANDARD}")

# Set the default installation directory
if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
    set(CMAKE_INSTALL_PREFIX "${PROJECT_BINARY_DIR}/install" CACHE PATH "Default installation directory" FORCE)
endif()

message(STATUS "[${ROOT}] Folder is set to : ${CMAKE_INSTALL_PREFIX}")

set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Enable testing
enable_testing()

# Set build configurations
set(CMAKE_CONFIGURATION_TYPES "Debug;Release" CACHE STRING "" FORCE)

#crypto++ settings, disable testing, documentation generation, install and DLL generation
set(CRYPTOPP_BUILD_TESTING OFF)
set(CRYPTOPP_BUILD_DOCUMENTATION OFF)
set(CRYPTOPP_INSTALL ON)
set(CRYPTOPP_BUILD_SHARED OFF)
set(CRYPTOPP_USE_MASTER_BRANCH FALSE)

option(ENABLE_UTILITY "Enable Utility Module" ON)
option(ENABLE_CALCULATOR "Enable Calculator Module" ON)
option(ENABLE_CALCULATOR_APP "Enable Calculator Application" ON)
option(ENABLE_TESTS "Enable All Tests" ON)

# Configure tests
add_compile_definitions(ENABLE_UTILITY_TEST)
add_compile_definitions(ENABLE_CALCULATOR_TEST)


# Configure logs
add_compile_definitions(ENABLE_UTILITY_LOGGER)
add_compile_definitions(ENABLE_CALCULATOR_LOGGER)

# Set the output directories for Debug and Release configurations
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY_DEBUG ${CMAKE_BINARY_DIR}/build/Debug)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY_RELEASE ${CMAKE_BINARY_DIR}/build/Release)

# Custom definitions based on environment
if(MSVC)
  add_definitions(-DMSVC_ENV)
endif()

if(CMAKE_COMPILER_IS_GNUCXX)
  add_definitions(-DGCC_ENV)
endif()

if(${CMAKE_SYSTEM_NAME} MATCHES "Darwin")
  add_definitions(-DMAC_ENV)
endif()

# Set Debug and Release configuration flags
if("${CMAKE_CXX_COMPILER_ID}" STREQUAL "GNU" OR "${CMAKE_CXX_COMPILER_ID}" MATCHES "Clang")
  message(STATUS "[${ROOT}] Setting Ubuntu/MacOS C/C++ Flags")

  set(COMP_WARNINGS "-Wall -Wextra -Wunused-function -Wno-unknown-pragmas")
  set(COMP_PROFILE "-fprofile-arcs -ftest-coverage")
  set(COMP_OPTIMIZATION "-O0") #for debugging
  set(COMP_SHARED "-shared -fPIC")

  set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -g ${COMP_OPTIMIZATION} ${COMP_WARNINGS} ${COMP_PROFILE}")
  set(CMAKE_C_FLAGS_DEBUG "${CMAKE_C_FLAGS_DEBUG} -g ${COMP_OPTIMIZATION} ${COMP_WARNINGS} ${COMP_PROFILE}")

  set(CMAKE_EXE_LINKER_FLAGS_DEBUG "${CMAKE_EXE_LINKER_FLAGS_DEBUG} ${COMP_WARNINGS} ${COMP_PROFILE}")
  set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} ${COMP_WARNINGS} ${COMP_PROFILE}")

elseif("${CMAKE_CXX_COMPILER_ID}" STREQUAL "MSVC")
  message(STATUS "[${ROOT}] Setting Windows C/C++ Flags")
  set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} /MTd")
  set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} /MT")
else()
  message(WARNING "[${ROOT}] Not supported with the current compiler.")
endif()



# Utility submodule
if(ENABLE_UTILITY)
	add_subdirectory(${ROOT}/utility)
endif()

# Logger submodule
if(ENABLE_CALCULATOR)
	add_subdirectory(${ROOT}/calculator)
endif()

# BigInteger for Crypto submodule
if(ENABLE_CALCULATOR_APP)
	add_subdirectory(${ROOT}/calculatorapp)
endif()

# Tests
if(ENABLE_TESTS)
	add_subdirectory(${ROOT}/tests)
endif()

# Include the Google Test framework
# add_subdirectory(src/tests/googletest)


