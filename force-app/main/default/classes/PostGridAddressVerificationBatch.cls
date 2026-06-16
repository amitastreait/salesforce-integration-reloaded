public class PostGridAddressVerificationBatch implements Database.Batchable<sObject>, Database.AllowsCallouts {

    public Database.QueryLocator start(Database.BatchableContext batchContext){
        return Database.getQueryLocator('''
               SELECT  Id, Name, BillingStreet, BillingCity, BillingState,
                       BillingPostalCode, BillingCountry, ShippingStreet, ShippingCity, ShippingState,
                       ShippingPostalCode, ShippingCountry
               FROM Account
               WHERE CreatedDate = TODAY
               AND (AddressVerificationStatus__c = 'FAILED' OR AddressVerificationStatus__c = NULL)
        ''');
    }
    public void finish(Database.BatchableContext batchContext){
        
    }
    public void execute(Database.BatchableContext batchContext, List<Account> accountList){
        
        List<AddressVerifyRequest.Addresses> addresses = new List<AddressVerifyRequest.Addresses>();
        for(Account acc: accountList){
            AddressVerifyRequest.Addresses address = new AddressVerifyRequest.Addresses();
            address.line1 			= acc.BillingStreet;
            address.city 			= acc.BillingCity;
            address.country 		= acc.BillingCountry;
            address.postalOrZip 	= acc.BillingPostalCode;
            address.provinceOrState = acc.BillingState;
            addresses.add(address);
        }
        
        AddressVerifyRequest requestBody = new AddressVerifyRequest();
        requestBody.addresses = addresses;
        
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://api.postgrid.com/v1/addver/verifications/batch');
        request.setMethod('POST');
        request.setheader('x-api-key',System.Label.PostGridAPIKey);
        request.setheader('Content-Type','application/json');
        
        System.debug(System.JSON.serializePretty(requestBody));
        
        request.setBody( System.JSON.serializePretty(requestBody) );
        
        HttpResponse response = new HttpResponse();
        Http ht = new Http();
        try{
            response = ht.send(request);
            Integer statusCode = response.getStatusCode();
            String responseBody = response.getBody();
            System.debug('Response Body '+ responseBody);
            if(statusCode == 200 || statusCode == 201){
                // success
                AddressBatchWrapper wrapper = (AddressBatchWrapper)System.JSON.deserialize(responseBody, AddressBatchWrapper.class);
                List<AddressBatchWrapper.Results> results = wrapper.data?.results;
                for(Integer i=0; i < results.size(); i++){
                    AddressBatchWrapper.Results result = results.get(i);
                    Account acc = accountList.get(i);
                    acc.AddressVerificationStatus__c = result?.verifiedAddress?.status?.toUpperCase(); //FAILED, CORRECTED, SUCCESS
                    acc.AddressVerificationError__c = System.JSON.serializePretty( result?.verifiedAddress?.errors );
                    acc.BillingCity = result?.verifiedAddress?.city;
                }
                /** Update Account Record **/
                update accountList;
            } else {
                // error
            }
        }catch(System.CalloutException ex){
            
            System.debug('Line Number '+ ex.getLineNumber());
            System.debug('Cause '+ ex.getCause());
            System.debug('Message '+ ex.getMessage());
            System.debug('StackTraceString '+ ex.getStackTraceString());
            System.debug('TypeName '+ ex.getTypeName());
            
        }catch(System.Exception ex){
            
            System.debug('Line Number '+ ex.getLineNumber());
            System.debug('Cause '+ ex.getCause());
            System.debug('Message '+ ex.getMessage());
            System.debug('StackTraceString '+ ex.getStackTraceString());
            System.debug('TypeName '+ ex.getTypeName());
            
        }
        
    }
}