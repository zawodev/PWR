let rec last_element lst =
  match lst with
  | [] -> None
  | [x] -> Some x
  | _ :: rest -> last_element rest

let result1 = last_element [1; 2; 3; 4; 5];;
let result2 = last_element [];;
let result3 = last_element [42];;

(* Przykłady wyników *)
print_endline (match result1 with Some x -> string_of_int x | None -> "None");;  (* Wypisze: "5" *)
print_endline (match result2 with Some x -> string_of_int x | None -> "None");;  (* Wypisze: "None" *)
print_endline (match result3 with Some x -> string_of_int x | None -> "None");;  (* Wypisze: "42" *)
