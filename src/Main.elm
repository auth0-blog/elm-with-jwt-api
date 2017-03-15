port module Main exposing (..)

import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (..)


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
    { quote : String 
    }
    
init : (Model, Cmd Msg)
init =
    ( Model "", Cmd.none )



{-
   UPDATE
   * Messages
   * Update case
-}


type Msg = GetQuote

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GetQuote ->
            ( { model | quote = model.quote ++ "A quote! " }, Cmd.none )



{-
   VIEW
   * Hide sections of view depending on authenticaton state of model
   * Get a quote
   * Log In or Register
   * Get a protected quote
-}


view : Model -> Html Msg
view model =
    div [ class "container" ] [
        h2 [ class "text-center" ] [ text "Chuck Norris Quotes" ]
        , p [ class "text-center" ] [
            button [ class "btn btn-success", onClick GetQuote ] [ text "Grab a quote!" ]
        ]
        -- Blockquote with quote
        , blockquote [] [ 
            p [] [text model.quote] 
        ]
    ]
