(**ZAD 1*)
let rec print_int_list lst =
  match lst with
  | [] -> ()
  | hd::tl -> 
    print_int hd;
    print_string " ";
    print_int_list tl

let rec flatten1 lst =
  match lst with
  | [] -> []
  | hd::tl -> hd @ flatten1 tl

let result = flatten1 [[5;6];[1;2;3];[5;2]];;
print_int_list result;;
print_newline ();;