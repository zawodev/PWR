(define (domain package_system)
  (:requirements 
    :strips
    :typing
    :negative-preconditions
    :durative-actions
    :fluents
    )
  
  (:types
    package location vehicle 
    car plane boat - vehicle
    transport_type
  )
  
  (:constants
    road air water - transport_type
  )
  
  (:predicates
    (at ?x - (either package vehicle) ?l - location)
    (contains ?p - package ?v - vehicle)
    (availible ?v - vehicle)
    (delivered ?p - package)
    (connection ?l1 ?l2 - location ?typ - transport_type)
  )
  
  (:functions
    (time-road ?l1 ?l2 - location)
    (time-air ?l1 ?l2 - location)
    (time-water ?l1 ?l2 - location)
  )
  
  ;; Loading action
  (:durative-action load
    :parameters (?p - package ?v - vehicle ?l - location)
    :duration (= ?duration 1)
    :condition (and
      (at start (at ?p ?l))
      (at start (at ?v ?l))
      (at start (availible ?v)))
    :effect (and
      (at start (not (at ?p ?l)))
      (at start (not (availible ?v)))
      (at end (contains ?p ?v))
)
  )

  ;; Unloading action
  (:durative-action unload
    :parameters (?p - package ?v - vehicle ?l - location)
    :duration (= ?duration 1)
    :condition (and
      (at start (contains ?p ?v))
      (at start (at ?v ?l)))
    :effect (and
      (at start (not (contains ?p ?v)))
      (at end (at ?p ?l))
      (at end (availible ?v))
      (at end (delivered ?p))
)
  )

  ;; Road transport
  (:durative-action drive
    :parameters (?v - car ?from ?to - location)
    :duration (= ?duration (time-road ?from ?to))
    :condition (and
      (at start (at ?v ?from))
      (over all (connection ?from ?to road)))
    :effect (and
      (at start (not (at ?v ?from)))
      (at end (at ?v ?to))
      )
  )

  ;; Air transport
  (:durative-action fly
    :parameters (?v - plane ?from ?to - location)
    :duration (= ?duration (time-air ?from ?to))
    :condition (and
      (at start (at ?v ?from))
      (over all (connection ?from ?to air)))
    :effect (and
      (at start (not (at ?v ?from)))
      (at end (at ?v ?to))
      )
  )

  ;; Water transport
  (:durative-action sail
    :parameters (?v - boat ?from ?to - location)
    :duration (= ?duration (time-water ?from ?to))
    :condition (and
      (at start (at ?v ?from))
      (over all (connection ?from ?to water)))
    :effect (and
      (at start (not (at ?v ?from)))
      (at end (at ?v ?to))
      )
  )
)