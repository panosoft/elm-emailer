port module Test.App exposing (..)

{- TODO remove this when compiler is fixed -}

import Json.Decode
import Emailer exposing (..)


port exitApp : Float -> Cmd msg


port externalStop : (() -> msg) -> Sub msg


config : Emailer.Config
config =
    { mtEmailerConfig
        | host = "localhost"
        , port_ = Just 465
        , auth = Just <| Auth "user" "password"
        , debug = True
    }


options : MessageOptions
options =
    { from = "noreply@example.com"
    , to = "joe@example.com"
    , subject = "Testing elm-emailer"
    , message = TextMessage "This is a test message from elm-emailer"
    }


sendEmail : MessageOptions -> SendCompleteTagger Msg -> Cmd Msg
sendEmail =
    Emailer.send config


type alias Model =
    {}


type Msg
    = Nop
    | SendComplete SendResult


initModel : Model
initModel =
    {}


init : ( Model, Cmd Msg )
init =
    ( initModel, sendEmail options SendComplete )


main : Program Never Model Msg
main =
    Platform.program
        { init = init
        , update = update
        , subscriptions = subscriptions
        }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Nop ->
            model ! []

        SendComplete (Ok message) ->
            let
                l =
                    Debug.log "SendComplete" message
            in
                ( model, exitApp 0 )

        SendComplete (Err error) ->
            let
                l =
                    Debug.log "SendComplete Error" error
            in
                ( model, exitApp 1 )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
