public with sharing class PS_PKCEAuthHelper {
    
    /**
     * code_challenge - SHA 256 of code_verifier and must be base64 Url encoded (Crypto)
     *  First Call
     * code_verifier - Random String - UUID Class ( System.UUID.getRandomString().toString() ); in Token Call 
     *  Second Call
     */

    /**
     * 1. Generate code_verifier 
     * 2. SHA-256 of code verifier
     * 3. baseUrlEndoc of SHA-256 of code verifier
     * 4. Custom Setting / Custom Object to store code_verifier & code_challenge, an Active__c
     * 5. Get the data (code_verifier) from Custom Setting / Custom Object
     * 6. Expire the code_verifier by setting Active__c checkbox to false
     */
    public static List<String> getDetails(){
        
        String code_verifier  = System.UUID.randomUUID().toString();
        Blob sha256           = Crypto.generateDigest('SHA-256', Blob.valueOf(code_verifier));
        String code_challenge = SFDC_BASE64_URLENCODE(sha256);
        
        System.debug('**** code_verifier **** \n  '+code_verifier);
        System.debug('**** code_challenge **** \n '+code_challenge);
        return new List<String>{code_verifier, code_challenge};
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

}