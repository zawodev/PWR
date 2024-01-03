#ifndef ZAD2_HPP
#define ZAD2_HPP

#include <iostream>

class CNumber {
private:
    bool negative;
    int* digits;
    int size;

    void myFixer(CNumber* pcOther); //usuwa zera z przodu oraz zamienia -0 na 0
public:
    CNumber(std::string strDigits);
    CNumber(int size, int vals);
    CNumber(long long val);
    CNumber() : size(0), digits(nullptr), negative(false) {};
    CNumber(const CNumber& pcOther);
    ~CNumber() { delete[] digits; }

    CNumber& operator=(const CNumber& pcOther);
    CNumber& operator=(const long long iValue);

    CNumber operator+(const CNumber& pcOther);
    CNumber operator+(long long iNewVal);

    CNumber operator-(const CNumber& pcOther);
    CNumber operator-(long long iNewVal);

    CNumber operator*(const CNumber& pcOther);
    CNumber operator*(long long iNewVal);

    CNumber operator/(const CNumber& pcOther);
    CNumber operator/(long long iNewVal);

    bool operator<(const CNumber& pcOther);
    bool operator<=(const CNumber& pcOther);

    bool operator>(const CNumber& c);
    //bool operator>=(const CNumber& pcOther);

    //modyfikacja

    friend CNumber& operator>=(int val, CNumber& num);
    friend CNumber& operator>=(CNumber& num, int& val);
    friend CNumber& operator>=(CNumber& num1, CNumber& num2);

    //end of modyfikacja

    bool operator==(const CNumber& pcNewVal) const;
    bool operator==(long long iNewVal);

    bool operator!=(const CNumber& pcNewVal) const;
    bool operator!=(long long iNewVal);

    std::string toString() {
        std::string out = "";
        if (digits == nullptr) {
            out += "Not Definied";
        }
        else {
            if (negative) out += "-";
            for (int i = 0; i < size; i++) {
                out += (digits[i] + '0');
            }
        }
        return out;
    }

    int toInt() {
        int out = 0;
        if (digits == nullptr) {
            return 0;
        }
        else {
            for (int i = 0; i < size; i++) {
                out += digits[i];
                out *= 10;
            }
            out /= 10;
        }
        if (negative) out *= -1;
        return out;
    }
};

#endif