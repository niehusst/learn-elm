module Model.Author exposing (..)

import Json.Decode as Decode exposing (Decoder, string)
import Json.Decode.Pipeline exposing (required)
import Json.Encode as Encode


type alias Author =
    { name : String
    , url : String
    }


setUrl : String -> Author -> Author
setUrl url author =
    { author | url = url }


setName : String -> Author -> Author
setName name author =
    { author | name = name }


authorDecoder : Decoder Author
authorDecoder =
    Decode.succeed Author
        |> required "name" string
        |> required "url" string


encodeAuthor : Author -> Encode.Value
encodeAuthor author =
    Encode.object
        [ ( "name", Encode.string author.name )
        , ( "url", Encode.string author.url )
        ]
