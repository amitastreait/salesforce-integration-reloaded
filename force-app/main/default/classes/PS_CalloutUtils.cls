public with sharing class PS_CalloutUtils {
    
    public static HttpRequest prepareRequest(String endPoint, String method, String body, String accept, String contentType){
        HttpRequest httpReq = new HttpRequest();
        httpReq.setEndpoint(endPoint);
        httpReq.setMethod(method);
        httpReq.setHeader('Content-Type', contentType);
        if(!String.isBlank(accept)){
            httpReq.setHeader('Accept',accept);
        }
        if(!String.isBlank(body)){
            httpReq.setBody(body);
        }
        return httpReq;
    }
}