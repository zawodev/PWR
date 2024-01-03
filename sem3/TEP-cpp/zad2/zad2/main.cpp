#include <iostream>
#include <string>
#include "zad2.hpp"

void addingTest(long long a, long long b) {
	CNumber num1, num3, num4, num5, num6;
	CNumber num2(b);
	num1 = a;
	num3 = num2 + num1;
	num4 = num1 + num2;
	num5 = num2 - num1;
	num6 = num1 - num2;

	std::cout << num2.toString() << " + " << num1.toString() << " = " << num3.toString() << std::endl;
	std::cout << num1.toString() << " + " << num2.toString() << " = " << num4.toString() << std::endl;
	std::cout << num2.toString() << " - " << num1.toString() << " = " << num5.toString() << std::endl;
	std::cout << num1.toString() << " - " << num2.toString() << " = " << num6.toString() << std::endl;

}
void multyplyingTest(long long a, long long b) {
	CNumber num1, num2, num3, num4;
	num1 = a;
	num2 = b;
	num3 = num1 * num2;
	num4 = num2 * num1;

	std::cout << num1.toString() << " * " << num2.toString() << " = " << num3.toString() << std::endl;
	std::cout << num2.toString() << " * " << num1.toString() << " = " << num4.toString() << std::endl;
}
void devidingTest(long long a, long long b) {
	CNumber num1, num2, num3, num4;
	num1 = a;
	num2 = b;
	num3 = num1 / num2;
	num4 = num2 / num1;

	std::cout << num1.toString() << " / " << num2.toString() << " = " << num3.toString() << std::endl;
	std::cout << num2.toString() << " / " << num1.toString() << " = " << num4.toString() << std::endl;
}
void test(long long a, long long b) {
	addingTest(a, b);
	addingTest(-a, b);
	addingTest(a, -b);
	addingTest(-a, -b);

	multyplyingTest(a, b);
	multyplyingTest(-a, b);
	multyplyingTest(a, -b);
	multyplyingTest(-a, -b);

	devidingTest(a, b);
	devidingTest(-a, b);
	devidingTest(a, -b);
	devidingTest(-a, -b);
}
void bigNumberTest() {
	CNumber num1("1234567890");
	CNumber num2("-9999999999999999999999999999999999999999999999999999");
	std::cout << std::endl << num1.toString() << " * " << num2.toString() << " = " << (num1 * num2).toString() << std::endl;
}
void notDefiniedTest() {
	CNumber num1;
	CNumber num2 = 5;
	std::cout << (num1 * num2).toString();
}
void modyfikacja() {
	CNumber m;
	CNumber n;
	int x;
	1234 >= m >= x >= n;
	std::cout << "\n ===== MODYFIKACJA: =====\nm: " << m.toString() << "\nn: " << n.toString() << "\nx: " << x << std::endl;
}
void zad2() {
	std::cout << "===== ZAD 2: =====\n";
	test(13, 37);
	bigNumberTest();
}
int main() {
	zad2();
	modyfikacja();
}
