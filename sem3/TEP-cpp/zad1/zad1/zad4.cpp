#include <iostream>
#include <string>
#include "zad4.hpp"
using namespace std;

void exercise_4() {
	cout << "\nZAD 4\n";

	CTable c_tab;
	CTable c_tab_named("my_tab", 7);
	CTable* c_tab_dynamic_copy = new CTable(c_tab);
	CTable* c_tab_method_copy = c_tab_named.pcClone();

	cout << c_tab.iGetSize() << endl;
	v_mod_tab(&c_tab, 10); //c_tab kopiuje lub &c_tab
	cout << c_tab.iGetSize() << endl;

	cout << (*c_tab_dynamic_copy).iGetSize() << endl;
	v_mod_tab(c_tab_dynamic_copy, 10);
	cout << (*c_tab_dynamic_copy).iGetSize() << endl;
}

CTable::CTable() { //konstruktor bezparametrowy
	s_name = const_def_s_name;
	i_table_len = const_def_table_len;
	table = new int[const_def_table_len];
	cout << const_text_def << "'" << s_name << "'" << endl;
}

CTable::CTable(string sName, int iTableLen) { //konstruktor z parametrem
	if (iTableLen < 0) {
		iTableLen = const_def_table_len;
		cout << const_text_error_msg << const_def_table_len << endl;
	}

	s_name = sName;
	i_table_len = iTableLen;
	table = new int[iTableLen];
	cout << const_text_param << "'" << s_name << "'" << endl;
}

CTable::CTable(const CTable& pcOther) { //konstruktor kopiuj¹cy
	s_name = pcOther.s_name + "_copy";
	i_table_len = pcOther.i_table_len;
	table = new int[pcOther.i_table_len];

	for (int i = 0; i < pcOther.i_table_len; i++) {
		table[i] = pcOther.table[i];
	}
	cout << const_text_copy << "'" << s_name << "'" << endl;
}

CTable::~CTable() { //destruktor
	cout << const_text_destr << "'" << s_name << "'" << endl;
	delete[] table;
}

//vSetName w hpp

bool CTable::bSetNewSize(int iTableLen) {//zmien dlugosc tablicy
	if (iTableLen < 0) return false;

	i_table_len = iTableLen;
	int* temp_table = table;
	table = new int[iTableLen];

	for (int i = 0; i < iTableLen; i++) {
		table[i] = temp_table[i];
	}
	delete[] temp_table;
	return true;
}
void v_mod_tab(CTable* pcTab, int iNewSize) {
	pcTab->bSetNewSize(iNewSize);
}
void v_mod_tab(CTable cTab, int iNewSize) {
	cTab.bSetNewSize(iNewSize);
}