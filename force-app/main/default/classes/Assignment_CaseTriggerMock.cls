/**
 * @description       : 
 * @author            : Amit Singh - PantherSchools
 * @group             : 
 * @last modified on  : 06-08-2024
 * @last modified by  : Amit Singh - PantherSchools
**/
@IsTest
public with sharing class Assignment_CaseTriggerMock implements HttpCalloutMock {
    public HttpResponse respond(HttpRequest req){

        String json=		'{'+
		'    "ticket": {'+
		'        "url": "https://pantherschoolshelp.zendesk.com/api/v2/tickets/14.json",'+
		'        "id": 14,'+
		'        "external_id": null,'+
		'        '+
		'        "created_at": "2024-03-15T08:39:37Z",'+
		'        "updated_at": "2024-03-15T08:39:37Z",'+
		'        "generated_timestamp": 0,'+
		'        "type": "incident",'+
		'        "subject": "My printer is on fire!",'+
		'        "raw_subject": "My printer is on fire!",'+
		'        "description": "The smoke is very colorful.",'+
		'        "priority": "urgent",'+
		'        "status": "open",'+
		'        "recipient": null,'+
		'        "requester_id": 17691919870738,'+
		'        "submitter_id": 17691919870738,'+
		'        "assignee_id": 17691919870738,'+
		'        "organization_id": 17691875790994,'+
		'        "group_id": 17691920139922,'+
		'        "forum_topic_id": null,'+
		'        "problem_id": null,'+
		'        "has_incidents": false,'+
		'        "is_public": true,'+
		'        "due_at": null,'+
		'        '+
		'        "followup_ids": [],'+
		'        "ticket_form_id": 17691875688594,'+
		'        "brand_id": 17691875769234,'+
		'        "allow_channelback": false,'+
		'        "allow_attachments": true,'+
		'        "from_messaging_channel": false'+
		'    }'+
		'}';

        HttpResponse response = new HttpResponse();
        response.setBody(json);
        response.setHeader('Content-Type', 'application/json');
        response.setStatusCode(200);
        response.setStatus('OK');
        return response;
    }
}