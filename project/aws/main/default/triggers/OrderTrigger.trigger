/**
 * @description       : 
 * @author            : Amit Singh - PantherSchools
 * @group             : 
 * @last modified on  : 06-23-2024
 * @last modified by  : Amit Singh - PantherSchools
**/
trigger OrderTrigger on Order (after insert) {
    if(Trigger.isAfter){
        if(Trigger.isInsert && !System.isBatch() && !System.isFuture() && !System.isQueueable() ){
            OrderTriggerHandler.createFolderInsideBucket(Trigger.new.get(0));
        }
    }
}