/**
 * @description       : 
 * @author            : Amit Singh - PantherSchools
 * @group             : 
 * @last modified on  : 06-17-2024
 * @last modified by  : Amit Singh - PantherSchools
**/
public without sharing class HTTPUtil {
    
    /**
     * Makes an HTTP POST request to the specified endpoint.
     *
     * @param endpoint The URL of the web service endpoint.
     * @param requestBody The body of the POST request.
     * @return HTTPResponse The response from the web service.
     */
    public static HTTPResponse call(String endpoint, String requestBody, String method, Map<String, String> headers, String contentType) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setMethod(method);
        request.setHeader('Content-Type', contentType);
        if(!String.isBlank(requestBody)){
            request.setBody(requestBody);
        }

        if(headers !=null && headers.size() > 0){
            for(String key : headers.keySet()){
                request.setHeader(key, headers.get(key));
            }
        }
        
        try {
            HTTPResponse response = http.send(request);
            return response;
        } catch (System.Exception ex) {
            System.debug('Callout error: ' + ex);
            return null;
        }
    }
}
