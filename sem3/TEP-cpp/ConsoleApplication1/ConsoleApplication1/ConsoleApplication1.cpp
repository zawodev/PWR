#include <iostream>
using namespace std;

int a = 6;
int* ptr = nullptr;
int** ptrptr = nullptr;

int* nptr = new int; //smieciowa wartosc
int* nptr = new int(); //0
int* nptr = new int(7); //7

/*
*nptr += 3;
delete nptr //bez delete wyciek pamieci ram, dwa razy delete tez zle bo zniszczy pamiec wiec poczytac

//gdzies w mainie pozniej
*/

int* tab = new int[10];
/*
tab[3] = 8;
delete tab;
//or
delete[] tab;
*/

class A {
public:
    int x;
    //konstruktor
    A(int x) : x(x) { //lista inicjalizacyjna konstruktora
        //ciało konstruktora
    }
} b;//obiekt b klasy A

int main(){
    A c(10);
    A* cptr = &c;

    (*cptr).x = 3;
    cptr->x = 5;

    //==========================

    int& ref = a; //kopia a pod inna nazwa
    ref = 3;//wiec a == 3 nagle

    //==========================

    ptr = &a;
    *ptr = 5;

    ptrptr = &ptr;
    cout << a;

    //==========================

    //static-cast<T>(expression) //type 1 long -> int, int -> long etc. | podczas kompilacji
    //dynamic-cast<T&/T*>(adres/obiekt klasy) //podczas wykonywania 
    //const-cast<T>(wyrażenie) - dodac/ususnac modyfikator const i lub volative
    //reinterpret-cast<T>(wyrażenie) -> 0101010010 (int) -> 0101010010 (float)
    //(T)wyrażenie // 1->2->3->4
}