# Set the minimum required CMake version. 3.16 (not 3.12) because the
# googletest submodule's own top-level CMakeLists.txt already requires 3.16 -
# this project could never actually configure below that anyway (verified:
# src/tests/googletest/CMakeLists.txt has cmake_minimum_required(VERSION 3.16)).
cmake_minimum_required(VERSION 3.16)

# Project identity comes from project.env (PROJECT_NAME, VERSION) - the one place to rename the project.
file(STRINGS "${CMAKE_CURRENT_SOURCE_DIR}/project.env" PROJECT_ENV_LINES REGEX "^[A-Za-z_]+=")
foreach(env_line IN LISTS PROJECT_ENV_LINES)
  if(env_line MATCHES "^([A-Za-z_]+)=(.*)$")
    set(PROJECT_ENV_${CMAKE_MATCH_1} "${CMAKE_MATCH_2}")
  endif()
endforeach()
set_property(DIRECTORY APPEND PROPERTY CMAKE_CONFIGURE_DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/project.env")
project(${PROJECT_ENV_PROJECT_NAME} VERSION ${PROJECT_ENV_VERSION} LANGUAGES C CXX)

set(ROOT src)

# Print useful information
message(STATUS "[${ROOT}] CMake version ${CMAKE_VERSION}")
message(STATUS "[${ROOT}] System ${CMAKE_SYSTEM_NAME}")
message(STATUS "[${ROOT}] Processor ${CMAKE_SYSTEM_PROCESSOR}")

# GoogleTest 1.15+ requires a C++17-capable compiler; default to C++17 unless
# the caller already requested a specific standard with -DCMAKE_CXX_STANDARD=..
if(NOT "${CMAKE_CXX_STANDARD}")
  set(CMAKE_CXX_STANDARD 17)
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

# Set build configurations: multi-config generators (Visual Studio) offer Debug and Release, single-config
# ones (Ninja, Makefiles) build the CMAKE_BUILD_TYPE given at configure time (Debug if none was given).
get_property(IS_MULTI_CONFIG GLOBAL PROPERTY GENERATOR_IS_MULTI_CONFIG)
if(IS_MULTI_CONFIG)
  set(CMAKE_CONFIGURATION_TYPES "Debug;Release" CACHE STRING "" FORCE)
elseif(NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE Debug CACHE STRING "Build type" FORCE)
endif()

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
# (build/<platform>-<config>/bin/<Config>/, e.g. build/windows-debug/bin/Debug/calculator_tests.exe)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY_DEBUG ${CMAKE_BINARY_DIR}/bin/Debug)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY_RELEASE ${CMAKE_BINARY_DIR}/bin/Release)

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
  # Coverage instrumentation (COMP_PROFILE) is Debug-only: the Release build (and the release archives) stay clean.
  set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} ${COMP_WARNINGS}")

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


