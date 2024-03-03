public with sharing class CaseTriggerHandler {

    public static void handleAfterInsert(List<Case> newRecords) {
        if(System.isFuture() || System.isBatch()){
            return;
        }
        
        for(Case c : newRecords){ // make a SQOL Query to get the Contact Details
            PS_ZendeskTicketUtils.TicektWrapper wrapper = new PS_ZendeskTicketUtils.TicektWrapper();
            wrapper.body     = c.Description;
            wrapper.subject  = c.Subject;
            wrapper.priority = c.Priority.toLowerCase(); // Allowed values are "urgent", "high", "normal", or "low".
            wrapper.name     = 'Amit Singh';
            wrapper.email    = 'asingh@example.org';
            // Converting the Object into String
            makeCallout( JSON.serialize(wrapper) );
        }
    }

    @future(callout = true) // THIS is not the best Solution
    private static void makeCallout(String params){
        // Convert the String in object(class)
        PS_ZendeskTicketUtils.TicektWrapper wrapper = (PS_ZendeskTicketUtils.TicektWrapper)JSON.deserialize(params, PS_ZendeskTicketUtils.TicektWrapper.class);
        PS_ZendeskTicketUtils.createTicket(wrapper);
    }
}