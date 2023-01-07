module Page.NewPost exposing (Model, Msg, init, update, view)

import Browser.Navigation as Nav
import Error exposing (buildErrorMessage)
import Html exposing (..)
import Html.Attributes exposing (type_)
import Html.Events exposing (onClick, onInput)
import Http
import Model.Author exposing (Author, setName, setUrl)
import Model.Post exposing (Post, emptyPost, newPostEncoder, postDecoder, setAuthor, setTitle)
import Route exposing (Route)


type alias Model =
    { navKey : Nav.Key
    , post : Post
    , createError : Maybe String
    }


type Msg
    = CreatePost
    | PostCreated (Result Http.Error Post)
    | StoreTitle String
    | StoreAuthorName String
    | StoreAuthorUrl String


init : Nav.Key -> ( Model, Cmd Msg )
init navKey =
    ( { navKey = navKey
      , post = emptyPost
      , createError = Nothing
      }
    , Cmd.none
    )



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ h3 [] [ text "Create New Post" ]
        , viewNewPostForm
        , viewCreateError model.createError
        ]


viewCreateError : Maybe String -> Html Msg
viewCreateError error =
    case error of
        Just message ->
            div []
                [ h3 [] [ text "Error occured while creating post:" ]
                , text message
                ]

        Nothing ->
            text ""


viewNewPostForm : Html Msg
viewNewPostForm =
    Html.form []
        [ div []
            [ text "Title"
            , br [] []
            , input [ type_ "text", onInput StoreTitle ] []
            ]
        , br [] []
        , div []
            [ text "Author Name"
            , br [] []
            , input [ type_ "text", onInput StoreAuthorName ] []
            ]
        , br [] []
        , div []
            [ text "Author URL"
            , br [] []
            , input [ type_ "text", onInput StoreAuthorUrl ] []
            ]
        , br [] []
        , div []
            [ button [ type_ "button", onClick CreatePost ]
                [ text "Submit" ]
            ]
        ]



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        StoreTitle title ->
            ( { model | post = model.post |> setTitle title }
            , Cmd.none
            )

        StoreAuthorName name ->
            ( { model | post = model.post |> (setAuthor <| setName name) }
            , Cmd.none
            )

        StoreAuthorUrl url ->
            ( { model | post = model.post |> (setAuthor <| setUrl url) }
            , Cmd.none
            )

        CreatePost ->
            ( model
            , createPost model.post
            )

        PostCreated (Ok post) ->
            ( { model | post = post, createError = Nothing }
            , Route.pushUrl Route.Posts model.navKey
            )

        PostCreated (Err httpError) ->
            ( { model | createError = Just (buildErrorMessage httpError) }
            , Cmd.none
            )


createPost : Post -> Cmd Msg
createPost post =
    Http.post
        { url = "http://localhost:5019/posts"
        , body = Http.jsonBody (newPostEncoder post)
        , expect = Http.expectJson PostCreated postDecoder
        }
