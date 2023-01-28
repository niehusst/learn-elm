module Playground exposing (main)

import Html


escapeEarth : Float -> Float -> String
escapeEarth myVelocity mySpeed =
    if myVelocity > 11.182 then
        "Yeet bitch"

    else if mySpeed == 7.9 then
        "Orbitting i guess"

    else
        "Crash n burn"


computeSpeed : Float -> Float -> Float
computeSpeed distance time =
    distance / time


computeTime : Float -> Float -> Float
computeTime tStart tEnd =
    tEnd - tStart



{- This is the more traditional way of function chaining. Simple but hard 2 read
   main =
       Html.text (escapeEarth 11 (computeSpeed 100 (computeTime 40 10)))
-}


main =
    computeTime 40 10
        |> computeSpeed 100
        |> escapeEarth 11
        |> Html.text



-- This way is kinda backwards compared to traditional way, but is more readable.
-- This way of chaining functions is call partial application of functions.
-- operator basically means, feed prev result to this fun


{-| Extensible Record
is a type that you can use to help narrow types and expose fewer fields
of large records to functions. An extensible record means a record that
just has all the specified and no less (but maybe more).
This allows you to pass in a large record to a function that takes an
extensible record type and only expose the specified fields.
-}
type alias Extensible r =
    { r
        | name : String
        , age : Int
    }


type alias Concrete =
    { name : String
    , favoriteFood : String
    , catsName : String
    , age : Int
    }


getName : Extensible r -> String
getName record =
    record.name


dontDie =
    let
        rec : Concrete
        rec =
            { name = "Tim"
            , favoriteFood = "pie"
            , catsName = "Void"
            , age = 43
            }
    in
    getName rec
