(**ZAD 3*)
(**ocamlc -o zad3 zad1_3/cwiki1_3.ml*)
let rec print_string_list lst =
  match lst with
  | [] -> ()
  | hd::tl -> 
    print_string hd;
    print_string " ";
    print_string_list tl

let rec replicate (element, n) =
  if n <= 0 then []
  else element :: replicate (element, n - 1)

let result = replicate ("la", 3);;
print_string_list result;;
print_newline ();;