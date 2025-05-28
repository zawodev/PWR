(define (problem transport-packages)
  (:domain package-transport)
  (:objects
    warszawa bialystok wroclaw poznan tychy - location
    truck1 truck2 - truck
    package1 package2 package3 package4 package5 - package
  )
  (:init
    (at-trk truck1 warszawa)
    (at-trk truck2 wroclaw)
    (not (isbusy truck1))
    (not (isbusy truck2))

    (at-pkg package1 warszawa)
    (at-pkg package2 bialystok)
    (at-pkg package3 wroclaw)
    (at-pkg package4 poznan)
    (at-pkg package5 tychy)

    (connected warszawa bialystok)
    (connected warszawa wroclaw)
    (connected bialystok wroclaw)
    (connected bialystok poznan)
    (connected wroclaw poznan)
    (connected wroclaw tychy)
    (connected poznan tychy)
    (connected tychy warszawa)

    (= (travel-time warszawa bialystok) 2)
    (= (travel-time warszawa wroclaw) 3)
    (= (travel-time wroclaw tychy) 4)
    (= (travel-time poznan tychy) 1)
    (= (travel-time tychy warszawa) 5)
    (= (travel-time bialystok wroclaw) 1)
    (= (travel-time bialystok poznan) 3)
    (= (travel-time wroclaw poznan) 2)
  )
  (:goal
    (and
      (at-pkg package1 wroclaw)
      (at-pkg package2 tychy)
      (at-pkg package3 tychy)
      (at-pkg package4 wroclaw)
      (at-pkg package5 warszawa)
      (not (isbusy truck1))
      (not (isbusy truck2))
    )
  )
)