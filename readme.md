# Emailer Effects Manager for Elm

> An Effects Manager that enables a node Elm program to send Email. It supports the SMTP protocol as documented in nodemailer.

> This is built on top of the Email library for node, [nodemailer](https://github.com/nodemailer/nodemailer), and supports a subset of the library's functionality.

## Install

### Elm

Since the Elm Package Manager doesn't allow for Native code and this uses Native code, you have to install it directly from GitHub, e.g. via [elm-github-install](https://github.com/gdotdesign/elm-github-install) or some equivalent mechanism.

### Node modules

You'll also need to install the dependent node modules at the root of your Application Directory. See the example `package.json` for a list of the dependencies.

The installation can be done via `npm install` command.

### Test program

The test program sends a text email. Use `aBuild.sh` or `build.sh` to build it and run it with `node main` command.

## API

### Commands


> Send an email

Send an email using the supplied email config and options.

```elm
send : EmailConfig -> EmailOptions -> SendCompleteTagger msg -> Cmd msg
send config mailOptions tagger =
```
__Usage__

```elm
send config mailOptions SendComplete
```
* `SendComplete` is your application's messages to handle the different result scenarios
* `config` has fields used to configure the email transport.
* `mailOptions` has email routing and content information.

__EmailConfig__

```elm
{-| Email credentials
-}
type alias Auth =
    { user : String
    , pass : String
    }


type alias EmailConfig =
    { host : String
    , port_ : Maybe Int
    , auth : Maybe Auth
    , secure : Bool
    , debug : Bool
    }

{-| Default EmailConfig options.  See nodemailer SMTP transport documentation.
-}
mtEmailConfig : EmailConfig
mtEmailConfig =
    { host = ""
    , port_ = Nothing
    , auth = Nothing
    , secure = True
    , debug = False
    }
```
__Usage__

```elm
config : EmailConfig
config =
    { mtEmailConfig
        | host = "localhost"
        , port_ = Just 465
        , auth = Just <| Auth "user" "password"
        , debug = True
    }
```

__EmailOptions__

```elm
{-| EmailOptions message can be plain text or html
-}
type EmailMessage
    = TextMessage String
    | HtmlMessage String


type alias EmailOptions =
    { from : String
    , to : String
    , subject : String
    , message : EmailMessage
    }
```
__Usage__

```elm
options : EmailOptions
options =
    { from = "noreply@example.com"
    , to = "joe@example.com"
    , subject = "Testing elm-emailer"
    , message = TextMessage "This is a test message from elm-emailer"
    }
```


### Subscriptions

> There are no subscriptions.


### Messages


#### SendCompleteTagger

Returns an elm Result indicating a successful email send or an error sending the email.

```elm
type alias SendCompleteTagger msg =
    ( Result String String ) -> msg
```

__Usage__

```elm
SendComplete (Ok message) ->
    let
        l =
            Debug.log "SendComplete" message
    in
    model ! []

SendComplete (Err error) ->
    let
        l =
            Debug.log "SendComplete Error" error
    in
        model ! []
```
