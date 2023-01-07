port module PortExamples exposing (main)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)


type alias Model =
    String


type Msg
    = SendDataToJS


view : Model -> Html Msg
view model =
    div []
        [ button [ onClick SendDataToJS ]
            [ text "Send data to JS" ]
        ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SendDataToJS ->
            ( model, sendData "Howdy javascript~" )



-- CMD FOR SENDING MSG TO JS


{-| port is a keyword in elm that creates a function for us
just from the function signature we provide.

Here we explicitly use anon type lowercase "msg" for our Cmd
associated type. This is because the port function does not
actually send a message back to our elm app, so we use anon
type instead. A command that doesnt send any messages back to
the app always has the type "Cmd msg". port functions always
have this return type.

port functions can also only have 1 parameter. Here we've
chosen it to be String.

Any module that declares a port function must be a "port module"
meaning that we have to prefix our module definition at the
top with "port" as well.

-}
port sendData : String -> Cmd msg



-- end important stuff


init : () -> ( Model, Cmd Msg )
init _ =
    ( "", Cmd.none )


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }
