(define (problem example_transport)
  (:domain package_system)
  (:objects
    Warszawa Vatican Berlin DC Prague - location
    truck1 truck2 - car
    boeing1 - plane
    package1 package2 package3 package4 package5 - package
  )
  (:init
    (at truck1 Warszawa)
    (at truck2 Vatican)
    (at boeing1 Berlin)
    (availible truck1)
    (availible truck2)
    (availible boeing1)

    (at package1 Warszawa)
    (at package2 Vatican)
    (at package3 Berlin)
    (at package4 DC)
    (at package5 Prague)

    (connection Warszawa Vatican road) 
    (connection Vatican Berlin road)
    (connection Berlin DC road)
    (connection DC Prague road)
    (connection Prague Warszawa road)
    (connection Berlin Vatican road)

    (connection Berlin Warszawa air)

    (= (time-road Warszawa Vatican )  10)
    (= (time-road Vatican Berlin ) 4)
    (= (time-road Berlin DC ) 5)
    (= (time-road DC Prague ) 2)
    (= (time-road Prague Warszawa ) 7)
    (= (time-road Berlin Vatican ) 8)

    (= (time-air Berlin Warszawa) 1) ;;żeby zobaczyć czy paczka pojedzie samolotem
  )
  (:goal
    (and
      (at package1 DC)
      (at package2 Vatican)
      (at package3 Warszawa)
      (at package4 Prague)
      (at package5 Berlin)

      (availible truck1)
      (availible truck2)
      (availible boeing1)

      (delivered package1)
      (delivered package2)
      (delivered package3)
      (delivered package4)
      (delivered package5)
    )
  )
)