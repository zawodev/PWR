#include <iostream>
#include <string>
#include "zad2.hpp"

CNumber::CNumber(std::string strDigits) {
	if (strDigits[0] == '-') negative = true;
	else negative = false;

	int neg = negative ? 1 : 0;
	size = (int)strDigits.size() - neg;
	digits = new int[size];

	for (int i = 0; i < size; i++) {
		digits[i] = ((int)strDigits[i + neg]) - '0';
	}
}
CNumber::CNumber(int size, int vals) : size(size), digits(new int[size]), negative(false) {
	for (int i = 0; i < size; i++) {
		digits[i] = vals;
	}
}
CNumber::CNumber(const CNumber& pcOther){
	negative = pcOther.negative;
	size = pcOther.size;
	digits = new int[size];
	for (int i = 0; i < size; i++) {
		digits[i] = pcOther.digits[i];
	}
}
CNumber::CNumber(long long val) {
	int tempSize = 1;
	long long tempVal = val;
	while (tempVal / 10 != 0) {
		tempVal /= 10;
		tempSize++;
	}
	//==============================
	negative = val < 0;
	size = tempSize;
	digits = new int[size];
	tempVal = negative ? -val : val;
	for (int i = size - 1; i >= 0; i--) {
		digits[i] = tempVal % 10;
		tempVal /= 10;
	}
}

CNumber& CNumber::operator=(const CNumber& pcOther){
	if (this == &pcOther) return *this; //t=t; zabezpieczenie
	delete[] digits;
	size = pcOther.size;
	negative = pcOther.negative;
	digits = new int[size];
	for (int i = 0; i < size; ++i) {
		digits[i] = pcOther.digits[i];
	}
	return *this;
}
CNumber& CNumber::operator=(const long long val) {
	int tempSize = 1;
	long long tempVal = val;
	while (tempVal / 10 != 0) {
		tempVal /= 10;
		tempSize++;
	}
	//==============================
	negative = val < 0;
	size = tempSize;
	delete[] digits;
	digits = new int[size];
	tempVal = negative ? -val : val;
	for (int i = size - 1; i >= 0; i--) {
		digits[i] = tempVal % 10;
		tempVal /= 10;
	}

	return *this;
}

CNumber CNumber::operator+(const CNumber& pcOther) {

	if ((*this).digits == nullptr || pcOther.digits == nullptr) return CNumber();

	/*
	CNumber result;
	result.size = std::max(size, pcOther.size) + 1;
	result.digits = new int[result.size];
	
	for (int i = 0; i < result.size; i++) {
		result.digits[i] = 0;
	}
	*/
	//============================================

	CNumber result(std::max(size, pcOther.size) + 1, 0);
	CNumber num1, num2;
	num1 = *this; num1.negative = false;
	num2 = pcOther; num2.negative = false;

	//============================================

	if (((*this).negative && !(num1 < num2)) || (pcOther.negative && !(num2 < num1))) {
		result.negative = !result.negative;
		num1.negative = !((*this).negative);
		num2.negative = !(pcOther.negative);
	}
	else {
		num1.negative = (*this).negative;
		num2.negative = (pcOther).negative;
	}

	//============================================

	/* //OLD WORKING METHOD
	bool addCarry = false;
	int j = size - 1;
	int k = pcOther.size - 1;
	for (int i = result.size - 1; i >= 0; i--) {
		int nextDigit = (j >= 0 ? digits[j] : 0) + (k >= 0 ? pcOther.digits[k] : 0) + (addCarry ? 1 : 0);
		result.digits[i] = nextDigit % 10;
		nextDigit /= 10;
		if (nextDigit > 0) addCarry = true;
		else addCarry = false;

		j--; k--;
	}
	*/
	
	bool addCarry = false;
	bool remCarry = false;
	int j = num1.size - 1;
	int k = num2.size - 1;
	for (int i = result.size - 1; i >= 0; i--) { //-14???? how
		int nextDigit = (j >= 0 ? (num1.digits[j] * (num1.negative ? -1 : 1)) : 0) + (k >= 0 ? (num2.digits[k] * (num2.negative ? -1 : 1)) : 0) + (addCarry ? 1 : 0) - (remCarry ? 1 : 0);
		if (nextDigit < 0) {
			nextDigit += 10;
			remCarry = true;
		}
		else {
			remCarry = false;
		}
		result.digits[i] = nextDigit % 10;
		nextDigit /= 10;
		if (nextDigit > 0) addCarry = true;
		else addCarry = false;

		j--; k--;
	}

	myFixer(&result);

	return result;
}

