module Page.ListSongs exposing (Model, Msg, init, update, view)

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
import Song (Song, SongId, songsDecoder)
import RemoteData exposing (WebData)



-- MODEL


type alias Model =
    { songs : WebData (List Song)
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( { songs = RemoteData.Loading }, fetchSongs )



-- UPDATE


type Msg
    = FetchSongs
    | SongsReceived (WebData (List Song))

fetchSongs : Cmd Msg
fetchSongs =
    Http.get
        { url = "http://localhost:3000/songs/"
        , expect =
            postsDecoder
                |> Http.expectJson (RemoteData.fromResult >> PostsReceived)
        }