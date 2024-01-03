module type Coord = sig
  type t
  val subtract : t -> t -> float
end

(* INT CLASS *)
module IntCoord : Coord with type t = int = struct
  type t = int
  let subtract c1 c2 = float_of_int (abs (c1 - c2))
end

(* FLOAT CLASS *)
module FloatCoord : Coord with type t = float = struct
  type t = float
  let subtract c1 c2 = abs_float (c1 -. c2)
end


module MakePoint (C : Coord) = struct
  type t = { x: C.t; y: C.t; z: C.t }
  let create x y z = { x: C.t; y: C.t; z: C.t }
  let distance p1 p2 =
    let dx = C.subtract p1.x p2.x in
    let dy = C.subtract p1.y p2.y in
    let dz = C.subtract p1.z p2.z in
    sqrt (dx *. dx +. dy *. dy +. dz *. dz)
end


(* Objects of classes int and float *)
module IntPoint = MakePoint(IntCoord)
module FloatPoint = MakePoint(FloatCoord)



(* ======================================== *)
(*      \/     TEST EXAMPLE USE     \/      *)
(* ======================================== *)

let int_point1 = IntPoint.create 1 2 1;;
let int_point2 = IntPoint.create 4 6 1;;

let int_distance = IntPoint.distance int_point1 int_point2 in
Printf.printf "Int points distance: %.2f\n" int_distance;;

let float_point1 = FloatPoint.create 1.0 2.0 1.0;;
let float_point2 = FloatPoint.create 4.0 6.0 1.0;;

let float_distance = FloatPoint.distance float_point1 float_point2 in
Printf.printf "Float points distance: %.2f\n" float_distance;;




