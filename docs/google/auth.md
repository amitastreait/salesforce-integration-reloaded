## Step 1 - Direct the user to Google's OAuth 2.0 server

https://accounts.google.com/o/oauth2/v2/auth?
scope=https://www.googleapis.com/auth/calendar https://www.googleapis.com/auth/drive&
access_type=offline&
include_granted_scopes=true&
response_type=code&
state=state_parameter_passthrough_value&
redirect_uri=https://login.salesforce.com/services/oauth2/success&
client_id=1068862644457-kvlgmlenqjr2ui18265nocl3q41tfsq5.apps.googleusercontent.com&
prompt=consent


## Step 2 - Exchange the authorization code for an access token

POST https://oauth2.googleapis.com/token HTTP/1.1
Host: oauth2.googleapis.com
Content-Type: application/x-www-form-urlencoded 

code=4/P7q7W91a-oMsCeLvIaQm6bTrgtp7&
client_id=your_client_id&
redirect_uri=https%3A//developers.google.com/oauthplayground&
grant_type=authorization_code&
client_secret=your_client_secret

### Google Calendar Endpoints

1. https://www.googleapis.com/calendar/v3/calendars/[CALENDARID]/events

2. With Attachments
    https://www.googleapis.com/calendar/v3/calendars/[CALENDARID]/events?supportsAttachments=true