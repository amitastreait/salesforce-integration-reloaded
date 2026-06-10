/**
 * @description       : 
 * @author            : Amit Singh - PantherSchools
 * @group             : 
 * @last modified on  : 07-10-2024
 * @last modified by  : Amit Singh - PantherSchools
**/
trigger AccountTrigger on Account (after insert, after update, before update) {

    if(Trigger.isAfter){
        if(Trigger.isInsert && !System.isBatch() && !System.isFuture() && !System.isQueueable() ){
            Account acc = Trigger.new.get(0);
            if(acc.SyncWithS3__c == True && String.isBlank(acc.S3BucketName__c)){
                AccountTriggerHandler.createBucket(new List<Account>{acc});
            }
        }
        if(Trigger.isUpdate && !System.isBatch() && !System.isFuture() && !System.isQueueable() ){
            // check if sync with s3 is changed and marked as true
            Account acc = Trigger.new.get(0);
            Account oldRecord = Trigger.oldMap.get(acc.Id);
            if(acc.SyncWithS3__c <> oldRecord.SyncWithS3__c && acc.SyncWithS3__c == True && String.isBlank(acc.S3BucketName__c) ){
                AccountTriggerHandler.createBucket(new List<Account>{acc});
            }
        }
    }else if (trigger.isBefore && trigger.isUpdate) {
        System.debug('Before Update Trigger');
        for (Account acc : trigger.new) {
            Account oldAcc = trigger.oldMap.get(acc.Id);
            System.debug('Processing Account Id: ' + acc.Id);
            if (acc.Rating == 'Hot' && oldAcc.Rating != 'Hot') {
                System.debug('Rating has changed to Hot. Old: ' + oldAcc.Rating + ', New: ' + acc.Rating);
                OpenCodeGeocoderService.getReverseGeoCoding(acc.Id);
                System.debug('Called getReverseGeoCoding for Account Id: ' + acc.Id);
            }
        }
    }

}