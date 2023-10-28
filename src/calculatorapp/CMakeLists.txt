# aka5g/CMakeLists.txt
set(ROOT src)
set(APPNAME calculatorapp)

message(STATUS "[${ROOT}/${APPNAME}] Module Processing...")

# Collect files without having to explicitly list each header and source file
file(GLOB APP_HEADERS
  "${CMAKE_CURRENT_SOURCE_DIR}/header/*.h"
  "${CMAKE_CURRENT_SOURCE_DIR}/header/*.hpp")

file(GLOB APP_SOURCES
  "${CMAKE_CURRENT_SOURCE_DIR}/src/*.cpp"
  "${CMAKE_CURRENT_SOURCE_DIR}/src/*.cc")

# Create named folders for the sources within the project
source_group("header" FILES ${APP_HEADERS})
source_group("src" FILES ${APP_SOURCES})

# Set Properties->General->Configuration Type to Dynamic Library (.dll/.so/.dylib)
add_executable(${APPNAME} ${APP_HEADERS} ${APP_SOURCES}) # for dynamic library use SHARED

target_include_directories(${APPNAME} PUBLIC
						   ${CMAKE_CURRENT_SOURCE_DIR}/../utility/header
						   ${CMAKE_CURRENT_SOURCE_DIR}/../calculator/header
						   ${CMAKE_CURRENT_SOURCE_DIR}/header)

# Add any dependencies or compile options specific to lock6g
target_link_libraries(${APPNAME} PRIVATE calculator utility)

install(TARGETS ${APPNAME}
        LIBRARY DESTINATION lib
        ARCHIVE DESTINATION lib
        RUNTIME DESTINATION bin )
		
		
message(STATUS "[${ROOT}/${APPNAME}] Added Executable target: ${APPNAME}")
