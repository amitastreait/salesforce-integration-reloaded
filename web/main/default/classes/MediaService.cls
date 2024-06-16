/**
 * @description       : 
 * @author            : Amit Singh - PantherSchools
 * @group             : 
 * @last modified on  : 06-14-2024
 * @last modified by  : Amit Singh - PantherSchools
**/
public without sharing class MediaService {
    
    @AuraEnabled(cacheable=true)
    public static List<sObject> fetch(String typex){
        try {
            return [SELECT Id, Subheading__c, Heading__c, Media_Type__c, PublicUrl__c, ButtonText__c, ButtonUrl__c FROM Media__c WHERE Media_Type__c = :typex ];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}