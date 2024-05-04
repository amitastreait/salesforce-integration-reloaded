/**
 * @description       : 
 * @author            : Amit Singh - PantherSchools
 * @group             : 
 * @last modified on  : 05-04-2024
 * @last modified by  : Amit Singh - PantherSchools
**/
public with sharing class PS_JWT {
    // PS_JWT.run();
    public static void run(){
        Auth.JWT jwt = new Auth.JWT();
        jwt.setSub('epic.58871712590567910@epic.th');
        jwt.setAud('https://login.salesforce.com'); 
        jwt.setIss('3MVG9OGq41FnYVsH1.oT0PkIJ35QxbbA7jiT3xfy5rblQ72OP7IBLZ_XV2RQz_AEPeoPQYTczFa28uZUhyY_3');
        System.debug(jwt.toJSONString());

        //Create the object that signs the JWT bearer token
        Auth.JWS jws = new Auth.JWS(jwt,'integrationcert');

        String tokenEndpoint ='https://login.salesforce.com/services/oauth2/token';

        Auth.JWTBearerTokenExchange bearer = new Auth.JWTBearerTokenExchange(tokenEndpoint, jws);

        //Get the access token
        String accessToken = bearer.getAccessToken();
        system.debug('Access Token--> \n '+accessToken);
        getUserInfo(accessToken);
    }

    public static void getUserInfo(String accessToken){
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://dhn000002vxjomao-dev-ed.develop.my.salesforce.com/services/oauth2/userinfo');
        req.setMethod('GET');
        req.setHeader('Authorization', 'Bearer '+accessToken);
        req.setHeader('Content-Type', 'application/json');
        Http http = new Http();
        HTTPResponse res = http.send(req);
        System.debug(res.getBody());
        String response = res.getBody();
    }
}