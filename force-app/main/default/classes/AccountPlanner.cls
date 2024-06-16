/**
 * @description       : 
 * @author            : Amit Singh - PantherSchools
 * @group             : 
 * @last modified on  : 06-16-2024
 * @last modified by  : Amit Singh - PantherSchools
**/
global with sharing class AccountPlanner {

    webservice static String helloWorld(String name){
        return 'Hello ' + name + '!';
    }

    /*webservice static String createAccount(String name, String Industry){
        Account acc = new Account();
        acc.Name = name;
        acc.Industry = Industry;
        insert acc;
        return acc.Id;
    }*/

    webservice static InputWrapper createContact(InputWrapper input){
        /***
         * Create the Contact Record and return the response
         */
        return input;
    }

    /* webservice static Lead createLead(Lead leadRecord){
        return leadRecord;
    } */

    global class InputWrapper{
        webservice String firstName;
        webservice String lastName;
        webservice String email;
        webservice String accountId;
    }

}