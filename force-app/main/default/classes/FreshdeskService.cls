public class FreshdeskService {
    public static String ENDPOINT = 'https://pantherschools.freshdesk.com';
    
    public static void listAllContacts(){
        Blob blobValue = Blob.valueOf(System.Label.FreshDeskAPIKey +':'+'X');
        HttpRequest httpReq = new HttpRequest();
        httpReq.setHeader('Content-Type', 'application/json');
        httpReq.setHeader('Authorization', 'Basic '+EncodingUtil.base64Encode(blobValue) );
        
        /** Set the Endpoint Details **/
        httpReq.setEndpoint(ENDPOINT+'/api/v2/contacts');
        httpReq.setMethod('GET');
        
        try{
            HttpResponse response = (new Http()).send(httpReq);
            System.debug( response.getBody() );
            Integer statusCode = response.getStatusCode();
            if(statusCode == 200 || statusCode == 201){
              List<FreshdeskContactWrapper> listContacts = (List<FreshdeskContactWrapper>)System.JSON.deserialize(response.getBody(), List<FreshdeskContactWrapper>.class );
                List<Contact> contactList = new List<Contact>();
                for(FreshdeskContactWrapper con: listContacts){
                    String lastName = con.last_name ?? con.first_name;
                    If(String.isBlank(lastName)){
                        lastName = 'No Last Name';
                    }
                    Contact contactRec = new Contact(
                    	LastName = lastName,
                        FirstName = con.first_name,
                        Email = con.email,
                        Phone = con.phone,
                        Title = con.job_title,
                        Freshdesk_Id__c = con.id
                    );
                    contactList.add(contactRec);
                }
                upsert contactList Freshdesk_Id__c;
            } else {
                System.debug('Error Occured with Status Code '+statusCode );
            }
        } catch (System.CalloutException ex) {
            System.debug('Line Number '+ ex.getLineNumber());
            System.debug('Cause '+ ex.getCause());
            System.debug('Message '+ ex.getMessage());
            System.debug('StackTraceString '+ ex.getStackTraceString());
            System.debug('TypeName '+ ex.getTypeName());
        } catch (System.Exception ex) {
            System.debug('Line Number '+ ex.getLineNumber());
            System.debug('Cause '+ ex.getCause());
            System.debug('Message '+ ex.getMessage());
            System.debug('StackTraceString '+ ex.getStackTraceString());
            System.debug('TypeName '+ ex.getTypeName());
        }
    }
    
    public static HttpResponseWrapper createTicket(Map<String, Object> valueMap){

        Blob blobValue = Blob.valueOf(System.Label.FreshDeskAPIKey +':'+'X');
        
        HttpRequest httpReq = new HttpRequest();
        httpReq.setEndpoint(ENDPOINT+'/api/v2/tickets');
        httpReq.setMethod('POST');
        httpReq.setHeader('Content-Type', 'application/json');
        httpReq.setHeader('Authorization', 'Basic '+EncodingUtil.base64Encode(blobValue) );
        
        /* Map<String, Object> valueMap = new Map<String, Object>{
            'descriptionVar' => 'Description goes here..... Urgent Support Needed. Unable to login please help',
            'subject' => 'Urgent Support Needed. Unable to login please help',
            'email' => 'tom@outerspace.com',
            'priority' => 4, 'status' => 2, 'typex' => 'Problem', 'name' => 'Tom Holland'
        }; */
        
        String requestBody = '''
        	{ 
                "description": "${Description}", 
                "subject": "${Subject}",
                "email": "${ContactEmail}",
                "name" : "${ContactName}",
                "type": "${Typex}",
                "priority": ${Priority},
                "status": ${Status},
                "source": ${Source},
                "cc_emails": ["ram@freshdesk.com","diana@freshdesk.com"] 
            }
        '''.template(valueMap);
        
        httpReq.setBody(requestBody);
        
        Http httpObj = new Http();
        HttpResponseWrapper wrapper = new HttpResponseWrapper();
        try {
            HttpResponse httpRes = httpObj.send(httpReq);
            if(httpRes.getStatusCode() == 200 || httpRes.getStatusCode() == 201){
                // success
                wrapper.isSuccess = true;
                wrapper.message = 'Ticket has been created successfully!';
            } else {
                // error
                wrapper.isSuccess = false;
                wrapper.statusCode = httpRes.getStatusCode();
                wrapper.errorMessage = '';
            }
        } catch (System.CalloutException ex) {
            /* System.debug('Line Number '+ ex.getLineNumber());
            System.debug('Cause '+ ex.getCause());
            System.debug('Message '+ ex.getMessage());
            System.debug('StackTraceString '+ ex.getStackTraceString());
            System.debug('TypeName '+ ex.getTypeName()); */
            wrapper.isSuccess = false;
            wrapper.statusCode = 400;
            wrapper.errorMessage = 'Message '+ex.getMessage() +' Line Number '+ex.getLineNumber()+' Cause '+ ex.getCause();
        } catch (System.Exception ex) {
            /* System.debug('Line Number '+ ex.getLineNumber());
            System.debug('Cause '+ ex.getCause());
            System.debug('Message '+ ex.getMessage());
            System.debug('StackTraceString '+ ex.getStackTraceString());
            System.debug('TypeName '+ ex.getTypeName()); */
            wrapper.isSuccess = false;
            wrapper.statusCode = 400;
            wrapper.errorMessage = 'Message '+ex.getMessage() +' Line Number '+ex.getLineNumber()+' Cause '+ ex.getCause();
        }
        return wrapper;
    }
}