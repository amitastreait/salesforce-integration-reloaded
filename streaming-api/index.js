var jsforce = require('jsforce');
const express = require('express')
require('dotenv').config();

const app = express()
const port = process.env.PORT || 3000;
const path = require('path');

app.use(express.static(path.join(__dirname, 'public')));
app.use(express.static(path.join(__dirname, 'oauth2')));
app.use(express.static(path.join(__dirname, 'images')));

var oauth2 = new jsforce.OAuth2({
  loginUrl : process.env.SF_LOGIN_URL,
  clientId : process.env.SF_CLIENT_ID,
  clientSecret : process.env.SF_CLIENT_SECRET,
  redirectUri : process.env.SF_REDIRECT_URI
});

app.listen(port, () => {
    console.log(`Example app listening on port ${port}`)
})

app.get('/', (req, res) => {
    res.sendFile(path.join(__dirname, 'public', 'index.html'));
});

app.get('/oauth2/auth', function(req, res) {
  res.redirect(oauth2.getAuthorizationUrl());
});

app.get('/oauth2/callback', function(req, res) {
    var conn = new jsforce.Connection({ oauth2 : oauth2 });
    //console.log(req.query);
    var code = req.query.code;
    if(code){
        //console.log(code);
        conn.authorize(code, function(err, userInfo) {
          if (err) { 
            return console.error(err); 
          }
          /*console.log(conn.accessToken);
          console.log(conn.refreshToken);
          console.log(conn.instanceUrl);
          console.log("User ID: " + userInfo.id);*/
          console.log("Org ID: " + userInfo.organizationId);

          const subscription = conn.streaming.topic('/data/AccountChangeEvent').subscribe(function(message) {
            console.log('Received message:', JSON.stringify(message, null, 2));
          });  
          
      });
    }
    res.sendFile(path.join(__dirname, 'oauth2', 'callback.html'));
});