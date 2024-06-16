/**
 * @description       : 
 * @author            : Amit Singh - PantherSchools
 * @group             : 
 * @last modified on  : 06-14-2024
 * @last modified by  : Amit Singh - PantherSchools
**/
public without sharing class RSVPService {
    
    @AuraEnabled
    public static void process(String records){
        try {
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}