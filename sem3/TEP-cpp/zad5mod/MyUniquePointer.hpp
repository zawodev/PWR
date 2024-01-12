#ifndef MYUNIQUEPOINTER_HPP
#define MYUNIQUEPOINTER_HPP
#pragma once
//====================================================================================================
#include "CRefCounter.hpp"

template <typename T> class MyUniquePointer {
public:
    MyUniquePointer(T* pcPointer) {
        pc_pointer = pcPointer;
    }
    /*
    MyUniquePointer(const MyUniquePointer& pcOther) {
        pc_pointer = pcOther.pc_pointer;
        pc_counter = pcOther.pc_counter;
        pc_counter->iAdd();
    }
    */
    MyUniquePointer(MyUniquePointer&& pcOther) {
		pc_pointer = pcOther.pc_pointer;
		pcOther.pc_pointer = nullptr;
	}

    ~MyUniquePointer() {
        delete pc_pointer;
    }

    T& operator*() {
        return *pc_pointer;
    }

    T* operator->() {
        return pc_pointer;
    }
    /*
    MyUniquePointer& operator=(const MyUniquePointer& pcOther) {
        if (this != &pcOther) {
            if (pc_counter->iDec() == 0) {
                delete pc_pointer;
                delete pc_counter;
            }

            pc_pointer = pcOther.pc_pointer;
            pc_counter = pcOther.pc_counter;
            pc_counter->iAdd();
        }
        return *this;
    }
    */
    MyUniquePointer& operator=(MyUniquePointer&& pcOther) {
        if (this != &pcOther) {
            delete pc_pointer;
			pc_pointer = pcOther.pc_pointer;
			pcOther.pc_pointer = nullptr;
		}
        return *this;
    }

private:
    T* pc_pointer;
};

template<typename T>class MyUniquePointer<T[]> {
public:
    MyUniquePointer(T* pcPointer) {
        pc_pointer = pcPointer;
    }
    MyUniquePointer(MyUniquePointer&& pcOther) {
        pc_pointer = pcOther.pc_pointer;
        pcOther.pc_pointer = nullptr;
    }

    ~MyUniquePointer() {
        delete[] pc_pointer;
    }

    T& operator*() {
        return *pc_pointer;
    }

    T* operator->() {
        return pc_pointer;
    }
    MyUniquePointer& operator=(MyUniquePointer&& pcOther) {
        if (this != &pcOther) {
            delete[] pc_pointer;
            pc_pointer = pcOther.pc_pointer;
            pcOther.pc_pointer = nullptr;
        }
        return *this;
    }


    T& operator[](size_t index) {
        return pc_pointer[index];
    }

private:
    T* pc_pointer;
};
#endif