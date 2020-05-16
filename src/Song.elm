module Song exposing (Song, decodeAllSongs, decodeSong, encodeSong, viewAllSongs)

import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import Html exposing (Html)
import Json.Decode as Decode exposing (Decoder, float, int, string)
import Json.Decode.Pipeline exposing (required)
import Json.Encode as Encode



-- MODEL


type alias Song =
    { title : String
    , artist : String
    , bpm : String
    }



-- DECODERS


decodeSong : Decoder Song
decodeSong =
    Decode.succeed Song
        |> required "title" string
        |> required "artist" string
        |> required "bpm" string


encodeSong : Song -> Encode.Value
encodeSong sg =
    Encode.object
        [ ( "title", Encode.string sg.title )
        , ( "artist", Encode.string sg.artist )
        , ( "bpm", Encode.string sg.bpm )
        ]


decodeAllSongs : Decoder (List Song)
decodeAllSongs =
    Decode.list decodeSong



-- VIEW


tableHeader : String -> Element msg
tableHeader str =
    el [ Background.color <| rgb255 114 159 207, paddingEach edges, Font.color <| rgb255 0xFF 0xFF 0xFF ] (text str)


tableRow data =
    el [ paddingEach { edges | top = 10, bottom = 10 } ] (text <| data)


edges =
    { top = 15
    , right = 0
    , bottom = 15
    , left = 15
    }


viewAllSongs : List Song -> Element msg
viewAllSongs list =
    table [ paddingXY 0 30 ]
        { data = list
        , columns =
            [ { header = tableHeader "Title"
              , width = fill
              , view =
                    \song ->
                        tableRow song.title
              }
            , { header = tableHeader "Artist"
              , width = fill
              , view =
                    \song ->
                        tableRow song.artist
              }
            , { header = tableHeader "BPM"
              , width = fill
              , view =
                    \song ->
                        tableRow song.bpm
              }
            ]
        }
