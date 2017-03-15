port module Main exposing (..)

import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (..)
import Http
import Json.Decode as Decode exposing (..)
import Json.Encode as Encode exposing (..)


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , update = update
        , subscriptions = \_ -> Sub.none
        , view = view
        }



{- 
    MODEL
    * Model type 
    * Initialize model with empty values
-}


type alias Model =
    { username : String
    , password : String
    , token : String
    , quote : String
    , errorMsg : String
    }
    
init : (Model, Cmd Msg)
init =
    ( Model "" "" "" "" "", fetchRandomQuoteCmd )



{-
   UPDATE
   * API routes
   * GET and POST
   * Encode request body
   * Decode responses
   * Messages
   * Update case
-}
-- API request URLs


api : String
api =
    "http://localhost:3001/"


randomQuoteUrl : String
randomQuoteUrl =
    api ++ "api/random-quote"


registerUrl : String
registerUrl =
    api ++ "users"


loginUrl : String
loginUrl =
    api ++ "sessions/create"



-- GET a random quote (unauthenticated)


fetchRandomQuote : Http.Request String
fetchRandomQuote =
    Http.getString randomQuoteUrl


fetchRandomQuoteCmd : Cmd Msg
fetchRandomQuoteCmd =
    Http.send FetchRandomQuoteCompleted fetchRandomQuote


fetchRandomQuoteCompleted : Model -> Result Http.Error String -> ( Model, Cmd Msg )
fetchRandomQuoteCompleted model result =
    case result of
        Ok newQuote ->
            ( { model | quote = newQuote }, Cmd.none )

        Err _ ->
            ( model, Cmd.none )    




-- Encode user to construct POST request body (for Register and Log In)


userEncoder : Model -> Encode.Value
userEncoder model =
    Encode.object
        [ ( "username", Encode.string model.username )
        , ( "password", Encode.string model.password )
        ]



-- POST register / login request


authUser : Model -> String -> Http.Request String
authUser model apiUrl =
    let
        body =
            model
                |> userEncoder
                |> Http.jsonBody
    in
        Http.post apiUrl body tokenDecoder


authUserCmd : Model -> String -> Cmd Msg
authUserCmd model apiUrl =
    Http.send GetTokenCompleted (authUser model apiUrl)


getTokenCompleted : Model -> Result Http.Error String -> ( Model, Cmd Msg )
getTokenCompleted model result =
    case result of
        Ok newToken ->
            ( { model | token = newToken, password = "", errorMsg = "" }, Cmd.none )

        Err error ->
            ( { model | errorMsg = (toString error) }, Cmd.none )



-- Decode POST response to get token


tokenDecoder : Decoder String
tokenDecoder =
    Decode.field "id_token" Decode.string



-- Messages	


type Msg
    = GetQuote
    | FetchRandomQuoteCompleted (Result Http.Error String)
    | SetUsername String
    | SetPassword String
    | ClickRegisterUser
    | ClickLogIn
    | GetTokenCompleted (Result Http.Error String)
    | LogOut


-- Update


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GetQuote ->
            ( model, fetchRandomQuoteCmd )

        FetchRandomQuoteCompleted result ->
            fetchRandomQuoteCompleted model result

        SetUsername username ->
            ( { model | username = username }, Cmd.none )

        SetPassword password ->
            ( { model | password = password }, Cmd.none )

        ClickRegisterUser ->
            ( model, authUserCmd model registerUrl )

        ClickLogIn ->
            ( model, authUserCmd model loginUrl )

        GetTokenCompleted result ->
            getTokenCompleted model result

        LogOut ->
            ( { model | username = "", token = "" }, Cmd.none )


{-
   VIEW
   * Hide sections of view depending on authenticaton state of model
   * Get a quote
   * Log In or Register
-}


view : Model -> Html Msg
view model =
    let
        -- Is the user logged in?
        loggedIn : Bool
        loggedIn =
            if String.length model.token > 0 then
                True
            else
                False

        -- If the user is logged in, show a greeting; if logged out, show the login/register form
        authBoxView =
            let
                -- If there is an error on authentication, show the error alert
                showError : String
                showError =
                    if String.isEmpty model.errorMsg then
                        "hidden"
                    else
                        ""

                -- Greet a logged in user by username
                greeting : String
                greeting =
                    "Hello, " ++ model.username ++ "!"
            in
                if loggedIn then
                    div [ id "greeting" ]
                        [ h3 [ class "text-center" ] [ text greeting ]
                        , p [ class "text-center" ] [ text "You have super-secret access to protected quotes." ]
                        , p [ class "text-center" ]
                            [ button [ class "btn btn-danger", onClick LogOut ] [ text "Log Out" ]
                            ]
                        ]
                else
                    div [ id "form" ]
                        [ h2 [ class "text-center" ] [ text "Log In or Register" ]
                        , p [ class "help-block" ] [ text "If you already have an account, please Log In. Otherwise, enter your desired username and password and Register." ]
                        , div [ class showError ]
                            [ div [ class "alert alert-danger" ] [ text model.errorMsg ]
                            ]
                        , div [ class "form-group row" ]
                            [ div [ class "col-md-offset-2 col-md-8" ]
                                [ label [ for "username" ] [ text "Username:" ]
                                , input [ id "username", type_ "text", class "form-control", Html.Attributes.value model.username, onInput SetUsername ] []
                                ]
                            ]
                        , div [ class "form-group row" ]
                            [ div [ class "col-md-offset-2 col-md-8" ]
                                [ label [ for "password" ] [ text "Password:" ]
                                , input [ id "password", type_ "password", class "form-control", Html.Attributes.value model.password, onInput SetPassword ] []
                                ]
                            ]
                        , div [ class "text-center" ] [
                            button [ class "btn btn-primary", onClick ClickLogIn ] [ text "Log In" ]
                            , button [ class "btn btn-link", onClick ClickRegisterUser ] [ text "Register" ]
                            ]
                        ]
    in
        div [ class "container" ]
            [ h2 [ class "text-center" ] [ text "Chuck Norris Quotes" ]
            , p [ class "text-center" ]
                [ button [ class "btn btn-success", onClick GetQuote ] [ text "Grab a quote!" ]
                ]
              -- Blockquote with quote
            , blockquote []
                [ p [] [ text model.quote ]
                ]
            , div [ class "jumbotron text-left" ]
                [ -- Login/Register form or user greeting
                  authBoxView
                ]
            ]
