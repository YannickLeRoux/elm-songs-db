module Song exposing (Song, SongId, decodeAllSongs, decodeSong, encodeSong, viewAllSongs, idToSring)

import Browser
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import Html exposing (Html)
import Http
import Json.Decode as Decode exposing (Decoder, int, string)
import Json.Decode.Pipeline exposing (required)
import Json.Encode as Encode



-- MODEL


init : () -> ( Song, Cmd Msg )
init _ =
    ( Song 0 "" "", Cmd.none )


type alias Song =
    { id : SongId
    , title : String
    , artist : String
    , bpm : String
    }


type SongId
    = SongId Int



-- UPDATE


type Msg
    = DeleteSong Int


update : Msg -> Song -> ( Song, Cmd Msg )
update msg model =
    case msg of
        -- DeleteSong id ->
        --     ( model
        --     , Http.request
        --         { method = "DELETE"
        --         , headers = []
        --         , url = "http://localhost:3000/songs/" ++ id
        --         , body = Http.emptyBody
        --         , expect = Http.expectJson PostSongResponse decodeSong
        --         , timeout = Nothing
        --         , tracker = Nothing
        --         }
        --     )
        _ ->
            ( model, Cmd.none )



-- DECODERS


decodeSong : Decoder Song
decodeSong =
    Decode.succeed Song
        |> required 'id' idDecoder
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


-- Decode the id that is int in json to a SongId
idDecoder : Decoder PostId
idDecoder =
    Decode.map SongId int


-- HELPER FUNCTIONS

idToString: SongId -> String;
idToSring (SongId id) =
    String.fromInt id

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
            , { header = tableHeader "Delete"
              , width = fill
              , view =
                    \song ->
                        tableRow song.artist

              -- Input.button []
              --     { onPress = DeleteSong song.id
              --     , label = text "X"
              --     }
              }
            ]
        }



-- main : Program () Song Msg
-- main =
--     Browser.element
--         { init = init
--         , view = viewAllSongs
--         , update = update
--         , subscriptions = \_ -> Sub.none
--         }
