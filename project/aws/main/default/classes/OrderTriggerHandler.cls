/**
 * @description       : 
 * @author            : Amit Singh - PantherSchools
 * @group             : 
 * @last modified on  : 06-23-2024
 * @last modified by  : Amit Singh - PantherSchools
**/
public with sharing class OrderTriggerHandler {
    
    public static void createFolderInsideBucket(Order order){
        List<Account> accList = [SELECT Id, SyncWithS3__c, S3BucketName__c FROM Account WHERE Id =: order.AccountId LIMIT 1];
        if(accList?.size() > 0 && accList.get(0).SyncWithS3__c && String.isNotBlank( accList.get(0).S3BucketName__c ) ){
            // create a folder
            createFolderInsideBucket(accList.get(0).S3BucketName__c, 'orders', order.OrderNumber.toLowerCase()+'-'+String.valueOf(order.Id).toLowerCase() );
        }
    }

    @future(callout = true)
    public static void createFolderInsideBucket(String bucketPath, String folderPath, String folderName ) {
        String endPoint = EncodingUtil.urlEncode(bucketPath, 'UTF-8') + '/'+ EncodingUtil.urlEncode(folderPath, 'UTF-8') +'/'+ EncodingUtil.urlEncode(folderName, 'UTF-8') +'/';
        AWSS3Manager.createFolderInsideBucket(endPoint);
    }
}