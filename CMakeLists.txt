cmake_minimum_required(VERSION 3.21)
project(PyBroma)

set(CMAKE_OSX_ARCHITECTURES "arm64;x86_64")

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_POSITION_INDEPENDENT_CODE ON) # fix for -fPIC

include(cmake/CPM.cmake)
CPMAddPackage("gh:geode-sdk/broma#aad1438")

add_subdirectory(pybroma)