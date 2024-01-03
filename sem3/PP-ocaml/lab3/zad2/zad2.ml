let rec last_two lst =
  match lst with
  | [] | [_] -> None
  | [x; y] -> Some(x, y)
  | _ :: rest -> last_two rest;;

let result1 = last_two [1; 2; 3; 4; 5];;
let result2 = last_two [];;
let result3 = last_two [42];;
  
(* Przykłady wyników *)
print_endline (match result1 with Some (x, y) -> string_of_int x ^ " " ^ string_of_int y | None -> "None");;  (* Wypisze: "5" *)
print_endline (match result2 with Some (x, y) -> string_of_int x ^ " " ^ string_of_int y | None -> "None");;  (* Wypisze: "5" *)
print_endline (match result3 with Some (x, y) -> string_of_int x ^ " " ^ string_of_int y | None -> "None");;  (* Wypisze: "5" *)