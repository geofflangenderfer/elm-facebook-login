// pull in desired CSS/SASS files
//require('./styles/main.scss');

// Elm.Main.embed( document.getElementById( 'main' ) );
//var Elm = require('../elm/Main');

var storedState = localStorage.getItem('elm-facebook-api');
var storedAuthResponse = localStorage.getItem('elm-facebook-api-authResponse');
var startingState = storedState ? JSON.parse(storedState) : null;
var alreadyAuthed = storedState ? JSON.parse(storedAuthResponse) : null;

//var app = Elm.Main.fullscreen(startingState);
var app = Elm.Main.init({
  flags: startingState,
  node: document.getElementById('myapp')
});


app.ports.setStorage.subscribe(function (state) {
    localStorage.setItem('elm-facebook-api', JSON.stringify(state));
});

window.fbAsyncInit = function () {

    FB.init({
        appId: '284906869410472',
        status: true,
        xfbml: false,
        version: 'v2.7' // or v2.6, v2.5, v2.4, v2.3 
    });


    FB.getLoginStatus(function (response) {
        if (response.status === 'connected') {
            console.log('FB.getLoginStatus Logged in.');
            var uid = response.authResponse.userID;
            sendAccessToken(
                response.authResponse.accessToken,
                response.authResponse.data_access_expiration_time
            );
            var userData = JSON.stringify(response);
            app.ports.userLoggedIn.send(userData);
        }
        else if (response.status === 'not_authorized') {
            console.log(response.status);
            app.ports.userLoggedOut.send(response.status);
        }
        else if (alreadyAuthed) {
            console.log('auto login');
            let res = {
                authResponse: alreadyAuthed
            }
            FB.login(function (res) { });
        }
        else {
            app.ports.userLoggedOut.send(response.status);
        }



    }, true);

};

function sendAccessToken(at, et) {
    const basicToken = "bmlja0BjaXJjbGVzb2NpYWxpbmMuY29tOitNOS1mS3JyelE0M3E9S00=";
    const proxyurl = "https://immense-island-99832.herokuapp.com/"
    const url = "https://marketingdashboardpipeline.herokuapp.com";

    let data = {};
    data.user = "test@test.com";
    data.access_token = at
    data.expire_time = et
    data.refresh_token = "";
    data.id_provider = "facebook_from_frontend";
    let json = JSON.stringify(data);
    
    let xhr = new XMLHttpRequest();
    xhr.open("POST", url+'/tokens', true);
    xhr.setRequestHeader('Content-type','application/json; charset=utf-8');
    xhr.setRequestHeader('Authorization', `Basic ${basicToken}`);
    xhr.onload = function () {
    	let responseText = JSON.parse(xhr.responseText);
    	if (xhr.readyState == 4 && xhr.status == "201") {
    		console.table(responseText);
    	} else {
    		console.error(responseText);
    	}
    }
    xhr.send(json);
}

(function (d, s, id) {
    var js, fjs = d.getElementsByTagName(s)[0];
    if (d.getElementById(id)) return;
    js = d.createElement(s);
    js.id = id; d;
    js.async = true;
    js.src = "//connect.facebook.net/en_LA/sdk.js";
    fjs.parentNode.insertBefore(js, fjs);
} (document, 'script', 'facebook-jssdk'));


app.ports.logout.subscribe(function () {

    // logout of pseudo login state
    if (alreadyAuthed) {

        let userStatus = {
            uid: "",
            name: "",
            loginStatus : "unknown",
            userType : "Unknown"
        }

        app.ports.userLoggedOut.send(JSON.stringify(userStatus));

    }
    else {
        FB.logout(function (response) {
            console.log('Logging out ' + response);
            app.ports.userLoggedOut.send(response.status);
        });
    }
});

app.ports.login.subscribe(function () {

    FB.login(function (response) {
        if (response.authResponse) {

            localStorage.setItem('elm-facebook-api-authResponse', JSON.stringify(response.authResponse));

            FB.api('/me?fields=name,picture', function (response) {

                var userData = JSON.stringify(response);
                app.ports.userLoggedIn.send(userData);
            });

        } else {
            console.log('User cancelled login or did not fully authorize.');
        }
        // user is now logged out
    });
});
// app.ports.errors.send(response.status);
