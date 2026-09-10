public class PostGridAddressVerification {

    public static final String POSTGRID_BASE_URL = 'https://api.postgrid.com';
    public static void verifyStructuredAddress(String line1, String line2, String city, String state, String postalCode, String country, String recipient){
        
        HttpRequest request = new HttpRequest();
        // callout:PostGridAPI/v1/addver/verifications/batch
        request.setEndpoint('callout:PostGridAPI'+'/addver/verifications?geocode=false');
        request.setMethod('POST');
        //request.setheader('x-api-key',System.Label.PostGridAPIKey);
        request.setheader('Content-Type','application/x-www-form-urlencoded');
        
        /* String requestBody =
            'address[line1]=' + line1 +
            '&address[line2]=' + line2 +
            '&address[city]=' + city +
            '&address[provinceOrState]=' + state +
            '&address[postalOrZip]=' + postalCode +
            '&address[country]=' + country +
            '&address[recipient]=' + recipient;
        */
        // You can use Apex text blocks (''') with .template() like this: 
        Map<String, Object> valueMap = new Map<String, Object>{
            'addressline1'      => line1,
            'line2'             => line2,
            'city'              => city,
            'provinceOrState'   => state,
            'postalOrZip'       => postalCode,
            'country'           => country,
            'recipient'         => recipient
        };
        
        String requestBody = '''
            address[line1]=${addressline1}&
            address[line2]=${line2}&
            address[city]=${city}&
            address[provinceOrState]=${provinceOrState}&
            address[postalOrZip]=${postalOrZip}&
            address[country]=${country}&
            address[recipient]=${recipient}
        '''.replace('\n', '').template(valueMap);
        
        System.debug(requestBody.trim());
        request.setBody(requestBody.trim());
        HttpResponse response = new HttpResponse();
        Http ht = new Http();
        try{
            response = ht.send(request);
            Integer statusCode = response.getStatusCode();
            String responseBody = response.getBody();
            System.debug('Response Body '+ responseBody);
            if(statusCode == 200 || statusCode == 201){
                
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