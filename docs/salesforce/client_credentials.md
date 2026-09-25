Link to Document - 

    https://help.salesforce.com/s/articleView?id=xcloud.remoteaccess_oauth_client_credentials_flow.htm&type=5

User Info Endpoint - https://<YOUR_MY_DOMAIN>.my.salesforce.com/services/oauth2/userinfo

Sample Request for Access Token

POST https://<YOUR_MY_DOMAIN>.my.salesforce.com/services/oauth2/token
Content-Type: application/x-www-form-urlencoded

grant_type=client_credentials&
client_id=<CONSUMER_KEY>&
client_secret=<CONSUMER_SECRET>

Actual Token Request for Access Token
POST https://course-pantherschools-dev-ed.develop.my.salesforce.com/services/oauth2/token
Content-Type: application/x-www-form-urlencoded

grant_type=client_credentials&
client_id=<CONSUMER_KEY>&
client_secret=<CONSUMER_SECRET>