public with sharing class PS_ZendeskTicketUtils {

    /*
    PS_ZendeskTicketUtils.TicektWrapper wrapper = new PS_ZendeskTicketUtils.TicektWrapper();
    wrapper.body = 'Dynamic body';
    wrapper.subject = 'Testing from Salesforce Apex!';
    wrapper.priority = 'urgent';
    wrapper.name = 'Amit Singh';
    wrapper.email = 'asingh@example.org';
    PS_ZendeskTicketUtils.createTicket(wrapper);
    */

    public class TicektWrapper {
        public String body;
        public String subject;
        public String priority;
        public String name;
        public String email;
    }
    
    public static void createTicket(TicektWrapper wrapper){ // Enhance it
        /*
            Case --> 
                Case is Created in Salesforce
                    Zendesk
                Salesforce Case should be updated with the Zendesk ticket Id
        */
        String header = System.Label.Zendesk_Username +':'+System.Label.Zendesk_APITOKEN;
        Blob headerValue = Blob.valueOf(header);

        String requestBody = '{'+
		'    "ticket": {'+
		'        "comment": {'+
		'            "body": "'+wrapper.body+'"'+
		'        },'+
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

        HttpRequest httpReq = new HttpRequest();
        httpReq.setEndpoint('https://pantherschools.zendesk.com/api/v2/tickets');
        httpReq.setMethod('POST');
        httpReq.setBody(requestBody); // String --> XML/JSON
        httpReq.setHeader('Content-Type','application/json');
        httpReq.setHeader('Accept','application/json');
        httpReq.setHeader('Authorization','Basic '+EncodingUtil.base64Encode( headerValue ) );

        Http http = new Http();
        try{
            HttpResponse httpRes = http.send(httpReq);
            if(httpRes.getStatusCode() == 201){
                System.debug('SUCCESS \n '+httpRes.getBody());
                // Success
            } else {
                // 400
                System.debug('ERROR \n '+ httpRes.getBody());
                // error
            }
        }catch(System.CalloutException ex){
            //
        }catch(System.Exception ex){

        }
    }
}