module DecodingJson exposing (main)

import Browser
import Html exposing (..)
import Html.Attributes exposing (href)
import Html.Events exposing (onClick)
import Http
import Json.Decode as Decode
    exposing
        ( Decoder
        , decodeString
        , field
        , int
        , list
        , map3
        , string
        )
import Json.Decode.Pipeline exposing (optional, optionalAt, required, requiredAt)
import RemoteData exposing (RemoteData, WebData)


type alias Author =
    { name : String
    , url : String
    }


type alias Post =
    { id : Int
    , title : String
    , author : Author
    }


{-| WebData is equiv to `RemoteData Http.Error (List Post)`
-}
type alias Model =
    { posts : WebData (List Post)
    }


type Msg
    = SendHttpRequest
    | DataReceived (WebData (List Post))


view : Model -> Html Msg
view model =
    div []
        [ button [ onClick SendHttpRequest ]
            [ text "Get data from server" ]
        , viewPostsOrError model
        ]


viewPostsOrError : Model -> Html Msg
viewPostsOrError model =
    case model.posts of
        RemoteData.NotAsked ->
            text ""

        RemoteData.Loading ->
            h3 [] [ text "Loading..." ]

        RemoteData.Success posts ->
            viewPosts posts

        RemoteData.Failure error ->
            viewError (buildErrorMessage error)


viewError : String -> Html Msg
viewError error =
    div []
        [ h3 []
            [ text ("An error occured: " ++ error) ]
        ]


viewPosts : List Post -> Html Msg
viewPosts posts =
    div []
        [ h3 []
            [ text "Posts are:"
            , table []
                ([ viewTableHeader ] ++ List.map viewPost posts)
            ]
        ]


viewTableHeader : Html Msg
viewTableHeader =
    tr []
        [ th [] [ text "ID" ]
        , th [] [ text "Title" ]
        , th [] [ text "Author" ]
        ]


viewPost : Post -> Html Msg
viewPost post =
    tr []
        [ td [] [ text (String.fromInt post.id) ]
        , td [] [ text post.title ]
        , td []
            [ a [ href post.author.url ] [ text post.author.name ]
            ]
        ]


{-| there are a few ways we can define postDecoder

    postDecoder : Decoder Post
    postDecoder =
        map3 Post
            (field "id" int)
            (field "title" string)
            (field "author" string)

map3 is defined as

    map3 :
        (a -> b -> c -> value)
        -> Decoder a
        -> Decoder b
        -> Decoder c
        -> Decoder value

the stdlib implementation goes up to map8. if you need more fields than that, you can use the elm package NoRedInk/elm-json-decode-pipeline, which also has support for required/optional fields in the decoded json.

    import Json.Decode.Pipeline exposing (optional, optionalAt, required, requiredAt)

    postDecoder : Decoder Post
    postDecoder =
        Decode.succeed Post
            |> required "id" int
            |> required "title" string
            |> required "author" string

-}
postDecoder : Decoder Post
postDecoder =
    Decode.succeed Post
        |> required "id" int
        |> required "title" string
        |> optional "author"
            authorDecoder
            { name = "anon"
            , url = ""
            }


authorDecoder : Decoder Author
authorDecoder =
    Decode.succeed Author
        |> required "name" string
        |> required "url" string


{-| the `>>` operator wraps the first func in the second
f1 >> f2 == \\param -> f2 (f1 param)
-}
httpCommand : Cmd Msg
httpCommand =
    Http.get
        { url = "http://localhost:5019/posts"
        , expect =
            list postDecoder
                |> Http.expectJson (RemoteData.fromResult >> DataReceived)
        }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SendHttpRequest ->
            ( { model | posts = RemoteData.Loading }
            , httpCommand
            )

        DataReceived response ->
            ( { model | posts = response }
            , Cmd.none
            )


buildErrorMessage : Http.Error -> String
buildErrorMessage error =
    case error of
        Http.BadUrl msg ->
            msg

        Http.Timeout ->
            "Server took too long to respond. timeout"

        Http.NetworkError ->
            "Unable to reach the server"

        Http.BadStatus code ->
            "Request failed w/ code: " ++ String.fromInt code

        Http.BadBody msg ->
            msg


init : () -> ( Model, Cmd Msg )
init _ =
    ( { posts = RemoteData.Loading }
    , SendHttpRequest
    )


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }
