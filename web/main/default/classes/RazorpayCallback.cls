/**
 * @description       : 
 * @author            : Amit Singh - PantherSchools
 * @group             : 
 * @last modified on  : 06-17-2024
 * @last modified by  : Amit Singh - PantherSchools
**/
@RestResource(urlMapping='/razorpayCallback/*')
global with sharing class RazorpayCallback {
    @HttpGet
    global static void handleCallback() {
        RestRequest req = RestContext.request;
        Map<String, String> params = req.params;
        
        String razorpayPaymentId = params.get('razorpay_payment_id');
        String razorpayPaymentLinkId = params.get('razorpay_payment_link_id');
        String razorpayPaymentLinkReferenceId = params.get('razorpay_payment_link_reference_id');
        String razorpayPaymentLinkStatus = params.get('razorpay_payment_link_status');
        String razorpaySignature = params.get('razorpay_signature');
        
        // Fetch the secret key from custom metadata
        RazorpayConfig__mdt settings = RazorpayConfig.config('Sandbox');
        String secret = settings.RazorpaySecret__c;
        
        if (verifySignature(razorpayPaymentId, razorpayPaymentLinkId, razorpaySignature, secret)) {
            // Handle successful verification
            System.debug('Signature verified successfully.');
            // Implement your logic here (e.g., update payment status)
            updatePaymentStatus(razorpayPaymentId, razorpayPaymentLinkId, razorpayPaymentLinkStatus, true);
        } else {
            // Handle verification failure
            System.debug('Signature verification failed.');
            // Implement your logic here (e.g., log an error)
            updatePaymentStatus(razorpayPaymentId, razorpayPaymentLinkId, razorpayPaymentLinkStatus, false);
        }
    }
    
    private static Boolean verifySignature(String paymentId, String linkId, String signature, String secret) {
        String payload = paymentId + '|' + linkId;
        Blob mac = Crypto.generateMac('HmacSHA256', Blob.valueOf(payload), Blob.valueOf(secret));
        String expectedSignature = EncodingUtil.convertToHex(mac);
        return expectedSignature.equalsIgnoreCase(signature);
    }

    private static void updatePaymentStatus(String paymentId, String linkId, String status, Boolean isSuccess) {
        // Your logic to update payment status in Salesforce
        // This can involve updating a custom object, logging the result, etc.
    }
}