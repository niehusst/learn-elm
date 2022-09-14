-- this is the specified exports for this module (.. meaning all).
-- by exporting the type MyList under the module name MyList, it kind of mirrors method names on a class almost


module MyList exposing (MyList(..), isEmpty, sum)


type MyList a
    = Empty
    | Node a (MyList a)


sum : MyList Int -> Int
sum myList =
    case myList of
        Empty ->
            0

        Node val tail ->
            (+) val (sum tail)


isEmpty : MyList t -> Bool
isEmpty myList =
    case myList of
        Empty ->
            True

        _ ->
            False
