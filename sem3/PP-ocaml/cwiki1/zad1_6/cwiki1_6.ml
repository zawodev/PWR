(**ZAD 6*)
(**ocamlc -o zad6 zad1_6/cwiki1_6.ml*)
let rec listLength lst =
  match lst with
  | [] -> 0
  | _::tl -> 1 + listLength tl

let rec listL lst =
  if lst = [] then 0
  else 1 + listL (List.tl lst)


  
let length = listLength [1; 2; 3; 4; 5];;
print_int length;;
print_newline ();;