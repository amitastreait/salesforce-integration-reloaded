Refresh Token Flow for Google -
    https://developers.google.com/identity/protocols/oauth2/web-server#offline

SAMPLE POSTMAN REQUEST -

POST https://oauth2.googleapis.com/token HTTP/1.1
Host: oauth2.googleapis.com
Content-Type: application/x-www-form-urlencoded

client_id=your_client_id&
client_credentials=your_client_id&
refresh_token=refresh_token&
grant_type=refresh_token

Refresh Token flow for Salesforce - 

    https://help.salesforce.com/s/articleView?id=xcloud.remoteaccess_oauth_refresh_token_flow.htm&type=5


SAMPLE POSTMAN REQUEST -

POST https://login.salesforce.com/services/oauth2/token HTTP/1.1
Host: login.salesforce.com

client_id=3MVG9lKcPoNINVB&
client_secret=1955279925675241571
grant_type=refresh_token&
refresh_token=your token here