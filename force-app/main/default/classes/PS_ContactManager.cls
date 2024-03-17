/**
 * @description       : 
 * @author            : Amit Singh - PantherSchools
 * @group             : 
 * @last modified on  : 03-17-2024
 * @last modified by  : Amit Singh - PantherSchools
**/

@RestResource(urlMapping = '/v1/PS_AccountManager/*/Contact')
global with sharing class PS_ContactManager {
    
    @httpGet
    global static List<Contact> listContacts(){
        return [SELECT Id, Name, Email, Phone FROM Contact LIMIT 10];
    }
}