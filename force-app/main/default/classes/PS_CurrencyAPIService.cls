public with sharing class PS_CurrencyAPIService {
    
    public static void getExchangeRates(){
        /* Callouts Only */
        /* Step1 - Prepare the Request */
        HttpRequest httpReq = new HttpRequest();
        /* Step1.1 - Send the Endpoint */
        httpReq.setEndPoint('https://open.er-api.com/v6/latest/USD');

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
            String responseBody = httpRes.getBody();
            Integer statusCode  = httpRes.getStatusCode();
            String status = httpRes.getStatus();
            System.System.debug('The Response from Currency API - '+ status );
            System.System.debug('The Response from Currency API - '+ responseBody );
            System.System.debug('The Response from Currency API - '+ statusCode );
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