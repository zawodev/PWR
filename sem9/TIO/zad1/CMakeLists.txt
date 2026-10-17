cmake_minimum_required(VERSION 3.16)

project(LcVRPContest LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

add_executable(LcVRPContest
    Evaluator.cpp
    LcVRPContest.cpp
    Optimizer.cpp
    ProblemData.cpp
    ProblemLoader.cpp
)

if(MSVC)
    target_compile_options(LcVRPContest PRIVATE /W4)
else()
    target_compile_options(LcVRPContest PRIVATE -Wall -Wextra -Wpedantic)
endif()
