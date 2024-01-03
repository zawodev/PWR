let rec reverse_list xs =
  let rec reverse_pom ys output =
    match ys with
    | [] -> output
    | x :: rest -> reverse_pom rest (x :: output)
  in reverse_pom xs [];;

let rec print_list lista =
  match lista with
  | [] -> ()
  | x :: reszta ->
    print_int x;
    print_string " ";
    print_list reszta;;

let moja_lista = [1; 2; 3; 4; 5];;
let lista_odwrotna = reverse_list moja_lista;;

print_list moja_lista;;
print_newline ();;
print_list lista_odwrotna;;
print_newline ();;