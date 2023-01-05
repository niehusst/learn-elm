module Route exposing (..)

{-| This module defines the path routes for each page in our app. This way,
we can use nice types for our routing instead of strings, which can be easily
messed up.
-}

import Browser.Navigation as Nav
import Model.Post exposing (PostId)
import Url exposing (Url)
import Url.Parser exposing (..)


type Route
    = NotFound
    | Posts
    | Post PostId


matchRoute : Parser (Route -> a) a
matchRoute =
    oneOf
        [ map Posts top
        , map Posts (s "posts")
        , map Post (s "posts" </> Model.Post.idParser)
        ]


parseUrl : Url -> Route
parseUrl url =
    case parse matchRoute url of
        Just route ->
            route

        Nothing ->
            NotFound


pushUrl : Route -> Nav.Key -> Cmd msg
pushUrl route navKey =
    routeToString route
        |> Nav.pushUrl navKey


routeToString : Route -> String
routeToString route =
    case route of
        NotFound ->
            "/not-found"

        -- value doesnt matter
        Posts ->
            "/posts"

        Post postId ->
            "/posts/" ++ Model.Post.idToString postId
