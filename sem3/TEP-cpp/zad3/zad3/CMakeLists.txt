cmake_minimum_required(VERSION 3.27)
project(zad3)

set(CMAKE_CXX_STANDARD 14)

include_directories(.)

add_executable(zad3
        CNode.cpp
        CNode.hpp
        CTree.cpp
        CTree.hpp
        GUI.cpp
        GUI.hpp
        main.cpp
        zad3.cpp
        zad3.hpp)
