-- means this file contains ports


port module Main exposing (..)

import App.Model exposing (AppModel)
import App.Update as Update exposing (Msg, init, update, updateWithStorage)
import App.View exposing (view)
import Browser
import Json.Encode as Encode exposing (Value)



-- MAIN
-- it may receive a js value from init or not
--


main : Program (Maybe Encode.Value) AppModel Update.Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = updateWithStorage
        , subscriptions = subscriptions
        }



-- SUBSCRIPTIONS
-- creates event listener that receives info from javascript
-- this is because the port subscriptions have a function as first parameter. this means incoming data from js


subscriptions : AppModel -> Sub Update.Msg
subscriptions model =
    Sub.batch
        [ userLoggedIn Update.LoggedIn
        , userLoggedOut Update.LoggedOut
        ]



-- PORTS
-- function as first parameter means these ports are receiving info from js


port userLoggedIn : (String -> msg) -> Sub msg


port userLoggedOut : (String -> msg) -> Sub msg
