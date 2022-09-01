module Playground exposing (main)

import Html


escapeEarth myVelocity mySpeed =
    if myVelocity > 11.182 then
        "Yeet bitch"

    else if mySpeed == 7.9 then
        "Orbitting i guess"

    else
        "Crash n burn"


computeSpeed distance time =
    distance / time


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
