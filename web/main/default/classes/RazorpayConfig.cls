/**
 * @description       : 
 * @author            : Amit Singh - PantherSchools
 * @group             : 
 * @last modified on  : 06-18-2024
 * @last modified by  : Amit Singh - PantherSchools
**/
public with sharing class RazorpayConfig {
    
    public static RazorpayConfig__mdt config(String developerName){
        return RazorpayConfig__mdt.getInstance(developerName);
    }

    @AuraEnabled(cacheable=true)
    public static Boolean verifySignature(String paymentId, String linkId, String signature) {

        String payload = 'order_ONu5XJO20vDwxf' + '|' + paymentId;
        System.debug(payload);

        RazorpayConfig__mdt config = RazorpayConfig.config('Sandbox');
        System.debug(config.RazorpaySecret__c);

        Blob privateKey = Blob.valueOf(config.RazorpaySecret__c);
        Blob input = Blob.valueOf(payload);
        Blob mac = Crypto.generateMac('HmacSHA256', input, privateKey);

        String expectedSignature = EncodingUtil.convertToHex(mac);
        System.debug(' expectedSignature '+ expectedSignature);
        System.debug(' signature '+ signature);
        return expectedSignature == signature;
    }
}