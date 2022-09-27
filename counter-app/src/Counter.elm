module Counter exposing (Model)

import Browser
import Html exposing (..)
import Html.Events exposing (..)



-- models represent state (application state to be specific)


type alias Model =
    Int


initialModel : Model
initialModel =
    0



-- a view is a function that takes a model (aka state) and returns the UI for that state
-- since this is all functional, the same state should always lead to same UI output


view : Model -> Html Msg
view model =
    div []
        [ button [ onClick Decrement ] [ text "-" ]
        , text (String.fromInt model)
        , button [ onClick Increment ] [ text "+" ]
        ]


type Msg
    = Increment
    | Decrement


update : Msg -> Model -> Model
update msg currentModel =
    case msg of
        Increment ->
            currentModel + 1

        Decrement ->
            currentModel - 1


main : Program () Model Msg
main =
    Browser.sandbox
        { init = initialModel
        , view = view
        , update = update
        }
