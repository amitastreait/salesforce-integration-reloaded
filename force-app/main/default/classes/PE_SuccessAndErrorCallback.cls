/**
 * @description       : 
 * @author            : Amit Singh - PantherSchools
 * @group             : 
 * @last modified on  : 05-09-2024
 * @last modified by  : Amit Singh - PantherSchools
**/
public with sharing class PE_SuccessAndErrorCallback implements EventBus.EventPublishFailureCallback, EventBus.EventPublishSuccessCallback {
    
    public void onFailure(EventBus.FailureResult result) {
        List<String> eventUuids = result.getEventUuids();
        System.debug(eventUuids.size() + ' events failed to publish.');      
        System.debug('Callback eventUuids to match with event objects: ' + eventUuids);
    }

    public void onSuccess(EventBus.SuccessResult result) {
        List<String> eventUuids = result.getEventUuids();
        System.debug(eventUuids.size() + ' events were published successfully.');
        System.debug('Callback eventUuids to match with event objects: ' + eventUuids);
    }

}