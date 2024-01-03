let is_prime n =
  let n = abs n in
  let rec is_not_divisor d =
    d * d > n || (n mod d <> 0 && is_not_divisor (d + 1)) in n <> 1 && is_not_divisor 2
;;

let test_prime n =
  if is_prime n then
    print_string (string_of_int n ^ " jest liczbą pierwszą.\n")
  else
    print_string (string_of_int n ^ " nie jest liczbą pierwszą.\n")
;;

let liczba1 = 17;;
let liczba2 = 25;;

test_prime liczba1;;
test_prime liczba2;;
