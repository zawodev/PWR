let rec elementy_parzyste_indeksy lista =
  let rec pomocnicza tab indeks = function
    | [] -> List.rev tab
    | x :: reszta ->
      if indeks mod 2 = 0 then
        pomocnicza (x :: tab) (indeks + 1) reszta
      else
        pomocnicza tab (indeks + 1) reszta
  in pomocnicza [] 0 lista;;

let rec print_list lista =
  match lista with
  | [] -> ()
  | x :: reszta ->
    print_int x;
    print_string " ";
    print_list reszta;;

let moja_lista = [1; 2; 3; 4; 5; 6; 7; 8; 9; 10];;
let lista_elementow_parzystych = elementy_parzyste_indeksy moja_lista;;

print_list moja_lista;;
print_newline ();;
print_list lista_elementow_parzystych;;
print_newline ();;
