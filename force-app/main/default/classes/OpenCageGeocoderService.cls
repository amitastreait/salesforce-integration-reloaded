public with sharing class OpenCageGeocoderService {
    
    public static void reverseGeoCoding(String accountId){ // argument
        /* Step0 - Get The Lattitude and Longitude for given account */
        Account accRecord = [SELECT Id, Location__Latitude__s, Location__Longitude__s 
                            FROM 
                                Account 
                            WHERE 
                                Id =: accountId 
                                AND Location__Latitude__s != null
                                AND Location__Longitude__s != null
                            LIMIT 1
                        ];
        /* Step0.1 - Prepare the Query Params */
        String queryParams = accRecord.Location__Latitude__s+','+accRecord.Location__Longitude__s; // As Per API Document
        System.debug(queryParams);

        // URLEncode of that complete Query parameter
        // EncodingUtil.urlEncode();

        /* Callouts Only */
        /* Step1 - Prepare the Request */
        HttpRequest httpReq = new HttpRequest();
        /* Step1.1 - Send the Endpoint */
        httpReq.setEndPoint(System.Label.OPENCAGE_API_URL+'?key='
            +System.Label.OPENCAGE_API_KEY+'&q='+queryParams+'&pretty=1');

        /* Step1.2 - Set the Headers */
        httpReq.setHeader('Content-Type', 'application/json');
        httpReq.setHeader('Accept', 'application/json'); // JSON, XML, Text, HTML

        /* Step1.3 - Set the Method */
        httpReq.setMethod('GET'); // GET, POST, PUT, PATCH, DELETE

        /* Step2 - Send the Request */
        Http htt = new Http();
        try {
            HttpResponse httpRes = htt.send(httpReq);
            /* Step3 - Print the Information */
            /*
                getStatus(), getStatusCode()
                getBody() getXmlStreamReader() --> SOAP, getBodyAsBlob()
            */
            String responseBody = httpRes.getBody(); // String
            Integer statusCode  = httpRes.getStatusCode();
            // GET, 200
            if(statusCode == 200){
                // main logic
                // JSON Class inside System Namespace
                // dereialize, dereializeUnTyped, dereializeStrict 
                
                OpenCageReverseResponseWrapper wrapper = (OpenCageReverseResponseWrapper)System.JSON.deserialize(responseBody, OpenCageReverseResponseWrapper.class);
                if(wrapper?.results?.size() > 0){
                    // The Compiler
                    // The Run Time Environment ( Machine )
                    // wrapper?.results?.size() > 0
                        // if wrapper is not null
                            // Yes - 
                                // wrapper.results is not null
                                    // YES -
                                        // wrapper.results.size()
                                            // YES
                    OpenCageReverseResponseWrapper.results rslt = wrapper.results.get(0);
                    // Update Account Record
                    accRecord.BillingStreet = rslt?.components?.road;
                    accRecord.BillingCity = rslt?.components?.city;
                    accRecord.BillingState = rslt?.components?.state;
                    accRecord.BillingPostalCode = rslt?.components?.postcode;
                    accRecord.BillingCountry = rslt?.components?.country;

                    accRecord.ShippingStreet = rslt?.components?.road;
                    accRecord.ShippingCity = rslt?.components?.city;
                    accRecord.ShippingState = rslt?.components?.state;
                    accRecord.ShippingPostalCode = rslt?.components?.postcode;
                    accRecord.ShippingCountry = rslt?.components?.country;

                    update accRecord;
                }
            }else{
                // error handling code...
            }
            
        }catch(System.CalloutException calloutEx){
            System.debug('System.CalloutException .... '+ calloutEx.getStackTraceString());
            if(String.valueOf(calloutEx).startsWith('System.CalloutException: Unauthorized endpoint')){
                // Remote Site missing Error - 
                System.debug(' CalloutException ');
            }
        }catch(System.Exception ex){
            System.debug('Exception Executed ... '+ ex.getStackTraceString());
            if(String.valueOf(ex).startsWith('System.CalloutException: Unauthorized endpoint')){
                // Remote Site missing Error - 
                System.debug(' Executed ');
            }
        }
    }
}