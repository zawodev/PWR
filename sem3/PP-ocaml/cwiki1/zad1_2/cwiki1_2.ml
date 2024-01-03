(**ZAD 2*)
(**ocamlc -o zad2 zad1_2/cwiki1_2.ml*)
let rec count (element, lst) =
  match lst with
  | [] -> 0
  | hd::tl -> (if hd = element then 1 else 0) + count (element, tl)

let result1 = count ('a', ['a'; 'l'; 'a'; 'a'; 'l']);;
print_int result1;;
print_newline ();;