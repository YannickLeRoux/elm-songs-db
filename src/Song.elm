module Song exposing (..)

import Json.Decode as Decode exposing (Decoder, int, string)
import Json.Decode.Pipeline exposing (required)
import Json.Encode as Encode



-- MODEL


type alias Song =
    { title : String
    , artist : String
    }



-- DECODERS


decodeSong : Decoder Song
decodeSong =
    Decode.succeed Song
        |> required "title" string
        |> required "artist" string


encodeSong : Song -> Encode.Value
encodeSong sg =
    Encode.object
        [ ( "title", Encode.string sg.title )
        , ( "artist", Encode.string sg.artist )
        ]


decodeAllSongs : Decoder (List Song)
decodeAllSongs =
    Decode.list decodeSong
