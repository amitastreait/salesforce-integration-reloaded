/**
 * @description       : 
 * @author            : Amit Singh - PantherSchools
 * @group             : 
 * @last modified on  : 06-23-2024
 * @last modified by  : Amit Singh - PantherSchools
**/
public with sharing class AccountTriggerHandler {
    
    public static void createBucket(List<Account> newRecords){
        for (Account acc : newRecords) {
            createBucket(acc.Name, acc.Id, '');   
        }
    }

    @future(callout = true)
    public static void createBucket(String bucketName, String recordId, String region){
        AWSS3Manager.createBucket(bucketName, recordId, region);
    }
}