(**ZAD 5*)
(**ocamlc -o zad5 zad1_5/cwiki1_5.ml*)
let print_bool b =
  match b with
  | true -> print_string "true"
  | false -> print_string "false"

let rec palindrome lst =
  let rec reverse_list lst =
    match lst with
    | [] -> []
    | hd::tl -> (reverse_list tl) @ [hd]
  in lst = reverse_list lst

let rec palindrome2 lst = 
  let rec reverse_list2 lst = 
    if lst = [] then []
    else (reverse_list2 (List.tl lst)) @ [(List.hd) lst]
  in lst = reverse_list2 lst

let is_palindrome1 = palindrome ['a'; 'l'; 'a'];;
let is_palindrome2 = palindrome ['a'; 'b'; 'c'];;
let is_palindrome3 = palindrome ['a'; 'l'; 'l'; 'a'];;

print_bool is_palindrome1;;
print_newline ();;
print_bool is_palindrome2;;
print_newline ();;
print_bool is_palindrome3;;
print_newline ();;
