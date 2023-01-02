module HttpExamples exposing (main)

import Browser
import Html exposing (..)
import Html.Events exposing (onClick)
import Http
import Json.Decode exposing (Decoder, Error(..), decodeString, list, string)


type alias Model =
    { nicknames : List String
    , errorMessage : Maybe String
    }


type Msg
    = SendHttpRequest
    | SendShitRequest
    | DataReceived (Result Http.Error (List String))


view : Model -> Html Msg
view model =
    div []
        [ button [ onClick SendHttpRequest ]
            [ text "Get good Data from server" ]
        , button [ onClick SendShitRequest ]
            [ text "Get shit data from server" ]
        , viewNicknamesOrError model
        ]



-- helpers


viewNickname : String -> Html Msg
viewNickname nickname =
    li [] [ text nickname ]


nicknameDecoder : Decoder (List String)
nicknameDecoder =
    list string


url : String
url =
    "http://localhost:5016/nicknames"


badurl : String
badurl =
    "http://localhost:5016/new-school.txt"


getNicknames : Cmd Msg
getNicknames =
    Http.get
        { url = url
        , expect = Http.expectJson DataReceived nicknameDecoder
        }


getError : Cmd Msg
getError =
    Http.get
        { url = badurl
        , expect = Http.expectJson DataReceived nicknameDecoder
        }


viewNicknamesOrError : Model -> Html Msg
viewNicknamesOrError model =
    case model.errorMessage of
        Just message ->
            viewError message

        Nothing ->
            viewNicknames model.nicknames


viewError : String -> Html Msg
viewError errMsg =
    div []
        [ h3 [] [ text "HTTP error during file fetch." ]
        , text ("Error: " ++ errMsg)
        ]


viewNicknames : List String -> Html Msg
viewNicknames nicknames =
    div []
        [ h3 [] [ text "Old School movie main characters:" ]
        , ul [] (List.map viewNickname nicknames)
        ]


buildErrorMessage : Http.Error -> String
buildErrorMessage err =
    case err of
        Http.BadUrl msg ->
            msg

        Http.Timeout ->
            "Server took too long to respond"

        Http.NetworkError ->
            "Unable to reach server"

        Http.BadStatus statusCode ->
            "Req failed with status: " ++ String.fromInt statusCode

        Http.BadBody msg ->
            msg



-- the good stuff


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SendHttpRequest ->
            ( model, getNicknames )

        SendShitRequest ->
            ( model, getError )

        DataReceived (Ok nicknames) ->
            -- we have to reset error message or it will polute any future updates to the model
            ( { model
                | nicknames = nicknames
                , errorMessage = Nothing
              }
            , Cmd.none
            )

        DataReceived (Err error) ->
            ( { model
                | errorMessage = Just (buildErrorMessage error)
              }
            , Cmd.none
            )


init : () -> ( Model, Cmd Msg )
init _ =
    ( { nicknames = []
      , errorMessage = Nothing
      }
    , Cmd.none
    )


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }
