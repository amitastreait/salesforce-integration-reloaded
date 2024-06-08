/**
 * @description       : 
 * @author            : Amit Singh - PantherSchools
 * @group             : 
 * @last modified on  : 06-08-2024
 * @last modified by  : Amit Singh - PantherSchools
**/
public with sharing class Assignment_CaseTriggerHandler {

    @future(callout = true)
    public static void syncWithZendesk(String caseRecordId){
        Case newRecord = [SELECT Id, CaseNumber, Subject, Description, ContactId, Priority,
                                Contact.Name, Contact.Email, SuppliedEmail, SuppliedName,
                                Agent__c, Agent__r.ZendeskId__c
                            FROM
                                Case 
                            WHERE 
                                Id =: caseRecordId
                        ];

        Assignment_ZendeskUtils.TicektWrapper wrapper = new Assignment_ZendeskUtils.TicektWrapper();
        wrapper.body = newRecord.Description;
        wrapper.subject = newRecord.Subject;
        wrapper.priority = newRecord.Priority.toLowerCase();
        wrapper.name = newRecord.Contact.Name ?? newRecord.SuppliedName;
        wrapper.email = newRecord.Contact.Email ?? newRecord.SuppliedEmail;
        wrapper.agentId = newRecord.Agent__r.ZendeskId__c ?? null;

        HttpResponse httpRes = Assignment_ZendeskUtils.createTicket(wrapper);

        if(httpRes?.getStatusCode() == 201 || httpRes?.getStatusCode() == 200){
            String responseBody = httpRes.getBody();
            Assignment_ZendeskTicketWrapper ticket = (Assignment_ZendeskTicketWrapper)JSON.deserialize(responseBody, Assignment_ZendeskTicketWrapper.class);
            if(ticket?.ticket?.id != null){
                newRecord.Zendesk_Ticket_Id__c = Integer.valueOf(ticket.ticket.id);
                update newRecord;
            }
        }else{
            System.debug(' Error Occured While Creating Records '+ httpRes?.getBody() );
            newRecord.ZendeskErrorMessage__c = httpRes?.getBody();
            update newRecord;
        }
    }

}