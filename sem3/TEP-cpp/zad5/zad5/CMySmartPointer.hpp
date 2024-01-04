#ifndef CMYSMARTPOINTER_HPP
#define CMYSMARTPOINTER_HPP
#pragma once
//====================================================================================================
#include "CRefCounter.hpp"

template <typename T> class CMySmartPointer {
public:
    CMySmartPointer(T* pcPointer) {
        pc_pointer = pcPointer;
        pc_counter = new CRefCounter();
        pc_counter->iAdd();
    }

    CMySmartPointer(const CMySmartPointer& pcOther) {
        pc_pointer = pcOther.pc_pointer;
        pc_counter = pcOther.pc_counter;
        pc_counter->iAdd();
    }

    ~CMySmartPointer() {
        if (pc_counter->iDec() == 0) {
            delete pc_pointer;
            delete pc_counter;
        }
    }

    T& operator*() {
        return (*pc_pointer);
    }

    T* operator->() {
        return (pc_pointer);
    }

    CMySmartPointer& operator=(const CMySmartPointer& pcOther) {
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

private:
    CRefCounter* pc_counter;
    T* pc_pointer;
};
#endif