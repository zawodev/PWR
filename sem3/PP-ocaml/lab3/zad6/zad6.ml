(*
let rec remove_copies_old list =
  let rec pomocnicza acc = function
    | [] -> List.rev acc
    | x :: reszta ->
      if List.mem x acc then
        pomocnicza acc reszta
      else
        pomocnicza (x :: acc) reszta
    in pomocnicza [] list;;
*)
let rec remove_copies = function
  | a :: (b :: _ as t) -> if a = b then remove_copies t else a :: remove_copies t
  | smaller -> smaller;;

let rec print_list lista =
  match lista with
  | [] -> ()
  | x :: reszta ->
    print_int x;
    print_string " ";
    print_list reszta;;

let moja_lista = [1; 2; 2; 3; 3; 3; 4; 5; 5];;
let lista_bez_powtorzen = remove_copies moja_lista;;

print_list moja_lista;;
print_newline ();;
print_list lista_bez_powtorzen;;
print_newline ();;