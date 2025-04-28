cmake_minimum_required(VERSION 3.21)

project(PyBroma)
find_package(Python3 COMPONENTS Interpreter Development REQUIRED)

set(CYTHON_SRC ${CMAKE_CURRENT_SOURCE_DIR}/${PROJECT_NAME}.cpp)
set(PYX_SRC ${CMAKE_CURRENT_SOURCE_DIR}/${PROJECT_NAME}.pyx)
add_custom_command(
    OUTPUT ${CYTHON_SRC}
    COMMAND ${Python3_EXECUTABLE} -m cython -3 --cplus ${PYX_SRC} -o ${CYTHON_SRC}
    DEPENDS ${PYX_SRC}
)

add_library(${PROJECT_NAME} MODULE ${CYTHON_SRC})

target_include_directories(${PROJECT_NAME} PRIVATE ${Python3_INCLUDE_DIRS})
target_link_libraries(${PROJECT_NAME} PRIVATE Broma ${Python3_LIBRARIES})

set_target_properties(${PROJECT_NAME} PROPERTIES PREFIX "")
install(TARGETS ${PROJECT_NAME} LIBRARY DESTINATION ${CMAKE_INSTALL_PREFIX})