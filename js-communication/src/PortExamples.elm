port module PortExamples exposing (main)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Json.Decode exposing (Error(..), Value, decodeValue, string)



-- dummy data models


type alias ComplexData =
    { posts : List Post
    , comments : List Comment
    , profile : Profile
    }


type alias Post =
    { id : Int
    , title : String
    , author : Author
    }


type alias Author =
    { name : String
    , url : String
    }


type alias Comment =
    { id : Int
    , body : String
    , postId : Int
    }


type alias Profile =
    { name : String }



-- end data models


type alias Model =
    { dataFromJS : String
    , dataToJS : ComplexData
    , jsonError : Maybe Error
    }


type Msg
    = SendDataToJS
    | ReceivedDataFromJS Value


view : Model -> Html Msg
view model =
    div []
        [ button [ onClick SendDataToJS ]
            [ text "Send data to JS" ]
        , br [] []
        , br [] []
        , viewDataOrError model
        ]


viewDataOrError : Model -> Html Msg
viewDataOrError model =
    case model.jsonError of
        Nothing ->
            text ("Data back from JS: " ++ model.dataFromJS)

        Just error ->
            text ("Error from JS: " ++ buildErrorMessage error)


buildErrorMessage : Error -> String
buildErrorMessage error =
    case error of
        Failure message _ ->
            message

        _ ->
            "Invalid JSON"


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SendDataToJS ->
            ( model, sendData model.dataToJS )

        ReceivedDataFromJS value ->
            case decodeValue string value of
                Ok data ->
                    ( { model
                        | dataFromJS = data
                        , jsonError = Nothing
                      }
                    , Cmd.none
                    )

                Err error ->
                    ( { model | jsonError = Just error }, Cmd.none )



-- FUNCS FOR COMMUNICATING W/ JS


{-| port is a keyword in elm that creates a function for us
just from the function signature we provide.

Here we explicitly use anon type lowercase "msg" for our Cmd
associated type. This is because the port function does not
actually send a message back to our elm app, so we use anon
type instead. A command that doesnt send any messages back to
the app always has the type "Cmd msg". Outgoing port functions always
have this return type.

port functions can also only have 1 parameter.

Any module that declares a port function must be a "port module"
meaning that we have to prefix our module definition at the
top with "port" as well.

Rather than getting data back from JS directly, we have
incoming port functions that are subscriptions to events the
elm runtime will send us (from js).

-}
port sendData : ComplexData -> Cmd msg


{-| Value is a type provided by Json.Encode and Decode modules
-}
port receiveData : (Value -> msg) -> Sub msg



-- end imPORTant stuff


subscriptions : Model -> Sub Msg
subscriptions _ =
    receiveData ReceivedDataFromJS


init : () -> ( Model, Cmd Msg )
init _ =
    ( initialModel
    , Cmd.none
    )


initialModel : Model
initialModel =
    { dataFromJS = ""
    , jsonError = Nothing
    , dataToJS = complexData
    }


complexData : ComplexData
complexData =
    let
        post1 =
            Author "typicode" "https://github.com/typicode"
                |> Post 1 "json-server"

        post2 =
            Author "indexzero" "https://github.com/indexzero"
                |> Post 2 "http-server"
    in
    { posts = [ post1, post2 ]
    , comments = [ Comment 1 "some comment" 1 ]
    , profile = { name = "typicode" }
    }


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
