/**
 * @description       : 
 * @author            : Amit Singh - PantherSchools
 * @group             : 
 * @last modified on  : 06-18-2024
 * @last modified by  : Amit Singh - PantherSchools
**/
public without sharing class RazorpayPaymentLinkService {

    @AuraEnabled
    public static String process(Map<String, Object> customerInfo, String bookingInfo){
        try {

            RazorpayPaymentLinkHelper input = new RazorpayPaymentLinkHelper();
            input.customer          = new RazorpayPaymentLinkHelper.customer();
            input.customer.contact  = (String)customerInfo.get('Phone');
            input.customer.email    = (String)customerInfo.get('Email');
            input.customer.name     = (String)customerInfo.get('Name');
            input.callback_url      = (String)customerInfo.get('callback_url');
            input.amount            = (Decimal)customerInfo.get('amount');
            input.reference_id      = UUID.randomUUID().toString();

            Map<String, Object> responseMap = createPaymentLink(input);

            String payLink = (String)responseMap.get('short_url');

            Contact customerRecord = new Contact();
            customerRecord.LastName = (String)customerInfo.get('Name');
            customerRecord.Phone = (String)customerInfo.get('Phone');
            customerRecord.Email = (String)customerInfo.get('Email');

            insert as system customerRecord;

            List<BookingWrapper> bookings = (List<BookingWrapper>)System.JSON.deserialize(bookingInfo, List<BookingWrapper>.class);
            
            List<Booking__c> bookingRecords = new List<Booking__c>();
            for (BookingWrapper item : bookings) {
                Booking__c booking = new Booking__c(
                    Customer__c    = customerRecord.Id,
                    Email__c       = item.Email,
                    Name           = item.Name,
                    Phone__c       = item.Phone,
                    Status__c      = 'Created',
                    Company__c     = item.Organization,
                    Size__c        = item.Size,
                    BookingCode__c = 'MD-'+generateRandomString(10),
                    ReferenceID__c = (String)responseMap.get('reference_id'),
                    Amount__c      = ((Decimal)responseMap.get('amount')/100),
                    PaymentUrl__c  = payLink,
                    PaymentId__c   = (String)responseMap.get('id')
                );
                bookingRecords.add(booking);
            }

            insert as system bookingRecords;

            return payLink;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    public static Map<String, Object> createPaymentLink(RazorpayPaymentLinkHelper inputWrapper){
        HttpResponse httpRes = RazorpayPaymentLinkHelper.initiate(inputWrapper);
        if(httpRes != null && ( httpRes.getStatusCode() == 200 || httpRes.getStatusCode() == 201 ) ){
            Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(httpRes.getBody());
            return responseMap;
        }else {
            throw new AuraHandledException('Unknown error occured while creating the Payment Link');
        }
    }

    public static String generateRandomString(Integer len) {
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        String randStr = '';
        while (randStr.length() < len) {
           Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
           randStr += chars.substring(idx, idx+1);
        }
        return randStr; 
    }

    public class BookingWrapper {
        public String Size;
		public String Organization;
		public String Phone;
		public String Email;
		public String Name;
    }
}