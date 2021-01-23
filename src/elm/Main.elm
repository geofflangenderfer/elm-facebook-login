port module Main exposing (..)

import App
import Browser
import Json.Encode as Encode exposing (Value)



-- MAIN
-- it may receive a js value from init or not
--


main : Program (Maybe Encode.Value) App.AppModel App.Msg
main =
    Browser.element
        { init = App.init
        , view = App.view
        , update = App.updateWithStorage
        , subscriptions = subscriptions
        }



-- SUBSCRIPTIONS
-- creates event listener that receives info from javascript
-- this is because the port subscriptions have a function as first parameter. this means incoming data from js


subscriptions : App.AppModel -> Sub App.Msg
subscriptions model =
    Sub.batch
        [ userLoggedIn App.LoggedIn
        , userLoggedOut App.LoggedOut
        ]



-- PORTS
-- function as first parameter means these ports are receiving info from js


port userLoggedIn : (String -> msg) -> Sub msg


port userLoggedOut : (String -> msg) -> Sub msg
