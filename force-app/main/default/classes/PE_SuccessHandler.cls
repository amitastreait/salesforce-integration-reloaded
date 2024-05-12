/**
 * @description       : 
 * @author            : Amit Singh - PantherSchools
 * @group             : 
 * @last modified on  : 05-12-2024
 * @last modified by  : Amit Singh - PantherSchools
**/
public with sharing class PE_SuccessHandler implements EventBus.EventPublishSuccessCallback {
    public void onSuccess(EventBus.SuccessResult result){
        System.debug('Success');
        System.debug(result.getEventUuids());
    }
}