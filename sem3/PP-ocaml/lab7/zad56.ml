module type Point3D = sig
  type t
  val create : float -> float -> float-> t
  val x : t -> float
  val y : t -> float
  val z : t -> float
  val to_string : t -> string
end
module Point3DImpl : Point3D = struct
  type t = { x : float; y : float; z : float}
  let create x y z = { x; y; z}
  let x p = p.x
  let y p = p.y
  let z p = p.z
  let to_string point = Printf.sprintf "Point(%.2f, %.2f, %.2f)" (x point) (y point) (z point)
end




module type Segment = sig
  type t
  val create : Point3DImpl.t -> Point3DImpl.t -> t
  val p1 : t -> Point3DImpl.t
  val p2 : t -> Point3DImpl.t
  val to_string : t -> string
end

module SegmentImpl : Segment = struct
  type t = {p1 : Point3DImpl.t; p2 : Point3DImpl.t}

  let create p1 p2 = {p1; p2}
  let p1 segment = segment.p1
  let p2 segment = segment.p2
  let to_string segment =
    let p1_str = Point3DImpl.to_string (p1 segment) in
    let p2_str = Point3DImpl.to_string (p2 segment) in
    Printf.sprintf "Segment: %s -> %s" p1_str p2_str
end




module type Translation = sig
  val x : float
  val y : float
  val z : float
end
module TranslationImpl : Translation = struct
  let x = 3.0
  let y = 5.0
  let z = 7.0
end




module Translate_Point (P : Point3D) (T : Translation) : Point3D = struct
  type t = P.t

  let create x y z = P.create (x +. T.x) (y +. T.y) (z +. T.z)

  let x point = P.x point
  let y point = P.y point
  let z point = P.z point
  let to_string point = Printf.sprintf "Translated Point(%.2f, %.2f, %.2f)" (x point) (y point) (z point)
end

module TranslatePointImpl = Translate_Point (Point3DImpl) (TranslationImpl)


module Translate_Segment (S : Segment) (T : Translation) : Segment = struct
  type t = S.t 
  let create p1 p2 = 
    let x1 = Point3DImpl.x p1 in
    let x2 = Point3DImpl.x p2 in
    let y1 = Point3DImpl.y p1 in
    let y2 = Point3DImpl.y p2 in
    let z1 = Point3DImpl.z p1 in
    let z2 = Point3DImpl.z p2 in
    S.create 
    (Point3DImpl.create (x1 +. T.x) (y1 +. T.y) (z1 +. T.z)) 
    (Point3DImpl.create (x2 +. T.x) (y2 +. T.y) (z2 +. T.z)) 
  let p1 segment = S.p1 segment
  let p2 segment = S.p2 segment
  let to_string segment =
    let p1_str = Point3DImpl.to_string (p1 segment) in
    let p2_str = Point3DImpl.to_string (p2 segment) in
    Printf.sprintf "Translated Segment: %s -> %s" p1_str p2_str
end

module TranslateSegmentImpl = Translate_Segment (SegmentImpl) (TranslationImpl)


(* ======================================== *)
(*      \/     TEST EXAMPLE USE     \/      *)
(* ======================================== *)
(* Translation amount is: (3, 5, 7) (set up higher) *)
let point0 = Point3DImpl.create 1.0 1.0 1.0;;
let point1 = Point3DImpl.create 1.0 2.0 6.0;;
let point2 = TranslatePointImpl.create 1.0 1.0 1.0;;
let tmp0 = Point3DImpl.to_string point0;;
Printf.printf "%s\n" tmp0
let tmp1 = Point3DImpl.to_string point1;;
Printf.printf "%s\n" tmp1
let tmp2 = TranslatePointImpl.to_string point2;;
Printf.printf "%s\n" tmp2

let segment = SegmentImpl.create point0 point1;;
let segment2 = TranslateSegmentImpl.create point0 point1;;
let tmp3 = SegmentImpl.to_string segment;;
Printf.printf "%s\n" tmp3
let tmp4 = TranslateSegmentImpl.to_string segment2;;
Printf.printf "%s\n" tmp4



