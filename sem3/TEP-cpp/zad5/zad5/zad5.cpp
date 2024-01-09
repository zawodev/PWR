#include <iostream>

//Wartości ==========================================
//operator "="

//PO LEWEJ (L values)
//x || int y || const int z ... itd.

//PO PRAWEJ (R values)
//"7" || 7 || f() ... itd.

//przykładowo x moze po lewej i po prawej wiec jest L wartoscia (bo wyzej w hierarchi)

//REFERENCJE ==========================================
// 
//----CPP 98----
//int&			|	l wartosci *(z wyjatkiem stałych)
//const int&	|	l, r wartosci
// 
//----CPP 11----
//int&			|	l wartości (z wyjatkiem stałych)
//const int&	|	l, r wartosci
//int&&			|	r wartosci
// 
// & - referencja lewostronna
// && - referencja prawostronna
// 
// możemy rozpoznać zmienne tymczasowe (przykładowo f() zwraca zmienna tymczasową)
// 
// MOVE SEMANTICS (SEMANTYKA PRZENOSZENIA) ==============================================
// (a+b-c)*d/3
// 4 zmienne tymczasowe -> a+b -> z1-c -> z2*d -> z3/3 -> z4
// 
// zmienne tymczasowe (z1, z2, z3, z4) powstają w kolejności, a przy zakonczeniu wyrazenia sa usuwane
// jako że są usuwane to:
// jeżeli takiej zmiennej zabierzemy zasoby w sposób który pozwala jej się zwolnić to nie ma problemu wsm
// zabierzemy zasoby znaczy że:
// przeniesiemy je do innej zmiennej
// 
// A::A(A&&) - konstruktor przenoszący
// A& A::operator= (A&&) - przypisanie przenoszące
// 
// reguła trzech (konstrukror, konstr. kopiujący, desturktor) => reguła pięciu (te 3 + 2 wyżej)
// 
// PRZYKŁAD : =======================================
// 
//

class Int {
public:
	Int(int x);//reguła trzech
	Int(const Int& other); //reguła trzech
	Int(Int&& other); //reguła pieciu
	~Int();//reguła trzech

	Int& operator=(const Int& other);
	Int& operator=(Int&& other);//reguła pieciu

	Int operator+(const Int& rhs) const; //right hand side
	Int operator+(const Int& rhs) &&;
private:
	int* xPtr;
};
Int::Int(int x) : xPtr(new int(x)){//lepiej tu bo nie ma tymczasowych zmiennych niz 
	//xPtr = new int(x); //niz to
}
Int::Int(const Int& other) : Int(*other.xPtr){ //sztuczka zawiszy z cpp11

}
Int::Int(Int&& other) : xPtr(other.xPtr){
	other.xPtr = nullptr; //nwm czemu nie działa
}
Int::~Int() {
	delete xPtr;
}

Int&Int::operator=(const Int& other) {
	if (this == &other) return *this;
	delete xPtr;
	xPtr = new int(*other.xPtr);
	return *this;
}
Int& Int::operator=(Int&& other){
	if (this == &other) return *this;
	delete xPtr;
	xPtr = other.xPtr;
	other.xPtr = nullptr;
	return *this;
}
//powyzej celowo nieoptymalnie bo ma nam cos obrazowac idk
Int Int::operator+(const Int& rhs) const {
	return *xPtr + *rhs.xPtr;
}
Int Int::operator+(const Int& rhs)&& {
	Int result(*this); //zamiast *this => std::move(*this) LUB staticcast<sth> //move zmienia typ lewo stronny na prawostronny
	//*this jest lwartoscia bo ma nazwe
	*result.xPtr += *rhs.xPtr;
	return result;
}
//result i ten "Int" pierwszy -> bedzie kopia wiec: 
/*
"Int" Int::operator+(const Int& rhs)&& {
	Int result(*this);
	*result.xPtr += *rhs.xPtr;
	return (std::move(result)); //propozycja michała P
	//zdaniem zawiszy rzecz jasna herezja
	//return result jest lepsze, bo kompilator sam wychwyca i jest lepsze, i sa niby rzadkie przypadki gdzie move bedzie lepszy ale na ogol nie jest
	//
	//Jeżeli zwracamy ZMIENNĄ LOKALNĄ FUNKCJI to kompilator rezerwuje na nią pamięć w miejscu wywołania (unikając kopii przeniesienia) (ang. copy ellision)
}
*/
int main() {
	Int x(7);
	Int y(8);
	Int z(5);
	Int w = x + y + z;
	//x+y => z1
	//z1 + z => z1
}

