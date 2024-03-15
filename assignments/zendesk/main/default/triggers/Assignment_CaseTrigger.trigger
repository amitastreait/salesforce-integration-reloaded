trigger Assignment_CaseTrigger on Case (after insert) {
    if(!System.isFuture() && !System.isBatch()){
        System.debug(' Method Assignment_CaseTrigger is executed with isFuture or isBatch ');
        Assignment_CaseTriggerHandler.syncWithZendesk(Trigger.New.get(0).Id);
    }
}