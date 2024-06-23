/**
 * @description       : 
 * @author            : Amit Singh - PantherSchools
 * @group             : 
 * @last modified on  : 06-23-2024
 * @last modified by  : Amit Singh - PantherSchools
**/
public class JWT {
    
    private static final String JWT_HEADER = '{"alg":"RS256"}';
    
    public static String retrievePrivateKey(){
        ContentVersion base64Content = [SELECT VersionData FROM ContentVersion WHERE Title = 'server.key' ORDER BY Title LIMIT 1];
        String keyContents = base64Content.VersionData.toString();
        keyContents = keyContents.replace('-----BEGIN PRIVATE KEY-----', '');
        keyContents = keyContents.replace('-----END PRIVATE KEY-----', '');
        keyContents = keyContents.replace('\n', '');
        return keyContents;
    }
    // JWT.run();
    public static void run(){
        
        DateTime rightNow = System.now(); // Current Date Time
        rightNow    = rightNow.addMinutes(3);
        Long expiry = rightNow.getTime(); // Unix TimeStamp
        
        String CLAIMS = '{'+
            '"iss": "3MVG9OGq41FnYVsH1",'+
            '"sub": "yourusername@gmail.com",'+
            '"aud": "https://login.salesforce.com",'+
            '"exp": '+expiry+
        '}';
        
        String base64UrlJWTHeader = SFDC_BASE64_URLENCODE( Blob.valueOf(JWT_HEADER) );
        String base64UrlJWTClaims = SFDC_BASE64_URLENCODE( Blob.valueOf(CLAIMS) );
        
        String combinedHeaderClaim = base64UrlJWTHeader+'.'+base64UrlJWTClaims;
        System.debug('combinedHeaderClaim \n '+combinedHeaderClaim);
        
        String jwtAssertion = shaSignPrivateKey(combinedHeaderClaim);
        System.debug('jwtstr \n '+ jwtAssertion);
        
        getAccessToken(jwtAssertion);
    }
    
    public static String shaSignPrivateKey(String combinedHeaderClaim){
        // base64Decode the Private key Content
        Blob privateKey = EncodingUtil.base64Decode( retrievePrivateKey() );
        // Sign the Private Key using the rsa-sha256 Algorithm
        Blob signature  = Crypto.sign('rsa-sha256', Blob.valueOf(combinedHeaderClaim), privateKey);
        // Add the signature to the assertion
        combinedHeaderClaim += '.' + SFDC_BASE64_URLENCODE(signature);  
        return combinedHeaderClaim;
    }
    
    private static String SFDC_BASE64_URLENCODE(Blob input){
        if(input == null) {
            return null;
        }
        return EncodingUtil.base64Encode(input)
            .replace('/', '_')
            .replace('+', '-')
            .replaceAll('=+$', '');
    }
    
    private static void getAccessToken(String assertionValue){
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://login.salesforce.com/services/oauth2/token');
        String requestBody = 'grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer&assertion='+assertionValue;
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.setBody(requestBody);
        Http http = new Http();
        HTTPResponse res = http.send(req);
        System.debug(res.getBody());
        String response = res.getBody();
    }
}