module FuzzTests exposing (addOneTests, addTests)

{-
   the actual fuzz testing function, `fuzz` is defined in the Test module. But
   the built in fuzzers that provice the values are defined in the Fuzz module.
-}

import Expect exposing (Expectation)
import Fuzz exposing (..)
import Test exposing (..)


addOne : Int -> Int
addOne n =
    n + 1


add : Int -> Int -> Int
add n m =
    n + m



{-
   Instead of using `test` to define our unit test, we use `fuzz` and pass it
   a fuzzer (can be from Fuzz module or custom defined). `fuzz` runs
   100 rounds by default (this can be changed from CLI) with random
   values of the indicated type.

   If you want to repro the results of a fuzz test, `elm-test` will tell you the seed that was used and how many fuzz rounds
-}


addOneTests : Test
addOneTests =
    describe "addOne"
        [ fuzz int "adds 1 to any int" <|
            \num ->
                addOne num |> Expect.equal (num + 1)
        , fuzzWith { runs = 200 } int "adds 1 to int fuzz w/ options" <|
            \num ->
                addOne num |> Expect.equal (num + 1)
        , fuzz (intRange -30 30) "adds 1 to any int w/ range" <|
            \num ->
                addOne num |> Expect.equal (num + 1)
        , fuzz frequencyFuzzer "adds 1 custom freq" <|
            \num ->
                addOne num |> Expect.equal (num + 1)
        ]



{- multiple value fuzzers
   Test provides fuzzers for 1,2 and 3 parameter inputs (maybe more?).
   If you need to define your own custom fuzzer, fuzz2 looks like this:
   fuzz2
     : Fuzzer a
     -> Fuzzer b
     -> String
     -> (a -> b -> Expectation)
     -> Test
-}


addTests : Test
addTests =
    describe "add"
        [ fuzz2 int int "adds 2 ints" <|
            \n m ->
                add n m |> Expect.equal (n + m)
        ]



{- custom fuzzer where we provide the frequency of the returned values.
   70% chance 7
   20% chance 8-9
   5% chance 3
   5% chance 10-30
-}


frequencyFuzzer : Fuzzer Int
frequencyFuzzer =
    frequency
        [ ( 70, constant 7 )
        , ( 20, intRange 8 9 )
        , ( 5, constant 3 )
        , ( 5, intRange 10 40 )
        ]