CNumber CNumber::operator-(const CNumber& pcOther) {
	if ((*this).digits == nullptr || pcOther.digits == nullptr) return CNumber();
	CNumber num2;
	num2 = pcOther; num2.negative = !num2.negative;
	return (*this) + num2;
}
CNumber CNumber::operator*(const CNumber& pcOther) {

	if ((*this).digits == nullptr || pcOther.digits == nullptr) return CNumber();

	//============================================

	CNumber result(size + pcOther.size, 0);

	//============================================
	
	for (int i = (*this).size - 1; i >= 0; i--) {
		int addCarryInt = 0;
		for (int j = pcOther.size - 1; j >= 0; j--) {
			int nextDigit = (*this).digits[i] * pcOther.digits[j] + result.digits[i + j + 1] + addCarryInt;
			result.digits[i + j + 1] = nextDigit % 10;
			addCarryInt = nextDigit /= 10;
		}
		result.digits[i] += addCarryInt;
	}

	//============================================

	myFixer(&result);
	if(result.size > 0 && result.digits[0] != 0) result.negative = (*this).negative ^ pcOther.negative;

	return result;
}
CNumber CNumber::operator/(const CNumber& pcOther){

	if ((*this).digits == nullptr || pcOther.digits == nullptr) return CNumber();

	//============================================

	CNumber result(0);
	CNumber num1, num2;
	num1 = *this; num1.negative = false;
	num2 = pcOther; num2.negative = false;

	if (num1 < num2) {
		return result;
	}
	
	//============================================

	if (num2.size == 0 || num2.digits[0] == 0) {
		std::cout << "Error: Devide by zero" << std::endl;
		exit(1);
	}

	while (!(num1 < num2)) {
		CNumber temp, count;
		temp = num2;
		count = 1;

		while (!(num1 < (temp * 2))) {
			temp = temp * 2;
			count = count * 2;
		}

		num1 = num1 - temp;
		result = result + count;
	}

	//=====================================================

	myFixer(&result);
	if (result.size > 0 && result.digits[0] != 0) result.negative = num1.negative ^ num2.negative;
	
	return result;
}

CNumber CNumber::operator+(long long iNewVal){
	CNumber num1; num1 = iNewVal;
	return (*this) + num1;
}
CNumber CNumber::operator-(long long iNewVal){
	CNumber num1; num1 = iNewVal;
	return (*this) - num1;
}
CNumber CNumber::operator*(long long iNewVal){
	CNumber num1; num1 = iNewVal;
	return (*this) * num1;
}
CNumber CNumber::operator/(long long iNewVal){
	CNumber num1; num1 = iNewVal;
	return (*this) / num1;
}

bool CNumber::operator>(const CNumber& pcOther){
	if (size > pcOther.size) return true;
	else if (size < pcOther.size) return false;
	else {
		for (int i = 0; i < size; i++) {
			if (digits[i] > pcOther.digits[i]) return true;
			else if (digits[i] < pcOther.digits[i]) return false;
		}
		return false;
	}
}
/*
bool CNumber::operator>=(const CNumber& pcOther) {
	if (size > pcOther.size) return true;
	else if (size < pcOther.size) return false;
	else {
		for (int i = 0; i < size; i++) {
			if (digits[i] > pcOther.digits[i]) return true;
			else if (digits[i] < pcOther.digits[i]) return false;
		}
		return true;
	}
}
*/
bool CNumber::operator<(const CNumber& pcOther) {
	if (size < pcOther.size) return true;
	else if (size > pcOther.size) return false;
	else {
		for (int i = 0; i < size; i++) {
			if (digits[i] < pcOther.digits[i]) return true;
			else if (digits[i] > pcOther.digits[i]) return false;
		}
		return false;
	}
}
bool CNumber::operator<=(const CNumber& pcOther) {
	if (size > pcOther.size) return true;
	else if (size < pcOther.size) return false;
	else {
		for (int i = 0; i < size; i++) {
			if (digits[i] > pcOther.digits[i]) return true;
			else if (digits[i] < pcOther.digits[i]) return false;
		}
		return true;
	}
}
bool CNumber::operator==(const CNumber& pcOther) const{
	for (int i = 0; i < size; i++) {
		if (digits[i] != pcOther.digits[i]) return false;
	}
	return true;
}
bool CNumber::operator==(long long iNewVal) {
	CNumber num;
	num = iNewVal;
	return ((*this) == num);
}
bool CNumber::operator!=(const CNumber& pcOther) const {
	for (int i = 0; i < size; i++) {
		if (digits[i] != pcOther.digits[i]) return true;
	}
	return false;
}
bool CNumber::operator!=(long long iNewVal) {
	CNumber num;
	num = iNewVal;
	return ((*this) != num);
}
void CNumber::myFixer(CNumber* pcOther) {
	// 0  1  2  3  4 = index =>  0  1  2  3
	//[0][2][1][3][7] = 2137 => [2][1][3][7]
	//czyli przesuwamy wszystko o jeden w prawo
	while ((*pcOther).size > 1 && (*pcOther).digits[0] == 0) {
		for (int i = 0; i < (*pcOther).size - 1; i++) {
			(*pcOther).digits[i] = (*pcOther).digits[i + 1];
		}
		(*pcOther).size--;
	}
	if ((*pcOther) == 0) (*pcOther).negative = false;
}


CNumber& operator>=(int val, CNumber& num) {
	num = CNumber(val);
	return num;
}

CNumber& operator>=(CNumber& num, int& val) {
	//val = std::stoi(num.toString());
	val = num.toInt();
	return num;
}

CNumber& operator>=(CNumber& num1, CNumber& num2){
	num2 = num1;
	return num1;
}
