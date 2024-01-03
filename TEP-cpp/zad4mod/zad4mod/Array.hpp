#ifndef ARRAY_HPP
#define ARRAY_HPP
#pragma once

template <typename T> class Array {
private:
	T* myArray;
public:
	Array(size_t size) {
		myArray = new T[size];
	}

	T& operator[](size_t index) {
		return myArray[index];
	}
};

template<>
class Array<std::string>;


#endif

