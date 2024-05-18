var jsforce = require('jsforce');
const express = require('express')
const app = express()
const port = 3000

// OAuth2 client information can be shared with multiple connections.
var oauth2 = new jsforce.OAuth2({
  loginUrl : 'https://login.salesforce.com',
  clientId : 'qT1FjuseQiOTHifi8aUb0di',
  clientSecret : '477270FA2D9B893A808D1A',
  redirectUri : 'http://localhost:3000/oauth2/callback'
});

app.listen(port, () => {
    console.log(`Example app listening on port ${port}`)
})

app.get('/', (req, res) => {
    res.send('Platform Event Integration using Node.js')
});

// Get authorization url and redirect to it.
app.get('/oauth2/auth', function(req, res) {
  res.redirect(oauth2.getAuthorizationUrl());
  //res.redirect(oauth2.getAuthorizationUrl({ scope : 'api id web' }));
});

app.get('/oauth2/callback', function(req, res) {
    var conn = new jsforce.Connection({ oauth2 : oauth2 });
    console.log(req.query);
    var code = req.query.code;
    console.log(code);
    conn.authorize(code, function(err, userInfo) {
        if (err) { 
          return console.error(err); 
        }
        // Now you can get the access token, refresh token, and instance URL information.
        // Save them to establish connection next time.
        console.log(conn.accessToken);
        console.log(conn.refreshToken);
        console.log(conn.instanceUrl);
        console.log("User ID: " + userInfo.id);
        console.log("Org ID: " + userInfo.organizationId);

        const subscription = conn.streaming.topic('/event/SAP_Account__e').subscribe(function(message) {
          console.log('Received message:', JSON.stringify(message, null, 2));
          // Handle the received platform event message
        });  

        res.send('success'); // or your desired response
    });
});