(* ZAD 1, 2*)
(* Sygnatura modułu (interface) *)
module type Point3D = sig
  type t
  val create : float -> float -> float -> t
  val distance : t -> t -> float
end

(* Moduł implementujący sygnaturę (class implements interface) *)
module Point3DImpl : Point3D = struct
  type t = { x: float; y: float; z: float }
  let create x y z = { x; y; z }
  let distance p1 p2 =
    let dx = p1.x -. p2.x in
    let dy = p1.y -. p2.y in
    let dz = p1.z -. p2.z in
    sqrt (dx *. dx +. dy *. dy +. dz *. dz)
end


module type Line = sig
  type t
  val create : Point3DImpl.t -> Point3DImpl.t -> t
  val length : t -> float
end


module LineImpl : Line = struct
  type t = { start_point: Point3DImpl.t; end_point: Point3DImpl.t }
  let create start_point end_point = { start_point; end_point }
  let length line = Point3DImpl.distance line.start_point line.end_point
end






(* === TESTING POINT3D === *)
let point1 = Point3DImpl.create 1.0 2.0 8.0;;
let point2 = Point3DImpl.create 4.0 6.0 8.0;;

let distance_between_points = Point3DImpl.distance point1 point2 in Printf.printf "Odległość między punktami: %.2f\n" distance_between_points;;




(* === TESTING LINE === *)
let line = LineImpl.create point1 point2;;

let line_length = LineImpl.length line in Printf.printf "Długość odcinka: %.2f\n" line_length;;
