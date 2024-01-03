let rec length list =
  match list with
  | [] -> 0
  | _ :: rest -> 1 + length rest;;

let moja_lista = [1; 2; 3; 4; 5];;
let dlugosc = length moja_lista;;

print_int dlugosc;;
print_newline ();;