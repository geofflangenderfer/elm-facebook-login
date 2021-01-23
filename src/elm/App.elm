port module App exposing (AppModel, Msg(..), init, initialModel, update, updateWithStorage, view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Json.Decode as Decode exposing (..)
import Json.Encode as Encode exposing (..)
import User


type alias AppModel =
    { userModel : User.Model
    }


initialModel : AppModel
initialModel =
    { userModel = User.initialUser
    }



-- MESSAGE


type Msg
    = NoOp
    | Login
    | Logout
    | LoggedIn String
    | LoggedOut String
    | UserMsg User.Msg



-- INIT


init : Maybe Encode.Value -> ( AppModel, Cmd Msg )
init savedModel =
    case savedModel of
        Just value ->
            let
                _ =
                    Debug.log "init value " value
            in
            ( Maybe.withDefault initialModel (Decode.decodeValue modelDecoder value |> resultToMaybe)
            , Cmd.none
            )

        _ ->
            ( initialModel
            , Cmd.none
            )



-- PORTS


port setStorage : Encode.Value -> Cmd msg


port login : {} -> Cmd msg


port logout : {} -> Cmd msg



-- UPDATE


updateWithStorage : Msg -> AppModel -> ( AppModel, Cmd Msg )
updateWithStorage msg model =
    let
        ( newModel, cmds ) =
            update msg model

        _ =
            Debug.log "updateWithStorage " msg
    in
    ( newModel
    , Cmd.batch [ setStorage (User.modelToValue newModel.userModel), cmds ]
    )


update : Msg -> AppModel -> ( AppModel, Cmd Msg )
update msg model =
    case msg of
        LoggedIn json ->
            let
                ( updatedUserModel, userCmd ) =
                    User.update (User.UserLoggedIn json) model.userModel

                _ =
                    Debug.log "update LoggedIn " json
            in
            ( { model | userModel = updatedUserModel }, Cmd.map UserMsg userCmd )

        LoggedOut loggedOutMsg ->
            let
                ( updatedUserModel, userCmd ) =
                    User.update (User.UserLoggedOut loggedOutMsg) model.userModel

                _ =
                    Debug.log "update LoggedOut " loggedOutMsg
            in
            ( { model | userModel = updatedUserModel }, Cmd.none )

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


modelDecoder : Decode.Decoder AppModel
modelDecoder =
    Decode.map5 modelConstructor
        (field "uid" Decode.string)
        (field "name" Decode.string)
        (field "url" Decode.string)
        (field "loginStatus" Decode.string |> andThen User.loginStatusDecoder)
        (field "userType" Decode.string |> andThen User.userTypeDecoder)



-- HELPERS
-- helper to construct model from the decoded object


modelConstructor : String -> String -> String -> User.LoginStatus -> User.UserType -> AppModel
modelConstructor uid name picture status userType =
    AppModel
        { uid = uid
        , name = name
        , url = picture
        , loginStatus = status
        , userType = userType
        }



-- Maybe object helper


resultToMaybe : Result Error AppModel -> Maybe AppModel
resultToMaybe result =
    case result of
        Result.Ok model ->
            Just model

        Result.Err error ->
            Nothing


view : AppModel -> Html Msg
view app =
    case app.userModel.loginStatus of
        User.Connected ->
            div []
                [ div [] [ text app.userModel.name ]
                , loggedInHtml app.userModel.url
                ]

        _ ->
            div []
                [ div [] [ text app.userModel.name ]
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
