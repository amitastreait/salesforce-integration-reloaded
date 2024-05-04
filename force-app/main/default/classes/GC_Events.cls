/**
 * @description       : 
 * @author            : Amit Singh - PantherSchools
 * @group             : 
 * @last modified on  : 04-25-2024
 * @last modified by  : Amit Singh - PantherSchools
**/
public with sharing class GC_Events {
    public static void createGoogleEvent(String requestBody){
        
        Google_Config__mdt config = Google_Config__mdt.getInstance(System.Label.PS_GoogleTokenLabel);
        
        if(config == null || ( config != null && String.isBlank(config.access_token__c) ) ){
            return;
        }
        
        String errorMessage = '';
        String endPoint = config.Event_Url__c;
        endPoint = endPoint.replace('{calendarId}', 'your_email@gmail.com');
        
        String accessToken = config.access_token__c;
        
        Boolean isValid = Assignment_GoogleAPITokenUtils.isValid(config);
        Map<String, Object> refreshTokenMap = new Map<String, Object>();
        
        if(!isValid){
            refreshTokenMap = Assignment_GoogleAPITokenUtils.refreshToken(config);
            accessToken     = (String)refreshTokenMap.get('access_token__c');
        }
        
        Http http = new Http();
        HttpRequest httpReq   = prepareRequest('callout:Google'+endPoint, accessToken, 'POST', requestBody,'application/json');
        HttpResponse response = new HttpResponse();
        
        try{
            response = http.send(httpReq);
            if( response.getStatusCode() == 200 || response.getStatusCode() == 201 ){
                String body = response.getBody();
                System.debug(' Google Event Response '+body);
                if(!isValid){
                    String fullName = 'Google_Config.'+System.Label.PS_GoogleTokenLabel;
                    CreateUpdateMetadataUtils.createUpdateMetadata(fullName, System.Label.PS_GoogleTokenLabel, refreshTokenMap);
                }

            }else{
                errorMessage = 'Unexpected Error while communicating with API. '
                    +'Status '+response.getStatus()+' and Status Code '+response.getStatuscode();
                System.debug(System.LoggingLevel.DEBUG, 'Exeception Executed '+response.getBody());
            }
        }catch(System.Exception e){
            if(String.valueOf(e.getMessage()).startsWith('Unauthorized endpoint')){
                errorMessage = 'Unauthorize endpoint: An Administer must go to Setup -> Administer -> Security Control ->'
                    +' Remote Site Setting and add '+' '+ endPoint +' Endpoint';
            }else{
                errorMessage = 'Unexpected Error while communicating with API. '
                    +'Status '+response.getStatus()+' and Status Code '+response.getStatuscode();
            }
            System.debug(System.LoggingLevel.DEBUG, 'Exeception Executed '+errorMessage);
        } 
    }
    
    public static void getAllGoogleEvent(){
        
        String errorMessage = '';

        Http http = new Http();
        HttpRequest httpReq   = prepareRequest('callout:Google/calendar/v3/calendars/your_email@gmail.com/events',
                                               '', 'GET', '','application/json');
        HttpResponse response = new HttpResponse();
        
        try{
            response = http.send(httpReq);
            if( response.getStatusCode() == 200 || response.getStatusCode() == 201 ){
                String body = response.getBody();
                System.debug(' Google Event Response '+body);
            }else{
                errorMessage = 'Unexpected Error while communicating with API. '
                    +'Status '+response.getStatus()+' and Status Code '+response.getStatuscode();
                System.debug(System.LoggingLevel.DEBUG, 'Exeception Executed '+response.getBody());
            }
        }catch(System.Exception e){
            if(String.valueOf(e.getMessage()).startsWith('Unauthorized endpoint')){
                errorMessage = 'Unauthorize endpoint: An Administer must go to Setup -> Administer -> Security Control ->'
                    +' Remote Site Setting and add  Endpoint';
            }else{
                errorMessage = 'Unexpected Error while communicating with API. '
                    +'Status '+response.getStatus()+' and Status Code '+response.getStatuscode();
            }
            System.debug(System.LoggingLevel.DEBUG, 'Exeception Executed '+errorMessage);
        } 
    }

    public static HttpRequest prepareRequest(String endPoint, String accessToken, String method, String requestBody,
                                            String contentType){
        
        httpRequest httpReq = new httpRequest();
        httpReq.setMethod(method);
        httpReq.setEndpoint(endPoint);
        httpReq.setHeader('Content-Type', contentType);
        httpReq.setHeader('Accept', 'application/json');
        if(!String.isBlank(accessToken)){
            httpReq.setHeader('Authorization', 'Bearer '+accessToken);
        }
        if(!String.isBlank(requestBody)){
            httpReq.setBody(requestBody);
        }
        return httpReq;
        
    }
}