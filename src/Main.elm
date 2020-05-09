module Main exposing (..)

-- import Html.Attributes exposing (onChange)

import Browser
import Html exposing (..)
import Html.Attributes exposing (placeholder)
import Html.Events exposing (onClick, onInput)
import Http
import Song exposing (..)



-- MODEL


init : () -> ( Model, Cmd Msg )
init _ =
    ( initState
    , getAllSongs
    )



-- state of the app


initState : Model
initState =
    { status = Loading
    , listOfSongs = []
    , currentSong = Song "" ""
    }


type alias Model =
    { status : Status
    , listOfSongs : List Song
    , currentSong : Song
    }


type Status
    = Loading
    | Success (List Song)
    | Failure Http.Error



-- HTTP


getAllSongs : Cmd Msg
getAllSongs =
    Http.get
        { url = "http://localhost:3000/songs"
        , expect = Http.expectJson GotAllSongs decodeAllSongs
        }



-- UPDATE


type Msg
    = GotAllSongs (Result Http.Error (List Song))
    | PostSongResponse (Result Http.Error Song)
    | UpdateTitle String
    | UpdateArtist String
    | AddNewSong


errorToString : Http.Error -> String
errorToString err =
    case err of
        Http.Timeout ->
            "Timeout exceeded"

        Http.NetworkError ->
            "Network error"

        Http.BadUrl url ->
            "Malformed url: " ++ url

        _ ->
            "Well I dont know what error is this!"



-- TODO go watch the todo MVC tutorial


updateSongTitle : String -> Model -> Model
updateSongTitle str ({ currentSong } as model) =
    { model | currentSong = { currentSong | title = str } }


updateSongArtist : String -> Model -> Model
updateSongArtist str ({ currentSong } as model) =
    { model | currentSong = { currentSong | artist = str } }



-- REf
-- https://elmprogramming.com/creating-a-new-post.html


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotAllSongs result ->
            case result of
                Ok songsList ->
                    ( { model | status = Success songsList }, Cmd.none )

                Err message ->
                    ( { model | status = Failure message }, Cmd.none )

        PostSongResponse res ->
            case res of
                Ok _ ->
                    ( model, getAllSongs )

                Err err ->
                    ( { model | status = Failure err }, Cmd.none )

        UpdateTitle title ->
            ( updateSongTitle title model, Cmd.none )

        UpdateArtist title ->
            ( updateSongArtist title model, Cmd.none )

        AddNewSong ->
            ( model
            , Http.post
                { url = "http://localhost:3000/songs"
                , body = Http.jsonBody (encodeSong model.currentSong)
                , expect = Http.expectJson PostSongResponse decodeSong
                }
            )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Model -> Html Msg
view model =
    case model.status of
        Failure message ->
            div [] [ text ("Problem!: " ++ errorToString message) ]

        Loading ->
            div [] [ text "Loading..." ]

        Success songsList ->
            div []
                [ div []
                    [ input [ placeholder "Title", onInput UpdateTitle ] []
                    , input [ placeholder "Artist", onInput UpdateArtist ] []
                    , button [ onClick AddNewSong ] [ text "add song" ]
                    ]
                , div []
                    (viewAllSongs songsList)
                ]


viewAllSongs : List Song -> List (Html Msg)
viewAllSongs list =
    List.map viewSong list


viewSong : Song -> Html Msg
viewSong song =
    div [] [ text song.title ]


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
