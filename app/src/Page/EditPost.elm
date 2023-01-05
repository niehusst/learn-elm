module Page.EditPost exposing (Model, Msg, init, update, view)

import Browser.Navigation as Nav
import Error exposing (buildErrorMessage)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Http
import Model.Author exposing (Author, setName, setUrl)
import Model.Post exposing (Post, PostId, postDecoder, postEncoder, setAuthor)
import RemoteData exposing (WebData)
import Route


type alias Model =
    { navKey : Nav.Key
    , post : WebData Post
    , saveError : Maybe String
    }


type Msg
    = PostReceived (WebData Post)
    | UpdateTitle String
    | UpdateAuthorName String
    | UpdateAuthorUrl String
    | SavePost
    | PostSaved (Result Http.Error Post)


init : PostId -> Nav.Key -> ( Model, Cmd Msg )
init postId navKey =
    ( initialModel navKey, fetchPost postId )


initialModel : Nav.Key -> Model
initialModel navKey =
    { navKey = navKey
    , post = RemoteData.Loading
    , saveError = Nothing
    }


serverUrl =
    "http://localhost:5019/posts/"


fetchPost : PostId -> Cmd Msg
fetchPost postId =
    Http.get
        { url = serverUrl ++ Model.Post.idToString postId
        , expect =
            postDecoder
                |> Http.expectJson (RemoteData.fromResult >> PostReceived)
        }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        PostReceived post ->
            ( { model | post = post }, Cmd.none )

        UpdateTitle newTitle ->
            let
                updateTitle =
                    RemoteData.map
                        (\post -> { post | title = newTitle })
                        model.post
            in
            ( { model | post = updateTitle }, Cmd.none )

        UpdateAuthorName newName ->
            let
                updateName =
                    RemoteData.map
                        (\post -> post |> (setAuthor <| setName newName))
                        model.post
            in
            ( { model | post = updateName }, Cmd.none )

        UpdateAuthorUrl newUrl ->
            let
                updateUrl =
                    RemoteData.map
                        (\post -> post |> (setAuthor <| setUrl newUrl))
                        model.post
            in
            ( { model | post = updateUrl }, Cmd.none )

        SavePost ->
            ( model, savePost model.post )

        PostSaved (Ok postData) ->
            let
                post =
                    RemoteData.succeed postData
            in
            ( { model
                | post = post
                , saveError = Nothing
              }
            , Route.pushUrl Route.Posts model.navKey
            )

        PostSaved (Err error) ->
            ( { model
                | saveError = Just (buildErrorMessage error)
              }
            , Cmd.none
            )


savePost : WebData Post -> Cmd Msg
savePost post =
    case post of
        RemoteData.Success postData ->
            Http.request
                { method = "PATCH"
                , headers = []
                , url = serverUrl ++ Model.Post.idToString postData.id
                , body = Http.jsonBody (postEncoder postData)
                , expect = Http.expectJson PostSaved postDecoder
                , timeout = Nothing -- Just (Time.second 30)
                , tracker = Nothing
                }

        _ ->
            Cmd.none



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ h3 [] [ text "Edit Post" ]
        , viewPost model.post
        , viewSaveError model.saveError
        ]


viewPost : WebData Post -> Html Msg
viewPost post =
    case post of
        RemoteData.NotAsked ->
            text ""

        RemoteData.Loading ->
            h3 [] [ text "Loading Post..." ]

        RemoteData.Success postData ->
            editForm postData

        RemoteData.Failure httpError ->
            viewFetchError (buildErrorMessage httpError)


viewFetchError : String -> Html Msg
viewFetchError errMsg =
    div []
        [ h3 [] [ text "There was a problem fetching the post:" ]
        , text ("ERROR: " ++ errMsg)
        ]


editForm : Post -> Html Msg
editForm post =
    Html.form []
        [ div []
            [ text "Title"
            , br [] []
            , input
                [ type_ "text"
                , value post.title
                , onInput UpdateTitle
                ]
                []
            ]
        , br [] []
        , div []
            [ text "Author name"
            , br [] []
            , input
                [ type_ "text"
                , value post.author.name
                , onInput UpdateAuthorName
                ]
                []
            ]
        , div []
            [ text "Author URL"
            , br [] []
            , input
                [ type_ "text"
                , value post.author.url
                , onInput UpdateAuthorUrl
                ]
                []
            ]
        , div []
            [ button [ type_ "button", onClick SavePost ]
                [ text "Submit" ]
            ]
        ]


viewSaveError : Maybe String -> Html msg
viewSaveError error =
    case error of
        Just errorMsg ->
            div []
                [ h3 [] [ text "Couldnt save the post" ]
                , text ("Error: " ++ errorMsg)
                ]

        Nothing ->
            text ""
