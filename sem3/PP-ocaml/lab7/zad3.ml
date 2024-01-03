module type BinaryTree = sig
  type 'a tree
  val empty : 'a tree
  val add : 'a -> 'a tree -> 'a tree
  val remove : 'a -> 'a tree -> 'a tree
  val preorder : 'a tree -> 'a list
  val inorder : 'a tree -> 'a list
  val postorder : 'a tree -> 'a list
  val leaves : 'a tree -> 'a list
end

module BinaryTreeImpl : BinaryTree = struct
  type 'a tree = Leaf | Node of 'a * 'a tree * 'a tree

  let empty = Leaf

  let rec add value tree =
    match tree with
    | Leaf -> Node (value, Leaf, Leaf)
    | Node (v, left, right) ->
      if value < v then Node (v, add value left, right)
      else if value > v then Node (v, left, add value right)
      else tree  (* VALUE IN TREE EXIST ALREADY, DO NOTHING *)

  let rec remove value tree =
    match tree with
    | Leaf -> Leaf
    | Node (v, left, right) ->
      if value < v then Node (v, remove value left, right)
      else if value > v then Node (v, left, remove value right)
      else
        match left, right with
        | Leaf, _ -> right
        | _, Leaf -> left
        | _, _ ->
          let min_right = find_min right in
          Node (min_right, left, remove min_right right)

  and find_min = function
    | Leaf -> failwith "Empty tree"
    | Node (value, Leaf, _) -> value
    | Node (_, left, _) -> find_min left

  let rec preorder tree =
    match tree with
    | Leaf -> []
    | Node (value, left, right) -> value :: (preorder left) @ (preorder right)

  let rec inorder tree =
    match tree with
    | Leaf -> []
    | Node (value, left, right) -> (inorder left) @ [value] @ (inorder right)

  let rec postorder tree =
    match tree with
    | Leaf -> []
    | Node (value, left, right) -> (postorder left) @ (postorder right) @ [value]

  let rec leaves tree =
    match tree with
    | Leaf -> []
    | Node (value, Leaf, Leaf) -> [value]
    | Node (_, left, right) -> (leaves left) @ (leaves right)
end


(* IMPLEMENTATION ABOVE ... /\  *)
(*                          ||  *)
(* TESTING BELOW ...        \/  *) 
(*                              *)
(*              5               *)
(*       3             7        *)
(*    2     4       6     8     *)
(*                              *)

(* CREATE TREE *)
let tree =
  BinaryTreeImpl.empty
  |> BinaryTreeImpl.add 5
  |> BinaryTreeImpl.add 7
  |> BinaryTreeImpl.add 3
  |> BinaryTreeImpl.add 8
  |> BinaryTreeImpl.add 6
  |> BinaryTreeImpl.add 4
  |> BinaryTreeImpl.add 2
;;

(* PRINTING ELEMENTS OF THE TREE *)
let preorder_result = BinaryTreeImpl.preorder tree in
Printf.printf "Preorder: %s\n" (String.concat " " (List.map string_of_int preorder_result));;

let inorder_result = BinaryTreeImpl.inorder tree in
Printf.printf "Inorder: %s\n" (String.concat " " (List.map string_of_int inorder_result));;

let postorder_result = BinaryTreeImpl.postorder tree in
Printf.printf "Postorder: %s\n" (String.concat " " (List.map string_of_int postorder_result));;

let leaves_result = BinaryTreeImpl.leaves tree in
Printf.printf "Leaves: %s\n" (String.concat " " (List.map string_of_int leaves_result));;


(* ADDING AND REMOVING ELEMENTS TO AND FROM TREE *)
let tree_mod = tree;;
let tree_mod = BinaryTreeImpl.add 9 tree_mod;;
let tree_mod = BinaryTreeImpl.remove 7 tree_mod;;

let mod_result = BinaryTreeImpl.inorder tree_mod in
Printf.printf "After Change: %s\n" (String.concat " " (List.map string_of_int mod_result));;