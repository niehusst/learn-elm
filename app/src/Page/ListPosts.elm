module Page.ListPosts exposing (Model, Msg, init, update, view)

import Error exposing (buildErrorMessage)
import Html exposing (..)
import Html.Attributes exposing (href, type_)
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
    , deleteError : Maybe String
    }


type Msg
    = FetchPosts
    | DeletePost PostId
    | DataReceived (WebData (List Post))
    | PostDeleted (Result Http.Error String)



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ button [ onClick FetchPosts ]
            [ text "Refresh data from server" ]
        , viewPostsOrError model
        , viewDeletionError model
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


viewDeletionError : Model -> Html Msg
viewDeletionError model =
    case model.deleteError of
        Just message ->
            viewError message

        Nothing ->
            text ""


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
    let
        postPath =
            "/posts/" ++ Post.idToString post.id
    in
    tr []
        [ td [] [ text (idToString post.id) ]
        , td [] [ text post.title ]
        , td []
            [ a [ href post.author.url ] [ text post.author.name ]
            ]
        , td [] [ a [ href postPath ] [ text "Edit" ] ]
        , td []
            [ button [ type_ "button", onClick (DeletePost post.id) ]
                [ text "DELETE" ]
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


deletePost : PostId -> Cmd Msg
deletePost postid =
    Http.request
        { method = "DELETE"
        , headers = []
        , url = "http://localhost:5019/posts/" ++ Post.idToString postid
        , body = Http.emptyBody
        , expect = Http.expectString PostDeleted
        , timeout = Nothing
        , tracker = Nothing
        }



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        FetchPosts ->
            ( { model
                | posts = RemoteData.Loading
                , deleteError = Nothing
              }
            , fetchPosts
            )

        DeletePost postid ->
            ( model, deletePost postid )

        PostDeleted (Ok _) ->
            -- re-fetch posts now that 1 is deleted
            ( model, fetchPosts )

        PostDeleted (Err httpError) ->
            ( { model | deleteError = Just (buildErrorMessage httpError) }
            , Cmd.none
            )

        DataReceived response ->
            ( { model
                | posts = response
                , deleteError = Nothing
              }
            , Cmd.none
            )



-- INIT


init : ( Model, Cmd Msg )
init =
    ( { posts = RemoteData.Loading
      , deleteError = Nothing
      }
    , fetchPosts
    )
