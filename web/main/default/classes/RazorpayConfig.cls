/**
 * @description       : 
 * @author            : Amit Singh - PantherSchools
 * @group             : 
 * @last modified on  : 06-21-2024
 * @last modified by  : Amit Singh - PantherSchools
**/
public without sharing class RazorpayConfig {
    
    public static RazorpayConfig__mdt config(String developerName){
        return RazorpayConfig__mdt.getInstance(developerName);
    }

    @AuraEnabled
    public static List<Booking__c> verifySignature(String paymentId, String paymentLinkId, String referenceId, String status, String signature) {

        RazorpayConfig__mdt config = RazorpayConfig.config('Sandbox');

        Map<String, String> params = new Map<String, String>{
            'payment_id' => paymentId,
            'payment_link_id' => paymentLinkId,
            'payment_link_reference_id' => referenceId,
            'payment_link_status' => status
        };
        Boolean isValid = RazorpayUtils.validatePaymentVerification(params, signature, config.RazorpaySecret__c);
        
        if(!isValid){
            ErrorLog__c log = new Logger()
                .withComponentName('RazorpayConfig')
                .withErrorMessage('Invalid Signature!')
                .withEventName(System.Label.EventName)
                .withMethodName('verifySignature')
                .withDescription('Razorpay has send the user to callback page. After processing. Please check the payment before granting the ticket to attendee.')
                .withDateTime(System.now())
                .withStackTrace('RazorpayConfig.verifySignature')
                .withYear(System.today())
                .build();
            throw new AuraHandledException('Invalid Signature!');
        }
        List<Booking__c> bookingList = BookingService.listBookings(referenceId);
        
        for(Booking__c booking : bookingList){
            booking.Status__c        = isValid ? 'Success' : 'Error';
            booking.PaymentID__c     = paymentId;
            booking.PaymentStatus__c = status.toUpperCase();
            booking.SendEmail__c     = True;
        }
        try {
            update as System bookingList;
        } catch (System.Exception ex) {
            ErrorLog__c log = new Logger()
                .withComponentName('RazorpayConfig')
                .withErrorMessage(ex.getMessage())
                .withEventName(System.Label.EventName)
                .withMethodName('verifySignature')
                .withDescription('Razorpay has send the user to callback page. After processing. Please check the payment before granting the ticket to attendee. Reference ID: '+referenceId)
                .withDateTime(System.now())
                .withStackTrace(ex.getStackTraceString())
                .withYear(System.today())
                .build();
            throw new AuraHandledException('Error While updating the Booking Records!');
        }
        return bookingList;
    }
}