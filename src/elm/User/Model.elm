module User.Model exposing (..)

-- import Json.Decode as Decode exposing (decodeString, field, string, at, Decoder, map3, succeed)
-- import Json.Encode as Encode exposing (..)
-- import Debug exposing (log)
-- MODEL
-- types are like enums in go/c++ or data classes in kotlin. It's much easier to deal with an encapsulating type than its constituents


type alias Model =
    { uid : String
    , name : String
    , url : String
    , loginStatus : LoginStatus
    , userType : UserType
    }



-- I believe evan mentioned starting a project by defining types. I'll have to experiment with that
-- it seems like original author was building a food delivery/courier app?


type UserType
    = Unknown
    | Client
    | Vendor
    | Runner



-- I guess it doesn't matter if you think of all edge cases first with your types. Elm makes it easier to add to them as you go along


type LoginStatus
    = Connected
    | UnAuthorised
    | Disconnected



-- INIT
--initiates a user as unauthorized and unknown


initialUser : Model
initialUser =
    { uid = ""
    , name = ""
    , url = ""
    , loginStatus = UnAuthorised
    , userType = Unknown
    }



-- a function to create a new user model


newUser : String -> String -> String -> Model
newUser uid name picture =
    { uid = uid
    , name = name
    , url = picture
    , loginStatus = Connected
    , userType = Client
    }



-- it looks like this was part of a runner work leaderboard?
-- VIEW
-- view : Model -> Html Msg
-- view model =
--     div []
--         [ h3 [] [ text "Leaderboard page... So far" ]
--         , input
--             [ type_ "text"
--             , onInput QueryInput
--             , value model.query
--             , placeholder "Search for a runner..."
--             ]
--             []
--         ]
