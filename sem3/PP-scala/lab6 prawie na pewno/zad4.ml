let log prefix datetime text =
  Printf.printf "[%s] %s\t%s\n" prefix datetime text

let make_log prefix datetime =
  log prefix datetime

let () =
  let warn_log = make_log "WARN" "2022-10-26 01:45" in
  warn_log "Hello"

    
let rec quicksort = function
  | [] -> []
  | [x] -> [x]
  | xs ->
      let small = List.filter (fun y -> y < List.hd xs) (List.tl xs) in
      let large = List.filter (fun y -> y >= List.hd xs) (List.tl xs) in
      quicksort small @ (List.hd xs :: quicksort large);;


let rec quicksort' = function
  | [] -> []
  | x :: xs ->
      let small = List.filter (fun y -> y < x) xs in
      let large = List.filter (fun y -> y >= x) xs in
      quicksort' small @ (x :: quicksort' large);;

let f1 x = x 2 2;; 
let f2 x y z = x ( y ^ z );;