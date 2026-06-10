@RestResource(urlMapping='/quickbooks/webhooks/*')
global class VerifySignatureExample {
    private static final String SIGNATURE = 'intuit-signature';
    private static final String ALGORITHM = 'HmacSHA256';

    @HttpPost
    global static void listenToWebhook() {
        RestRequest req = RestContext.request;
        String jsonBody = req.requestBody.toString();
        System.debug('Received QuickBooks webhook: ' + jsonBody);
        Map<String, String> headers = req.headers;
        String webhookSecret = '3b0557fe-7503-494e-9b6f-a55fa0502bca';
        VerifySignatureExample verifier = new VerifySignatureExample();
        if (!verifier.isRequestValid(headers, jsonBody, webhookSecret)) {
            System.debug('Invalid signature for QuickBooks webhook');
            RestContext.response.statusCode = 401;
            RestContext.response.responseBody = Blob.valueOf('Unauthorized: Invalid signature');
            return;
        }
        System.debug('Signature verified for QuickBooks webhook');
        try {

            Map<String, Object> orderData = (Map<String, Object>) JSON.deserializeUntyped(jsonBody);
            // Return success response
            RestContext.response.statusCode = 200;
            RestContext.response.responseBody = Blob.valueOf('{"status":"success"}');
            
        } catch (Exception e) {
            // Log error and return error response
            System.debug('Error processing QuickBooks webhook: ' + e.getMessage());
            RestContext.response.statusCode = 500;
            RestContext.response.responseBody = Blob.valueOf('{"status":"error","message":"' + e.getMessage() + '"}');
        }
    }
    
    public Boolean isRequestValid(Map<String, String> headers, String payload, String verifier) {
        String signature = headers.get(SIGNATURE);
        if (signature == null) {
            return false;
        }
        
        try {
            Blob verifierBlob = Blob.valueOf(verifier);
            Blob payloadBlob = Blob.valueOf(payload);
            Blob hash = Crypto.generateMac(ALGORITHM, payloadBlob, verifierBlob);
            String encodedHash = EncodingUtil.base64Encode(hash);
            return encodedHash.equals(signature);
        } catch (Exception e) {
            return false;
        }
    }
}