public class LinkedInService {
    
    public static void userInfo(){
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:LinkedIn'+'/v2/userinfo');
        request.setMethod('GET');
        request.setheader('Content-Type','application/json');
        HttpResponse response = new HttpResponse();
        Http ht = new Http();
        try{
            response = ht.send(request);
            System.debug(response.getBody());
        }catch(System.CalloutException ex){
            debug(ex);
        }catch(System.Exception ex){
            debug(ex);
        }
    }

    public static void createPost(){
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:LinkedIn'+'/v2/ugcPosts');
        request.setMethod('POST');
        request.setheader('Content-Type','application/json');
        
        Map<String, Object> valueMap = new Map<String, Object>{
        	'linkedin_sub'  => System.Label.LinkedInSubject
        };
        
        String requestBody = '''
            {
                "author": "urn:li:person:${linkedin_sub}",
                "lifecycleState": "PUBLISHED",
                "specificContent": {
                    "com.linkedin.ugc.ShareContent": { 
                        "shareCommentary": {
                            "text": "🎯 If you can see this post, congratulations, my first LinkedIn API integration was successful! This post was published programmatically from Apex Class using the LinkedIn REST API."
                        },
                        "shareMediaCategory": "NONE"
                    }
                },
                "visibility": {
                    "com.linkedin.ugc.MemberNetworkVisibility": "PUBLIC"
                }
            }
        '''.template(valueMap);
            
        System.debug(requestBody.trim());
        request.setBody(requestBody.trim());
        HttpResponse response = new HttpResponse();
        Http ht = new Http();
        try{
            response = ht.send(request);
            System.debug(response.getBody());
        }catch(System.CalloutException ex){
            debug(ex);
        }catch(System.Exception ex){
            debug(ex);
        }
    }
    public static void debug(System.Exception ex){
        System.debug('Line Number '+ ex.getLineNumber());
        System.debug('Cause '+ ex.getCause());
        System.debug('Message '+ ex.getMessage());
        System.debug('StackTraceString '+ ex.getStackTraceString());
        System.debug('TypeName '+ ex.getTypeName());
    }
}