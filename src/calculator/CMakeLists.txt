# crypto/CMakeLists.txt
set(ROOT src)
set(LIBNAME calculator)

message(STATUS "[${ROOT}/${LIBNAME}] Module Processing...")

# Collect files without having to explicitly list each header and source file
file(GLOB LIB_HEADERS
  "${CMAKE_CURRENT_SOURCE_DIR}/header/*.h"
  "${CMAKE_CURRENT_SOURCE_DIR}/header/*.hpp")

file(GLOB LIB_SOURCES
  "${CMAKE_CURRENT_SOURCE_DIR}/src/*.cpp"
  "${CMAKE_CURRENT_SOURCE_DIR}/src/*.cc")

# Create named folders for the sources within the project
source_group("header" FILES ${LIB_HEADERS})
source_group("src" FILES ${LIB_SOURCES})

# Set Properties->General->Configuration Type to Dynamic Library (.dll/.so/.dylib)
add_library(${LIBNAME} STATIC ${LIB_HEADERS} ${LIB_SOURCES}) # for dynamic library use SHARED

target_include_directories(${LIBNAME} PUBLIC
						   ${CMAKE_CURRENT_SOURCE_DIR}/../utility/header
						   ${CMAKE_CURRENT_SOURCE_DIR}/header)

# Add any dependencies or compile options specific to crypto
target_link_libraries(${LIBNAME} PRIVATE utility)

# creates preprocessor definition used for library exports
add_compile_definitions("CORUH_CALCULATOR_LIB_EXPORTS")

install(TARGETS ${LIBNAME}
        LIBRARY DESTINATION lib
        ARCHIVE DESTINATION lib
        RUNTIME DESTINATION bin )
		
# Copy required header to the installation include folder		
install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/header/calculator.h
        DESTINATION include)

# Export the crypto target so other modules can use it
# export(TARGETS ${LIBNAME} FILE ${LIBNAME}Targets.cmake)

message(STATUS "[${ROOT}/${LIBNAME}] Added library target: ${LIBNAME}")
