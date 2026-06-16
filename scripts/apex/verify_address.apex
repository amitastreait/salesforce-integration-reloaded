public static void verifyStructuredAddress(String line1, String line2, String city, String state, String postalCode, String country, String recipient) {
    HttpRequest req = new HttpRequest();
    req.setEndpoint(POSTGRID_BASE_URL+'/v1/addver/verifications?includeDetails=false&geocode=false');
    req.setMethod('POST');
    req.setHeader('x-api-key', System.Label.PostGridAPIKey);
    req.setHeader('Content-Type', 'application/x-www-form-urlencoded');

    // You can use Apex text blocks (''') with .template() like this: 
    Map<String, Object> valueMap = new Map<String, Object>{
        'line1'             => line1,
        'line2'             => line2,
        'city'              => city,
        'provinceOrState'   => state,
        'postalOrZip'       => postalCode,
        'country'           => country,
        'recipient'         => recipient
    };

    String requestBody = '''
        address[line1]=${line1}&
        address[line2]=${line2}&
        address[city]=${city}&
        address[provinceOrState]=${provinceOrState}&
        address[postalOrZip]=${postalOrZip}&
        address[country]=${country}&
        address[recipient]=${recipient}
    '''.replace('\n', '').template(valueMap);

    req.setBody(requestBody);

    try{
        HttpResponse response = (new Http()).send(req);
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


