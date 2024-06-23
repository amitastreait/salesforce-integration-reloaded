/**
 * @description       : 
 * @author            : Amit Singh - PantherSchools
 * @group             : 
 * @last modified on  : 06-23-2024
 * @last modified by  : Amit Singh - PantherSchools
**/
trigger ContentVersionTrigger on ContentVersion (after insert) {
    Set<Id> orderIdsSet = new Set<Id>();
    Set<Id> opportunityIdsSet = new Set<Id>();
    for(ContentVersion file: Trigger.new){
        if(file.FirstPublishLocationId.getSobjectType() == Order.getSObjectType()){
            orderIdsSet.add(file.FirstPublishLocationId);
        }
        if(file.FirstPublishLocationId.getSobjectType() == Opportunity.getSObjectType()){
            opportunityIdsSet.add(file.FirstPublishLocationId);
        }
    }
    if(orderIdsSet?.size()> 0){
        // Call handler to check the Order Account Details and Upload File
    }
    if(opportunityIdsSet.size() > 0){
        // Call handler to check the Opportunity Account Details and Upload File
    }
}