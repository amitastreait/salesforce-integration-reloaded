var jsforce = require('jsforce');
const express = require('express')
const app = express()
const port = 3000

var oauth2 = new jsforce.OAuth2({
    loginUrl : 'https://login.salesforce.com',
    clientId : '3MVG9VTfpJmxg1yipdnPEKgkwnCYRymZ1jahTd4EOFeDlUiVt_43usqQ1IQk8mqT1FjuseQiOTHifi8aUb0di',
    clientSecret : '477270FA2D9B893A80F955F1EA4704EC8BB429978EFED691C19D0671968E8D1A',
    redirectUri : 'http://localhost:3000/oauth2/callback'
});

app.get('/', (req, res, next) => {
    res.send('Hello World!')
});

app.get('/oauth2/auth', (req, res, next) => {
    res.redirect(oauth2.getAuthorizationUrl());
});

app.get('/oauth2/callback', function(req, res) {
    // http://localhost:3000/oauth2/callback
    console.log(req.query);
    var code = req.query.code;
    console.log(code);

    var conn = new jsforce.Connection({ oauth2 : oauth2 });
    
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

        const eventName = '/event/SAP_Account__e';
        const subscription = conn.streaming.topic(eventName).subscribe(function(payload) {
            console.log('Received message: \n ', JSON.stringify(payload, null, 2));
            // Handle the received platform event message
        });

        const dataCaptureName = '/data/ContactChangeEvent';
        const subscriptionCDCContact = conn.streaming.topic(dataCaptureName).subscribe(function(payload) {
            console.log('CDC Received message: \n ', JSON.stringify(payload, null, 2));
        });

        res.send('success'); // or your desired response
    });
});

app.listen(port,()=>{
    console.log(`Example app listening at http://localhost:${port}`)
})