module Model.Post exposing (..)

import Json.Decode as Decode exposing (Decoder, int, list, string)
import Json.Decode.Pipeline exposing (optional, required)
import Json.Encode as Encode
import Model.Author as Author exposing (..)
import Ports
import Url.Parser exposing (Parser, custom)


{-| Masking Int as PostId helps the compiler catch errors
where we meant to pass this specific field value type, but
maybe messed up. While an Int could be mistakenly accepted,
an aliased type makes that way less likely
-}
type PostId
    = PostId Int


type alias Post =
    { id : PostId
    , title : String
    , author : Author
    }


{-| Setter for simplified nested record setting
-}
setAuthor : (Author -> Author) -> Post -> Post
setAuthor fn post =
    { post | author = fn post.author }


setTitle : String -> Post -> Post
setTitle newTitle post =
    { post | title = newTitle }


{-| there are a few ways we can define postDecoder

    postDecoder : Decoder Post
    postDecoder =
        map3 Post
            (field "id" int)
            (field "title" string)
            (field "author" string)

map3 is defined as

    map3 :
        (a -> b -> c -> value)
        -> Decoder a
        -> Decoder b
        -> Decoder c
        -> Decoder value

the stdlib implementation goes up to map8. if you need more fields than that, you can use the elm package NoRedInk/elm-json-decode-pipeline, which also has support for required/optional fields in the decoded json.

    import Json.Decode.Pipeline exposing (optional, optionalAt, required, requiredAt)

    postDecoder : Decoder Post
    postDecoder =
        Decode.succeed Post
            |> required "id" int
            |> required "title" string
            |> required "author" string

-}
postDecoder : Decoder Post
postDecoder =
    Decode.succeed Post
        |> required "id" postIdDecoder
        |> required "title" string
        |> optional "author"
            authorDecoder
            { name = "anon"
            , url = ""
            }


postsDecoder : Decoder (List Post)
postsDecoder =
    list postDecoder


postIdDecoder : Decoder PostId
postIdDecoder =
    Decode.map PostId int


newPostEncoder : Post -> Encode.Value
newPostEncoder post =
    Encode.object
        [ ( "title", Encode.string post.title )
        , ( "author", encodeAuthor post.author )
        ]


postEncoder : Post -> Encode.Value
postEncoder post =
    Encode.object
        [ ( "id", encodeId post.id )
        , ( "title", Encode.string post.title )
        , ( "author", encodeAuthor post.author )
        ]


encodeId : PostId -> Encode.Value
encodeId (PostId id) =
    Encode.int id


{-| The (PostId id) in the function def param spot is doing pattern matching to unwrap the int value from the type alias.
without it we would need a case expression to unwrap
-}
idToString : PostId -> String
idToString (PostId id) =
    String.fromInt id


idParser : Parser (PostId -> a) a
idParser =
    custom "POSTID" <|
        \postId ->
            Maybe.map PostId (String.toInt postId)


emptyPost : Post
emptyPost =
    { id = PostId -1
    , title = ""
    , author =
        { name = ""
        , url = ""
        }
    }


savePosts : List Post -> Cmd msg
savePosts posts =
    Encode.list postEncoder posts
        |> Encode.encode 0
        |> Ports.storePosts
