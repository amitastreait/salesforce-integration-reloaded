public with sharing class Assignment_ZendeskUtils {

    public class TicektWrapper {
        public String body;
        public String subject;
        public String priority;
        public String name;
        public String email;
        public String agentId;
    }
    
    public static HttpResponse createTicket(TicektWrapper wrapper){
        
        String header = System.Label.Zendesk_Username +':'+System.Label.Zendesk_APITOKEN;
        Blob headerValue = Blob.valueOf(header);

        String requestBody = '{'+
		'    "ticket": {'+
		'        "comment": {'+
		'            "body": "'+wrapper.body+'"'+
		'        },'+
        '        "assignee_id": '+wrapper.agentId+', '+
		'        "priority": "'+wrapper.priority+'",'+
		'        "subject": "'+wrapper.subject+'",'+
		'        "requester": {'+
		'            "locale_id": 8,'+
		'            "name": "'+wrapper.name+'",'+
		'            "email": "'+wrapper.email+'"'+
		'        }'+
		'    }'+
		'}';

        System.debug('requestBody \n '+ requestBody);
        String endpoint = 'https://pantherschoolshelp.zendesk.com/api/v2/tickets';
        
        HttpRequest httpReq = PS_CalloutUtils.prepareRequest(endpoint,'POST',requestBody,'application/json', 'application/json');
        httpReq.setHeader('Authorization','Basic '+EncodingUtil.base64Encode( headerValue ) );

        Http http = new Http();
        try{
            HttpResponse httpRes = http.send(httpReq);
            return httpRes;
        }catch(System.CalloutException ex){
            System.debug(ex.getStackTraceString());
        }catch(System.Exception ex){
            System.debug(ex.getStackTraceString());
        }
        return null;
    }
}