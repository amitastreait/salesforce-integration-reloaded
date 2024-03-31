/**
 * @description       : 
 * @author            : Amit Singh - PantherSchools
 * @group             : 
 * @last modified on  : 03-31-2024
 * @last modified by  : Amit Singh - PantherSchools
**/

/**
 * Org Base Url - Instance Url + services/apexrest/v1/PS_ContactManager/
 * https://integration-org2-dev-ed.develop.my.salesforce.com/services/apexrest/v1/PS_ContactManager/
 */

@RestResource(urlMapping = '/v1/PS_ContactManager/*')
global with sharing class PS_ContactManager {
    
    @httpGet
    global static List<Contact> listContacts(){
        return [SELECT Id, Name, Email, Phone FROM Contact LIMIT 10];
    }

    /*
        For Account Record - 
            Name,
            Industry, Rating
            AnnualRevenue, Phone

        For Contact Record - 
            FistName, LastName, Email, Title, Phone
    */

    @httpPost
    global static ResponseWrapper processData(InputWrapper input){
        List<Contact> existingContacts = [SELECT Id, FirstName, LastName, Account.Name 
                                            FROM
                                                Contact 
                                            WHERE 
                                                Email =: input.email
                                        ];

        ResponseWrapper wrapper = new ResponseWrapper();

        if(existingContacts?.size()>0){
            // do nothing
            wrapper.contactRecord = existingContacts.get(0);
            wrapper.status = 'Existing';
            wrapper.message = 'Contact Already Exists with the Same Email';
        }else{
            Account accountRecord = new Account(Name = input.accountName);
            insert accountRecord;
            
            Contact contactRecord = new Contact(
                FirstName = input.firstName,
                LastName = input.lastName,
                Email = input.email
            );
            contactRecord.AccountId = accountRecord.Id;

            insert contactRecord;

            wrapper.contactRecord = contactRecord;
            wrapper.accountRecord = accountRecord;
            wrapper.status = 'New';
            wrapper.message = 'Data Inserted';
        }
        return wrapper;
    }

    /*
    @httpPost
    global static ResponseWrapper processData(Account accountRecord, Contact contactRecord){ // method arguments
        System.debug(System.LoggingLevel.DEBUG, accountRecord);
        System.debug(System.LoggingLevel.DEBUG, contactRecord);
        List<Contact> existingContacts = [SELECT Id, FirstName, LastName, Account.Name FROM Contact WHERE Email =: contactRecord.Email];

        ResponseWrapper wrapper = new ResponseWrapper();

        if(existingContacts?.size()>0){
            // do nothing
            wrapper.contactRecord = contactRecord;
            wrapper.accountRecord = accountRecord;
            wrapper.status = 'Existing';
            wrapper.message = 'Contact Already Exists with the Same Email';
        }else{
            // Create Account
            insert accountRecord;
            // Create Contact
            contactRecord.AccountId = accountRecord.Id;
            insert contactRecord;

            wrapper.contactRecord = contactRecord;
            wrapper.accountRecord = accountRecord;
            wrapper.status = 'New';
            wrapper.message = 'Data Inserted';
        }
        return wrapper;
    }
    */

    global class InputWrapper {
        global String accountName;
        global String firstName;
        global String lastName;
        global String email;
    }

    global class ResponseWrapper {
        global Account accountRecord;
        global Contact contactRecord;
        global String status; // New, Existing
        global String message; // Success, Error
    }
}