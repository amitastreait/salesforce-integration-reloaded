public with sharing class Assignment_ZendeskAgentUtils implements System.Queueable, Database.AllowsCallouts {

    private final Integer PAGE_SIZE = 10;
    private String nextUrl = '';

    // Id jobId = System.enqueueJob(new Assignment_ZendeskAgentUtils(''));

    public Assignment_ZendeskAgentUtils(String nextUrl){
        this.nextUrl = nextUrl;
    }

    public void execute(QueueableContext context) {

        String header = System.Label.Zendesk_Username +':'+System.Label.Zendesk_APITOKEN;
        Blob headerValue = Blob.valueOf(header);

        String endpoint = 'https://pantherschoolshelp.zendesk.com/api/v2/users.json?page[size]='+PAGE_SIZE;
        if(!String.isBlank(this.nextUrl)){
            endpoint = this.nextUrl;
        }
        
        HttpRequest httpReq = PS_CalloutUtils.prepareRequest(endpoint,'GET','','application/json', 'application/json');
        httpReq.setHeader('Authorization','Basic '+EncodingUtil.base64Encode( headerValue ) );

        Http http = new Http();
        try{
            HttpResponse httpRes = http.send(httpReq);
            if(httpRes?.getStatusCode() == 201 || httpRes?.getStatusCode() == 200){
                List<Agent__c> agentsToUpsert = new List<Agent__c>();
                Assignment_ZendeskAgentUtils allrecords = (Assignment_ZendeskAgentUtils)JSON.deserialize(httpRes?.getBody(), Assignment_ZendeskAgentUtils.class);
                if(allrecords?.users?.size()>0){
                    for(Assignment_ZendeskAgentUtils.users user: allrecords?.users){
                        Agent__c agentRecord = new Agent__c();
                        agentRecord.Name = user.name;
                        agentRecord.Email__c = user.email;
                        agentRecord.ZendeskId__c = user.id;
                        agentRecord.Locale__c = user.locale;
                        agentRecord.LocaleId__c = user.locale_id;
                        agentRecord.Role__c = user.role;
                        agentRecord.TimeZone__c = user.time_zone;
                        agentRecord.Verified__c = user.verified;
                        agentRecord.Active__c = user.active;
                        agentRecord.ZendeskUrl__c = user.url;
                        agentRecord.Agent__c = user.role?.equals('agent');
                        agentsToUpsert.add(agentRecord);
                    }
                }
                if(agentsToUpsert?.size()>0){
                    upsert agentsToUpsert ZendeskId__c;
                }
                /**
                 * TODO: Queue the Job to fetch the next set of records
                 */
                if(allrecords?.links?.next != null){
                    Id jobId = System.enqueueJob(new Assignment_ZendeskAgentUtils(allrecords?.links?.next));
                }
            }else{
                System.debug(' Error Occured While Creating Records '+ httpRes?.getBody() );
            }
        }catch(System.CalloutException ex){
            System.debug(ex.getStackTraceString());
        }catch(System.Exception ex){
            System.debug(ex.getStackTraceString());
        }
    } 
    
    public users[] users;
	public meta meta;
	public links links;
	public class users {
		public String id;
		public String url;
		public String name;
		public String email;
		public String created_at;
		public String updated_at;
		public String time_zone;
		public Integer locale_id;
		public String locale;
		public String role;
		public boolean verified;
		public boolean active;
	}
	public class meta {
		public boolean has_more;
		public String after_cursor;
		public String before_cursor;
	}
	public class links {
		public String prev;
		public String next;
	}
}