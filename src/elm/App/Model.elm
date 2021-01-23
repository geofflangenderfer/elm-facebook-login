module App.Model exposing (AppModel, initialModel)

import User.Model as User exposing (Model, initialUser)



-- MODEL
--this file is an abstraction. The benefit is it's easy to swap out userModel.
--the cost is it's hard to reason about everything when it's spread apart.
--for a hello world app, everything should not be split


type alias AppModel =
    { userModel : User.Model
    }


initialModel : AppModel
initialModel =
    { userModel = User.initialUser
    }
