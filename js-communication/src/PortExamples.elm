port module PortExamples exposing (main)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)


type alias Model =
    String


type Msg
    = SendDataToJS
    | ReceivedDataFromJS Model


view : Model -> Html Msg
view model =
    div []
        [ button [ onClick SendDataToJS ]
            [ text "Send data to JS" ]
        , br [] []
        , br [] []
        , text ("Data back from JS: " ++ model)
        ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SendDataToJS ->
            ( model, sendData "Howdy javascript~" )

        ReceivedDataFromJS data ->
            ( data, Cmd.none )



-- FUNCS FOR COMMUNICATING W/ JS


{-| port is a keyword in elm that creates a function for us
just from the function signature we provide.

Here we explicitly use anon type lowercase "msg" for our Cmd
associated type. This is because the port function does not
actually send a message back to our elm app, so we use anon
type instead. A command that doesnt send any messages back to
the app always has the type "Cmd msg". Outgoing port functions always
have this return type.

port functions can also only have 1 parameter. Here we've
chosen it to be String.

Any module that declares a port function must be a "port module"
meaning that we have to prefix our module definition at the
top with "port" as well.

Rather than getting data back from JS directly, we have
incoming port functions that are subscriptions to events the
elm runtime will send us (from js).

-}
port sendData : String -> Cmd msg


port receiveData : (Model -> msg) -> Sub msg



-- end imPORTant stuff


subscriptions : Model -> Sub Msg
subscriptions _ =
    receiveData ReceivedDataFromJS


init : () -> ( Model, Cmd Msg )
init _ =
    ( "", Cmd.none )


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
