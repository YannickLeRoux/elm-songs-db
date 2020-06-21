module Main exposing (..)

-- import Html.Attributes exposing (onChange)

import Browser
import Browser.Navigation as Nav
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import Html exposing (Html)
import Html.Attributes exposing (placeholder, style)
import Html.Events exposing (onClick, onInput)
import Http
<<<<<<< HEAD
import Song exposing ()
=======
import Route exposing (Route)
import Song exposing (..)
import Url exposing (Url)
>>>>>>> 33cb7426151cb512ee9e378a1bfd2c25a8317629



-- MODEL


init : () -> Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url navKey =
    let
        model =
            { status = Loading
            , listOfSongs = []
            , currentSong = Song "" ""
            , page = NotFoundPage
            , route = Route.parseUrl url
            , navKey = navKey
            }
    in
    initCurrentPage
        ( model
        , getAllSongs
        )


initCurrentPage : ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
initCurrentPage ( model, existingCmds ) =
    let
        ( currentPage, mappedPageCmds ) =
            case model.route of
                Route.NotFound ->
                    ( NotFoundPage, Cmd.none )

                Route.Songs ->
                    let
                        ( pageModel, pageCmds ) =
                            ListPosts.init
                    in
                    ( SongsPage pageModel, Cmd.map ListPageMsg pageCmds )
    in
    ( { model | page = currentPage }
    , Cmd.batch [ existingCmds, mappedPageCmds ]
    )



-- state of the app


initState : Model
initState =
    { status = Loading
    , listOfSongs = []
    , currentSong = Song "" "" ""
    }


type alias Model =
    { status : Status
    , listOfSongs : List Song
    , currentSong : Song
    , route : Route
    , page : Page
    }


type Page
    = NotFoundPage
    | SongsPage List Song.Model


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
    | UpdateBPM String
    | AddNewSong
    | DeleteSong PostId


errorToString : Http.Error -> String
errorToString err =
    case err of
        Http.Timeout ->
            "Timeout exceeded"

        Http.NetworkError ->
            "Network error"

        Http.BadUrl url ->
            "Malformed url: " ++ url

        Http.BadStatus status ->
            "Returning " ++ String.fromInt status ++ " status"

        _ ->
            "Well I dont know what error is this!"



-- TODO go watch the todo MVC tutorial


updateSongTitle : String -> Model -> Model
updateSongTitle str ({ currentSong } as model) =
    { model | currentSong = { currentSong | title = str } }


updateSongArtist : String -> Model -> Model
updateSongArtist str ({ currentSong } as model) =
    { model | currentSong = { currentSong | artist = str } }


updateSongTempo : String -> Model -> Model
updateSongTempo str ({ currentSong } as model) =
    { model | currentSong = { currentSong | bpm = str } }



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

        UpdateBPM tempo ->
            ( updateSongTempo tempo model, Cmd.none )

        AddNewSong ->
            ( { model | currentSong = Song "" "" "" }
            , Http.post
                { url = "http://localhost:3000/songs"
                , body = Http.jsonBody (encodeSong model.currentSong)
                , expect = Http.expectJson PostSongResponse decodeSong
                }
            )

        DeleteSong id ->
            ( { model | currentSong = Song "" "" "" }
            , Http.request
                { method = "DELETE"
                , headers = []
                , url = "http://localhost:3000/songs" ++ Post.idToString postId
                , body = Http.emptyBody
                , expect = Http.expectString PostDeleted
                , timeout = Nothing
                , tracker = Nothing
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
                        , Input.text []
                            { onChange = UpdateBPM
                            , text = model.currentSong.bpm
                            , placeholder = Just <| Input.placeholder [] <| text "100.00"
                            , label = Input.labelAbove [] <| text "Song BPM"
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
