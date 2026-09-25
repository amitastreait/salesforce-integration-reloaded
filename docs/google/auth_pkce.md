## Step 1 - Prepare the code_verifier & code_challenge

 - **code_verifier:** A cryptographically random, high-entropy string (43 to 128 characters long) 
 - **code_challenge:** A transformed version of the code_verifier. It is typically created by hashing the code_verifier with the SHA-256 algorithm and then encoding it in Base64-URL.
    - **code_challenge** = BASE64URL-ENCODE(SHA256(code_verifier))

 - PKCE Generator Tool - https://tonyxu-io.github.io/pkce-generator/

## Step 2 - Direct the user to Google's OAuth 2.0 server

https://accounts.google.com/o/oauth2/v2/auth?scope=https://www.googleapis.com/auth/calendar https://www.googleapis.com/auth/drive https://www.googleapis.com/auth/youtube&access_type=offline&include_granted_scopes=true&response_type=code&state=state_parameter_passthrough_value&redirect_uri=https://login.salesforce.com/services/oauth2/success&client_id=1068862644457-jui5fjeb30sadet6lt1t30ughrq5r87h.apps.googleusercontent.com&prompt=consent&code_challenge=hNu_FIOvsQawBkjctiuT-cO17oPaLUuD9Bq74toPPwQ&code_challenge_method=S256


## Step 3 - Exchange the authorization code for an access token

POST https://oauth2.googleapis.com/token HTTP/1.1
Content-Type: application/x-www-form-urlencoded 

code=4/P7q7W91a-oMsCeLvIaQm6bTrgtp7&
client_id=your_client_id&
redirect_uri=https%3A//developers.google.com/oauthplayground&
grant_type=authorization_code&
client_secret=your_client_secret&
code_verifier=

### Google Calendar Endpoints

1. https://www.googleapis.com/calendar/v3/calendars/[CALENDARID]/events

2. With Attachments
    https://www.googleapis.com/calendar/v3/calendars/[CALENDARID]/events?supportsAttachments=true