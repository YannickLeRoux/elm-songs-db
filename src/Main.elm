module Main exposing (..)

-- import Html.Attributes exposing (onChange)

import Browser
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import Html exposing (Html)
import Html.Attributes exposing (placeholder, style)
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



-- VIEW


view : Model -> Html Msg
view model =
    layout [ padding 80 ] <|
        case model.status of
            Failure message ->
                el [] (text ("Problem!: " ++ errorToString message))

            Loading ->
                el [] (text "Loading...")

            Success songsList ->
                column []
                    [ row [ width fill, centerY, spacing 30 ]
                        [ Input.text []
                            { onChange = UpdateTitle
                            , text = model.currentSong.title
                            , placeholder = Just <| Input.placeholder [] <| text "Title"
                            , label = Input.labelAbove [] <| text "Song Title"
                            }
                        , Input.text []
                            { onChange = UpdateArtist
                            , text = model.currentSong.artist
                            , placeholder = Just <| Input.placeholder [] <| text "Artist"
                            , label = Input.labelAbove [] <| text "Song Artist"
                            }
                        , Input.button
                            [ padding 20
                            , Border.width 2
                            , Border.rounded 16
                            , Border.color <| rgb255 0x50 0x50 0x50
                            , Border.shadow { offset = ( 4, 4 ), size = 3, blur = 10, color = rgb255 0xD0 0xD0 0xD0 }
                            , Background.color <| rgb255 114 159 207
                            , Font.color <| rgb255 0xFF 0xFF 0xFF
                            , mouseOver
                                [ Background.color <| rgb255 0xFF 0xFF 0xFF, Font.color <| rgb255 0 0 0 ]
                            , focused
                                [ Border.shadow { offset = ( 4, 4 ), size = 3, blur = 10, color = rgb255 114 159 207 } ]
                            ]
                            { onPress = Just AddNewSong
                            , label = text "Add"
                            }
                        ]
                    , viewAllSongs songsList
                    ]


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }
