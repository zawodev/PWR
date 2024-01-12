#include <iostream>
#include "MyUniquePointer.hpp"

int main() {
    MyUniquePointer<int> ptr1(new int(5));
    MyUniquePointer<int> ptr2(new int(8));
    MyUniquePointer<int> ptr3(new int(9));
    
    //ptr1 = ptr2;
    ptr1 = std::move(ptr2);

    MyUniquePointer<int> ptr3(ptr2);
    MyUniquePointer<int> ptr4(std::move(ptr3));

    std::cout << *ptr1 << std::endl;
    std::cout << *ptr4 << std::endl << std::endl;

    MyUniquePointer<int[]> ptr5(new int[5]);
    MyUniquePointer<int[]> ptr6(new int[5]);

    for (int i = 0; i < 5; i++) {
		ptr5[i] = i;
		ptr6[i] = i + 5;
	}
    ptr5 = std::move(ptr6);

    for (int i = 0; i < 5; i++) {
        std::cout << ptr5[i] << std::endl;
    }
}