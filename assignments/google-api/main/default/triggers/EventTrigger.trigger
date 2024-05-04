/**
 * @description       : 
 * @author            : Amit Singh - PantherSchools
 * @group             : 
 * @last modified on  : 04-25-2024
 * @last modified by  : Amit Singh - PantherSchools
**/
trigger EventTrigger on Event (after insert) {
    if(!System.isBatch() && !System.isFuture()){
        EventTriggerHandler.createEventInGoogle(Trigger.new.get(0).Id);
    }
}