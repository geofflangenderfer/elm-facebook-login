port module Main exposing (..)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Json.Decode as D exposing (..)
import Json.Encode as E exposing (..)



-- MAIN
-- it may receive a js value from init or not
--


main : Program (Maybe E.Value) Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = updateWithStorage
        , subscriptions = subscriptions
        }



-- INIT


init : Maybe E.Value -> ( Model, Cmd Msg )
init savedModel =
    case savedModel of
        Just value ->
            let
                _ =
                    Debug.log "init value " value
            in
            ( Maybe.withDefault initialModel (D.decodeValue modelDecoder value |> resultToMaybe)
            , Cmd.none
            )

        _ ->
            ( initialModel
            , Cmd.none
            )


type alias Model =
    { uid : String
    , name : String
    , url : String
    , loginStatus : LoginStatus
    }



-- PORTS


port userLoggedIn : (String -> msg) -> Sub msg


port userLoggedOut : (String -> msg) -> Sub msg


port setStorage : E.Value -> Cmd msg


port login : {} -> Cmd msg


port logout : {} -> Cmd msg


initialModel : Model
initialModel =
    initialUser


initialUser : Model
initialUser =
    { uid = ""
    , name = ""
    , url = ""
    , loginStatus = UnAuthorised
    }



-- I guess it doesn't matter if you think of all edge cases first with your types. Elm makes it easier to add to them as you go along


type LoginStatus
    = Connected
    | UnAuthorised
    | Disconnected



-- MESSAGE


type Msg
    = NoOp
    | Login
    | Logout
    | LoggedIn String
    | LoggedOut String



-- SUBSCRIPTIONS
-- creates event listener that receives info from javascript
-- this is because the port subscriptions have a function as first parameter. this means incoming data from js


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ userLoggedIn LoggedIn
        , userLoggedOut LoggedOut
        ]



-- UPDATE


updateWithStorage : Msg -> Model -> ( Model, Cmd Msg )
updateWithStorage msg model =
    let
        ( newModel, cmds ) =
            update msg model

        _ =
            Debug.log "updateWithStorage " msg
    in
    ( newModel
    , Cmd.batch [ setStorage (modelToValue newModel), cmds ]
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LoggedIn json ->
            let
                ( updatedUserModel, userCmd ) =
                    case decodeString userDecoder json of
                        Ok userData ->
                            let
                                newModel =
                                    { uid = userData.uid
                                    , name = userData.name
                                    , url = userData.url
                                    , loginStatus = Connected
                                    }
                            in
                            ( newModel
                            , Cmd.none
                            )

                        Err error ->
                            ( model, Cmd.none )

                _ =
                    Debug.log "update LoggedIn " json
            in
            ( updatedUserModel, userCmd )

        LoggedOut loggedOutMsg ->
            let
                ( updatedUserModel, userCmd ) =
                    ( initialUser, Cmd.none )

                _ =
                    Debug.log "update LoggedOut " loggedOutMsg
            in
            ( updatedUserModel, Cmd.none )

        Login ->
            let
                _ =
                    Debug.log "update Login " Login
            in
            ( model, login {} )

        Logout ->
            let
                _ =
                    Debug.log "update Login " Login
            in
            ( model, logout {} )

        _ ->
            ( model, Cmd.none )



-- DECODER
-- Decode the saved model from localstorage


modelDecoder : D.Decoder Model
modelDecoder =
    D.map4 modelConstructor
        (field "uid" D.string)
        (field "name" D.string)
        (field "url" D.string)
        (field "loginStatus" D.string |> andThen loginStatusDecoder)



-- HELPERS
-- helper to construct model from the decoded object


modelConstructor : String -> String -> String -> LoginStatus -> Model
modelConstructor uid name picture status =
    { uid = uid
    , name = name
    , url = picture
    , loginStatus = status
    }



-- Maybe object helper


resultToMaybe : Result Error Model -> Maybe Model
resultToMaybe result =
    case result of
        Result.Ok model ->
            Just model

        Result.Err error ->
            Nothing


view : Model -> Html Msg
view app =
    case app.loginStatus of
        Connected ->
            div []
                [ div [] [ text app.name ]
                , loggedInHtml app.url
                ]

        _ ->
            div []
                [ div [] [ text app.name ]
                , loggedOutHtml
                ]


loggedInHtml : String -> Html Msg
loggedInHtml pic =
    div []
        [ img [ src pic ] []
        , button [ onClick Logout ] [ text "Logout" ]
        ]


loggedOutHtml : Html Msg
loggedOutHtml =
    button [ onClick Login ] [ text "Login" ]



-- a function to create a new user model


newUser : String -> String -> String -> Model
newUser uid name picture =
    { uid = uid
    , name = name
    , url = picture
    , loginStatus = Connected
    }



-- DECODERS


userDecoder : Decoder Model
userDecoder =
    map3 newUser
        (field "id" D.string)
        (field "name" D.string)
        (field "picture" <| (field "data" <| field "url" D.string))


setName : String -> Model -> Model
setName newName user =
    { user | name = newName }


loginStatusDecoder : String -> D.Decoder LoginStatus
loginStatusDecoder status =
    let
        _ =
            Debug.log "loginStatusDecoder " status
    in
    case status of
        "Connected" ->
            D.succeed Connected

        "UnAuthorised" ->
            D.succeed UnAuthorised

        "Disconnected" ->
            D.succeed Disconnected

        _ ->
            D.fail (status ++ " is not a recognized tag for login status")



-- ENCODERS


modelToValue : Model -> E.Value
modelToValue model =
    E.object
        [ ( "uid", E.string model.uid )
        , ( "name", E.string model.name )
        , ( "url", E.string model.url )
        , ( "loginStatus", loginStatusToValue model.loginStatus )
        ]


loginStatusToValue : LoginStatus -> E.Value
loginStatusToValue status =
    case status of
        Connected ->
            E.string "Connected"

        UnAuthorised ->
            E.string "UnAuthorised"

        Disconnected ->
            E.string "Disconnected"
