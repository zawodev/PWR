#ifndef ZAD4_HPP
#define ZAD4_HPP

void exercise_4();

#endif

#include <string>
using namespace std;

class CTable {
private:
	string s_name;
	int* table;
	int i_table_len;

public:
	//normal interfaced
	CTable();
	CTable(string sName, int iTableLen);
	CTable(const CTable& pcOther);
	~CTable();
	bool bSetNewSize(int iTableLen);

	//with body
	int iGetSize() {
		return i_table_len;
	};
	void vSetName(string sName) {
		s_name = sName;
	};
	CTable* pcClone() {
		return new CTable(*this);
	};
};

const string const_text_def = "bezp: ";
const string const_text_param = "parametr: ";
const string const_text_copy = "kopiuj: ";
const string const_text_destr = "usuwam: ";
const string const_text_error_msg = "Niepoprawna dlugosc tablicy! Przypisano domyslna wartosc: ";
const string const_def_s_name = "default";
const int const_def_table_len = 5;

void v_mod_tab(CTable* pcTab, int iNewSize);
void v_mod_tab(CTable cTab, int iNewSize);

