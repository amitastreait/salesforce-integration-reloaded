/**
 * @description       : 
 * @author            : Amit Singh - PantherSchools
 * @group             : 
 * @last modified on  : 06-23-2024
 * @last modified by  : Amit Singh - PantherSchools
**/
trigger AccountTrigger on Account (after insert, after update) {

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
    }
}