# Implement JWT auth using Salesforce API

## Important Links 

- Official Salesforce Document - https://help.salesforce.com/s/articleView?id=xcloud.remoteaccess_oauth_jwt_flow.htm&type=5
- Apex Hours - https://www.apexhours.com/salesforce-oauth-2-0-jwt-bearer-flow/

## Prerequite - Download and Install OPEN SSL

- Download for Windows - https://gnuwin32.sourceforge.net/packages/openssl.htm
    - Set OPENSSL_CONF path
    - set OPENSSL_CONF=C:\openssl\share\openssl.cnf 
- Download for MAC - Use brew command to insall - brew install openssl


## Step1 - Generate the Client Certificate and Private KEY

Step1.1 - openssl genrsa -des3 -passout pass:PANTHER_UDEMY -out server_sfdc.pass.key 2048

Step1.2 - openssl rsa -passin pass:PANTHER_UDEMY -in server_sfdc.pass.key -out server_sfdc.key

Step1.3 - openssl req -new -key server_sfdc.key -out server_sfdc.csr

    Once you will execute above command it will ask you some question and information
    
        Country Name : Provide any value for example : IN
        State or province Name [Some-State]: Karnatka
        Locality Name( eg. city)[] : Benguluru
        Organization Name (eg. company) : PantherSchools
        Organization Unit Name : PS
        Comman Name [] : You can keep it blank
        Email Address [] : amit.jwt_example@example.com

Step1.4 - openssl x509 -req -sha256 -days 365 -in server_sfdc.csr -signkey server_sfdc.key -out server_sfdc.crt

## Setup External Client App in Salesforce

Callback URL - http://localhost:1717/OauthRedirect

## Step2 - Get the JWT Assertion using Postman

Method: GET
URL - Any Valid Salesforce API URL (https://login.salesforce.com/services/oauth2/userinfo)

Before Request Script for PostMan -

```
const currentTimestamp = Math.floor(Date.now() / 1000);
const validityDuration = 3600; 
const expiryTimestamp = currentTimestamp + validityDuration;
const expiryDateTimeString = new Date(expiryTimestamp * 1000).toUTCString();
pm.collectionVariables.set("jwt_exp", expiryTimestamp);
pm.collectionVariables.set("jwt_expiry_date", expiryDateTimeString);
console.log("JWT Expiry Epoch:", expiryTimestamp);
```

JWT Header

```json
 {
    "alg":"RS256"
 }
```

JWT Assertion Payload

```json
{
  "iss": "3MVG9VTfpJmxg1yipdnPEKgkwnM_biD_GhIBtYrqVZiB8AzBuEBBDQUnMaUGujdBmET4zO0sg64DDN8F63rzn",
  "sub": "integration@pantherschools.com",
  "aud": "https://login.salesforce.com",
  "exp": "{{jwt_exp}}"
}
```

## Step3 - Get Access Token Using PostMan

Method: POST

URL: https://login.salesforce.com/services/oauth2/token

For Sandbox Use - https://login.salesforce.com/services/oauth2/token

Body Param

    grant_type : urn:ietf:params:oauth:grant-type:jwt-bearer
    assertion : USE JWT TOKEN created earlier

## Step4 - Get the Login User Info

Method - GET
URL - https://login.salesforce.com/services/oauth2/userinfo
For sandbox use - https://test.salesforce.com/services/oauth2/userinfo

Header Params: 
    Authorization: Bearer YOUR_ACCESS_TOKEN Generated from Previous Step