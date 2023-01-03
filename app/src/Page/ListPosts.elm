module Page.ListPosts exposing (..)

import Html exposing (..)
import Html.Attributes exposing (href)
import Html.Events exposing (onClick)
import Http
import Model.Author as Author exposing (..)
import Model.Post as Post exposing (..)
import RemoteData exposing (WebData)



-- TYPES


{-| WebData is equiv to `RemoteData Http.Error (List Post)`
-}
type alias Model =
    { posts : WebData (List Post)
    }


type Msg
    = FetchPosts
    | DataReceived (WebData (List Post))



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ button [ onClick FetchPosts ]
            [ text "Refresh data from server" ]
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
        [ td [] [ text (idToString post.id) ]
        , td [] [ text post.title ]
        , td []
            [ a [ href post.author.url ] [ text post.author.name ]
            ]
        ]



-- CMD


{-| the `>>` operator wraps the first func in the second
f1 >> f2 == \\param -> f2 (f1 param)
-}
fetchPosts : Cmd Msg
fetchPosts =
    Http.get
        { url = "http://localhost:5019/posts"
        , expect =
            postsDecoder
                |> Http.expectJson (RemoteData.fromResult >> DataReceived)
        }


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



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        FetchPosts ->
            ( { model | posts = RemoteData.Loading }
            , fetchPosts
            )

        DataReceived response ->
            ( { model | posts = response }
            , Cmd.none
            )



-- INIT


init : () -> ( Model, Cmd Msg )
init _ =
    ( { posts = RemoteData.Loading }
    , fetchPosts
    )
