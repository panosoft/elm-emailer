effect module Emailer
    where { command = MyCmd }
    exposing
        ( Config
        , MessageOptions
        , Auth
        , Message(..)
        , ErrorMessage
        , ResponseMessage
        , SendResult
        , SendCompleteTagger
        , send
        , mtEmailerConfig
        )

{-| Email Effects Module

@docs Config , MessageOptions , Auth , Message , ErrorMessage , ResponseMessage , SendResult , SendCompleteTagger , send , mtEmailerConfig
-}

import Task exposing (Task)
import Native.Emailer


-- API


type MyCmd msg
    = Send Config MessageOptions (SendCompleteTagger msg)


{-| Auth
-}
type alias Auth =
    { user : String
    , pass : String
    }


{-| Module's configuration
-}
type alias Config =
    { host : String
    , port_ : Maybe Int
    , auth : Maybe Auth
    , secure : Bool
    , debug : Bool
    }


{-| Empty config for mutating
-}
mtEmailerConfig : Config
mtEmailerConfig =
    { host = ""
    , port_ = Nothing
    , auth = Nothing
    , secure = True
    , debug = False
    }


{-| Message types
-}
type Message
    = TextMessage String
    | HtmlMessage String


{-| Message options
-}
type alias MessageOptions =
    { from : String
    , to : String
    , subject : String
    , message : Message
    }



-- Taggers


{-| Error message type
-}
type alias ErrorMessage =
    String


{-| Response message type
-}
type alias ResponseMessage =
    String


{-| Send Result
-}
type alias SendResult =
    Result ErrorMessage ResponseMessage


{-| Send completion tagger
-}
type alias SendCompleteTagger msg =
    SendResult -> msg


{-| Effects manager state
-}
type alias State =
    {}



-- Cmds


cmdMap : (a -> b) -> MyCmd a -> MyCmd b
cmdMap f cmd =
    case cmd of
        Send config mailMessageOptions tagger ->
            Send config mailMessageOptions (f << tagger)


{-| Send

    Usage:
        send config options SendComplete

    where:
        SendComplete is your application's message to handle the different scenarios
-}



-- send Cmd


send : Config -> MessageOptions -> SendCompleteTagger msg -> Cmd msg
send config mailMessageOptions tagger =
    command (Send config mailMessageOptions tagger)



-- Operators


(?) : Bool -> ( a, a ) -> a
(?) bool ( t, f ) =
    if bool then
        t
    else
        f


(&>) : Task x a -> Task x b -> Task x b
(&>) t1 t2 =
    t1 |> Task.andThen (\_ -> t2)



-- Init


init : Task Never (State)
init =
    Task.succeed
        {}



-- effect managers API


onEffects : Platform.Router msg (Msg msg) -> List (MyCmd msg) -> State -> Task Never (State)
onEffects router cmds state =
    let
        handleOneCmd state cmd tasks =
            let
                ( task, newState ) =
                    handleCmd router state cmd
            in
                ( task :: tasks, newState )

        ( tasks, cmdState ) =
            List.foldl (\cmd ( tasks, state ) -> handleOneCmd state cmd tasks) ( [], state ) cmds
    in
        Task.sequence (List.reverse <| tasks)
            &> Task.succeed cmdState


settings0 : Platform.Router msg (Msg msg) -> (a -> Msg msg) -> Msg msg -> { onError : a -> Task msg (), onSuccess : Never -> Task x () }
settings0 router errorTagger tagger =
    { onError = \err -> Platform.sendToSelf router (errorTagger err)
    , onSuccess = \_ -> Platform.sendToSelf router tagger
    }


settings1 : Platform.Router msg (Msg msg) -> (a -> Msg msg) -> (b -> Msg msg) -> { onError : a -> Task Never (), onSuccess : b -> Task x () }
settings1 router errorTagger tagger =
    { onError = \err -> Platform.sendToSelf router (errorTagger err)
    , onSuccess = \result1 -> Platform.sendToSelf router (tagger result1)
    }


settings2 : Platform.Router msg (Msg msg) -> (a -> Msg msg) -> (b -> c -> Msg msg) -> { onError : a -> Task Never (), onSuccess : b -> c -> Task x () }
settings2 router errorTagger tagger =
    { onError = \err -> Platform.sendToSelf router (errorTagger err)
    , onSuccess = \result1 result2 -> Platform.sendToSelf router (tagger result1 result2)
    }


handleCmd : Platform.Router msg (Msg msg) -> State -> MyCmd msg -> ( Task Never (), State )
handleCmd router state cmd =
    case cmd of
        Send config mailMessageOptions tagger ->
            ( Native.Emailer.send (settings1 router (ErrorSend tagger) (SuccessSend tagger))
                config.host
                config.port_
                config.auth
                config.secure
                config.debug
                mailMessageOptions
            , state
            )


crashTask : a -> String -> Task Never a
crashTask x msg =
    let
        crash =
            Debug.crash msg
    in
        Task.succeed x


printableState : State -> State
printableState state =
    state


type Msg msg
    = Nop
    | ErrorSend (SendCompleteTagger msg) ErrorMessage
    | SuccessSend (SendCompleteTagger msg) ResponseMessage


onSelfMsg : Platform.Router msg (Msg msg) -> Msg msg -> State -> Task Never (State)
onSelfMsg router selfMsg state =
    case selfMsg of
        Nop ->
            Task.succeed state

        ErrorSend tagger err ->
            (Platform.sendToApp router (tagger <| Err err))
                &> Task.succeed state

        SuccessSend tagger message ->
            (Platform.sendToApp router (tagger <| Ok message))
                &> Task.succeed state
