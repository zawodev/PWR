(define (domain package-transport)
  (:requirements :strips :typing :durative-actions :negative-preconditions :fluents)
  (:types
    location package truck
  )
  (:predicates
    (at-trk ?t - truck ?l - location)
    (at-pkg ?p - package ?l - location)
    (in-truck ?p - package ?t - truck)
    (connected ?from ?to - location)
    (isbusy ?t - truck)
  )
  (:functions
    (travel-time ?from ?to - location)
  )
  (:durative-action drive
    :parameters (?t - truck ?from - location ?to - location)
    :duration (= ?duration 2)
    :condition (and
      (at start (at-trk ?t ?from))
      (at start (connected ?from ?to))
      (at start (not (isbusy ?t)))
    )
    :effect (and
      (at start (isbusy ?t))
      (at end (not (at-trk ?t ?from)))
      (at end (at-trk ?t ?to))
      (at end (not (isbusy ?t)))
    )
  )
  (:durative-action load
    :parameters (?p - package ?t - truck ?l - location)
    :duration (= ?duration 1)
    :condition (and
      (at start (at-pkg ?p ?l))
      (at start (at-trk ?t ?l))
      (at start (not (isbusy ?t)))
    )
    :effect (and
      (at start (isbusy ?t))
      (at end (in-truck ?p ?t))
      (at end (not (at-pkg ?p ?l)))
      (at end (not (isbusy ?t)))
    )
  )
  (:durative-action unload
    :parameters (?p - package ?t - truck ?l - location)
    :duration (= ?duration 1)
    :condition (and
      (at start (in-truck ?p ?t))
      (over all (at-trk ?t ?l))
      (at start (not (isbusy ?t)))
      )
    :effect (and
      (at start (isbusy ?t))
      (at end (at-pkg ?p ?l))
      (at end (not (in-truck ?p ?t)))
      (at end (not (isbusy ?t)))
      )
  )
)