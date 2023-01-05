module RandomNumber exposing (main)

-- TODO fix

import Browser
import Html exposing (..)
import Html.Events exposing (onClick)
import Random


type alias Model =
    Int


type Msg
    = GenerateRandomNumber
    | NewRandomNumber Int



-- blank param spot for `flags` which we dont use


init : () -> ( Model, Cmd Msg )
init _ =
    ( 0, Cmd.none )


view : Model -> Html Msg
view model =
    div []
        [ text (String.fromInt model)
        , button [ onClick GenerateRandomNumber ]
            [ text "Generate Random Number" ]
        ]



-- param order matters since this is used by Browser.element


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GenerateRandomNumber ->
            ( model, Random.generate NewRandomNumber (Random.int 0 100) )

        NewRandomNumber num ->
            ( num, Cmd.none )



{-
   Browser.element is the real deal (actually its not, Browser.application is). unless creating a completely static page (basically) you won't ever need Browser.sandbox in the real world, because it doesn't leave any way to communicate w/ the Elm runtime (which does all the handling of side-effects pub/sub).
   Browser.element gives you options to subscribe to external events you might want to listen for, and fire off events using Cmd.
   Advice is to start of w/ Browser.sandbox until you run into a usecase for Browser.element (but that moment will likely come if youre planning anything at all complex.)
-}


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }
