
//gcc vs klang kompilatory
/*
1.) ==============================================================

Programowanie generyczne (programowanie uogólnione)

Klasy albo funkcje generyczne - java:
-jeden wspólny kod
>technika wycierania typów (List<E> -> (wycieranie) -> List (ang raw type, typ surowy) ~ List<object>
>parametry: typy referencyjne (Integer, a nie int bo jest referencyjny)
-w czasie kompilacji generowany jest cały kod.


Szablony klas funkcji - cpp:
-dla każdego zestawu parametrów jest generowana osobna implementacja
-możliwość ręcznego wycierania typów w pewnych przypadkach np. dla T*
-parametry: typy, wartości całkowito-liczbowe(int, bool, long itd), const char*(literały łańcuchowe [stałe stringi], szablony
-kod generowany w czasie kompilacji
-skrajnie nieczytelne komunikaty o błędach :C
-jest możliwość tworzenia specjalnych lepszych implementacji dla wybranych typów.
-funkcje wirtualne nie mogą być szablonami
-generowane jedynie te części kodu, które są wykorzystywane


2.) ==============================================================
Szablony:
Specjalizacja - implementacja dedykowana dla danego wybranego typu
>specjalizacja pełna: dla konkretnego typu np. double, std::vector<Student>
>specjalizacja częściowa: dla rodziny typów np. T*, const T&, std::vector<T>

Konkretyzacja (ang instantiation) - określa moment wygenerowania kodu
> nie jawna - ustalona automatycznie (99% przypadków)
> jawna - ręczne wymuszenie wygenerowania kodu (CAŁEGO!)

Szablon klasy/funkcji -> (generuje) -> klasy/funkcje szablonowe 
(ang. class/function template -> template class/function)


3) Szablony są w całości zapisywane w plikach *.hpp!!! (nie *.h)
*/



#include <iostream>

//Cell.hpp - 1 sposób tworzenia
//template<typename/class> (template i class to to samo, tylko w jezyku c była jakas roznica albo w starym cpp nie wiem, tak czy siak to to samo, ale zawisza woli typename bo sie nie myli nazwa)
template<typename T> class Cell {
public: 
    Cell(const T& val) : val(val) {};
    const T& value() const { return val; };
private:
    T val;
};

int main() {
    Cell<int> c1(1);
    Cell<float> c2(2.0);

    std::cout << c1.value();
    std::cout << c2.value();
}

//2 sposób tworzenia
//Cell2.hpp
template<typename T> class Cell2 {
public:
    Cell2(const T& val);
    const T& value() const;
private:
    T val;
};
template<typename T> Cell2<T>::Cell2(const T& val) {
    val = val;
}
template<typename T> const T& Cell2<T>::value() const {
    return val;
}

//całość powyżej w hpp :C

//3 sposób (oryginalny zawiszy)
//Cell3.hpp
template<typename T> class Cell3 {
public:
    Cell3(const T& val);
    const T& value() const;
private:
    T val;
};
//#include "Cell.tpp"; //(w ostatniej linijce hpp zeby dolaczyc tpp)
//trzeba ustawic w ustawieniach srodowiska, tools -> options -> extensions -> wziąć ustawienia edytora ?? extensions??, file extensions, add file extension?? visual c++ .tpp


//Cell3.tpp (to też nagłówek)
template<typename T> Cell3<T>::Cell3(const T& val) {
    val = val;
}
template<typename T> const T& Cell3<T>::value() const {
    return val;
}

//wersja 2 i 3 są takie same dla kompilatora, ale mozna sobie rozdzielic na dwa pliki



//4). Specjalizacje: //Cell.hpp wciaz
//a) specjalizacja składowej:

//brak template<> (które się daje czasem na ogół gdzieś tam) bo Cell<double> jest "kompletnym, konkretnym" typem
Cell<double>::Cell(const double& val) : val(3.14) {};

//b) specjalizacja klasy (częściowa): 
template<typename T> class Cell4 /*   <T*>   */ {
public:
    Cell(T& ptr) : ptr(&ptr) {};
    T& operator* () { return *ptr; };
private:
    T* ptr;
};

//kolejność specjalizacji ma znaczenie: powinniśmy iść od ogólnego szablonu do szczegółowej specjalizacji
void main4() {
    int x = 7;
    //Cell4<int> c1(x);
    //Cell4<int*> c2(x);
    //c1.value() = 2;
    //(*c2) = 3;
    std::cout << x; //x==3??!
} //cos nie kompiluje ale chodzi o to ze wow zmieniło oryginalna zmienna
