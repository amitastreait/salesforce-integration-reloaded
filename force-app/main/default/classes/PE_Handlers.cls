/**
 * @description       : 
 * @author            : Amit Singh - PantherSchools
 * @group             : 
 * @last modified on  : 05-12-2024
 * @last modified by  : Amit Singh - PantherSchools
**/
public with sharing class PE_Handlers implements EventBus.EventPublishSuccessCallback, EventBus.EventPublishFailureCallback {
    public void onSuccess(EventBus.SuccessResult result){
        System.debug('Success');
        System.debug(result.getEventUuids());
    }

    public void onFailure(EventBus.FailureResult result){
        System.debug('Failure');
        System.debug(result.getEventUuids());
    }
}