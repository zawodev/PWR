(**ZAD 4*)
(**ocamlc -o zad4 zad1_4/cwiki1_4.ml*)
let rec print_int_list lst =
  match lst with
  | [] -> ()
  | hd::tl -> 
    print_int hd;
    print_string " ";
    print_int_list tl

let rec sqrList lst =
  match lst with
  | [] -> []
  | hd::tl -> (hd * hd) :: sqrList tl

let rec sqrList2 lst = 
  if lst = [] then []
  else ((List.hd lst * List.hd lst) :: sqrList2 (List.tl lst))

let result = sqrList [1; 2; 3; -4];;
print_int_list result;;
print_newline ();;
