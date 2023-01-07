module Main exposing (main)

import Browser exposing (Document, UrlRequest)
import Browser.Navigation as Nav
import Html exposing (..)
import Page.EditPost as EditPost
import Page.ListPosts as ListPosts
import Page.NewPost as NewPost
import Route exposing (Route)
import Url exposing (Url)


type Page
    = NotFoundPage
    | ListPage ListPosts.Model
    | EditPage EditPost.Model
    | NewPage NewPost.Model


type alias Model =
    { route : Route
    , page : Page
    , navKey : Nav.Key
    }


{-| Msg in Main module is just a mapping to the subpage Msg types, since this
code will just forward all messages to the corresponding page.
(and also some over-arching page events)
-}
type Msg
    = ListPageMsg ListPosts.Msg
    | EditPageMsg EditPost.Msg
    | NewPageMsg NewPost.Msg
    | LinkClicked UrlRequest
    | UrlChanged Url


initCurrentPage : ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
initCurrentPage ( model, existingCmds ) =
    let
        ( currentPage, mappedCmds ) =
            case model.route of
                Route.NotFound ->
                    ( NotFoundPage, Cmd.none )

                Route.Posts ->
                    let
                        ( pageModel, pageCmds ) =
                            ListPosts.init
                    in
                    ( ListPage pageModel, Cmd.map ListPageMsg pageCmds )

                Route.Post postId ->
                    let
                        ( pageModel, pageCmds ) =
                            EditPost.init postId model.navKey
                    in
                    ( EditPage pageModel, Cmd.map EditPageMsg pageCmds )

                Route.CreatePost ->
                    let
                        ( pageModel, pageCmds ) =
                            NewPost.init model.navKey
                    in
                    ( NewPage pageModel, Cmd.map NewPageMsg pageCmds )
    in
    ( { model | page = currentPage }
    , Cmd.batch [ existingCmds, mappedCmds ]
    )


init : () -> Url -> Nav.Key -> ( Model, Cmd Msg )
init _ url navKey =
    let
        model =
            { route = Route.parseUrl url
            , page = NotFoundPage
            , navKey = navKey
            }
    in
    initCurrentPage ( model, Cmd.none )



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model.page ) of
        ( ListPageMsg subMsg, ListPage pageModel ) ->
            let
                ( updatedPageModel, updatedCmd ) =
                    ListPosts.update subMsg pageModel
            in
            ( { model | page = ListPage updatedPageModel }
            , Cmd.map ListPageMsg updatedCmd
            )

        ( LinkClicked urlRequest, _ ) ->
            case urlRequest of
                Browser.Internal url ->
                    ( model
                    , Nav.pushUrl model.navKey (Url.toString url)
                    )

                Browser.External url ->
                    ( model
                    , Nav.load url
                    )

        ( UrlChanged url, _ ) ->
            let
                newRoute =
                    Route.parseUrl url
            in
            ( { model | route = newRoute }
            , Cmd.none
            )
                |> initCurrentPage

        ( EditPageMsg submsg, EditPage pageModel ) ->
            let
                ( updatedPageModel, updatedCmd ) =
                    EditPost.update submsg pageModel
            in
            ( { model | page = EditPage updatedPageModel }
            , Cmd.map EditPageMsg updatedCmd
            )

        ( NewPageMsg submsg, NewPage pageModel ) ->
            let
                ( updatedPageModel, updatedCmd ) =
                    NewPost.update submsg pageModel
            in
            ( { model | page = NewPage updatedPageModel }
            , Cmd.map NewPageMsg updatedCmd
            )

        ( _, _ ) ->
            -- handles impossible cases, like (ListPostMsg, EditPostPage)
            ( model, Cmd.none )



-- VIEW


view : Model -> Document Msg
view model =
    { title = "Post App"
    , body = [ currentView model ]
    }


currentView : Model -> Html Msg
currentView model =
    case model.page of
        NotFoundPage ->
            notFoundView

        ListPage listModel ->
            ListPosts.view listModel
                |> Html.map ListPageMsg

        EditPage editModel ->
            EditPost.view editModel
                |> Html.map EditPageMsg

        NewPage newModel ->
            NewPost.view newModel
                |> Html.map NewPageMsg


notFoundView : Html Msg
notFoundView =
    h3 [] [ text "404 page not found!" ]


{-| Browser.element and sandbox are for making smaller components that get embedded in a larger JS application. For standalone elm apps (or elm components that need to handle navigation) then Browser.application is necessary.

On init, the Nav.Key provided to the init function holds the full URL that the user entered (so backend server should serve the elm root html for all paths?). The init function is then responsible for making sure the correct page is shown for that initial state.

-}
main : Program () Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        , onUrlRequest = LinkClicked
        , onUrlChange = UrlChanged
        }
