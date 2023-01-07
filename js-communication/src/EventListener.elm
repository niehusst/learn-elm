module EventListener exposing (Model)

{- a basic app for listening to key and mouse presses.
   increments value on 'i' and mouse click, and decrements on 'd'.
-}

import Browser
import Browser.Events exposing (onClick, onKeyPress)
import Html exposing (..)
import Json.Decode as Decode


type alias Model =
    Int


type Msg
    = CharacterKey Char
    | ControlKey String
    | MouseClick


init : () -> ( Model, Cmd Msg )
init _ =
    ( 0, Cmd.none )


view : Model -> Html Msg
view model =
    div []
        [ text (String.fromInt model) ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        CharacterKey 'i' ->
            ( model + 1, Cmd.none )

        CharacterKey 'd' ->
            ( model - 1, Cmd.none )

        MouseClick ->
            ( model + 5, Cmd.none )

        _ ->
            ( model, Cmd.none )


{-| subscriptions must take a model
When accepted multiple subscriptions, we have to batch
our listeners together into 1 subscription.
-}
subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch
        [ onKeyPress keyDecoder
        , onClick (Decode.succeed MouseClick)
        ]


keyDecoder : Decode.Decoder Msg
keyDecoder =
    Decode.map toKey (Decode.field "key" Decode.string)


toKey : String -> Msg
toKey keyValue =
    case String.uncons keyValue of
        Just ( char, "" ) ->
            -- if keyval was a single character, it was a char key
            CharacterKey char

        _ ->
            ControlKey keyValue


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
