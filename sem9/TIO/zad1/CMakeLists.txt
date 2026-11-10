cmake_minimum_required(VERSION 3.16)

project(LcVRPContest LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

add_executable(LcVRPContest
    Evaluator.cpp
    LcVRPContest.cpp
    ProblemData.cpp
    ProblemLoader.cpp
    optimizer1/Optimizer.cpp
    optimizer0/MyEvaluator.cpp
    optimizer0/Optimizer.cpp
    optimizer0/Individual.cpp
    optimizer2/Optimizer.cpp
    optimizer3/Optimizer3.cpp
)

if(MSVC)
    target_compile_options(LcVRPContest PRIVATE /W4)
else()
    target_compile_options(LcVRPContest PRIVATE -Wall -Wextra -Wpedantic)
endif()
