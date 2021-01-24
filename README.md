# Facebook Login Hello World
This is a minimal example for getting a user's short-lived access token through OAuth flow.

You can exchange it for a long-lived token that lasts for 60 days

## Install
```
$ git clone https://github.com/geofflangenderfer/facebook_login_hello_world.git
$ cd facebook_login_hello_world/
$ elm reactor
```

then navigate to `src/static/index.html`

## Architechture
- `src/static/facebook.js` contains all the calls to the facebook login sdk
- `src/static/main.js` is the compiled elm code from `Main.elm`
