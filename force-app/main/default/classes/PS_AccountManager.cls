/**
 * @description       : 
 * @author            : Amit Singh - PantherSchools
 * @group             : PantherSchools
 * @last modified on  : 04-06-2024
 * @last modified by  : Amit Singh - PantherSchools
**/

/**
 * Org Base Url - Instance Url + services/apexrest/v1/PS_AccountManager/
 * https://integration-org2-dev-ed.develop.my.salesforce.com/services/apexrest/v1/PS_AccountManager/
 */
@RestResource(urlMapping = '/v1/PS_AccountManager/*')
global with sharing class PS_AccountManager {
    
    /**
     * @httpGet - GET
     * @httpPost - POST
     * @httpPut - PUT
     * @httpPatch - PATCH
     * @httpDelete - DELETE
     */
    
    @httpDelete
    global static void deleteRecords(){
        String accountId = RestContext.request.requestURI.substringAfterLast('/');
        Database.delete(accountId);
    }

    /** List all the Salesforce Accounts  - GET */
    // /v1/PS_AccountManager/001Hu000038SWuZIAW/Contacts
    @httpGet
    global static Account getAccountList(){

        RestRequest req  = RestContext.request;
        System.debug(System.JSON.serializePretty(req));

        RestResponse res = RestContext.response;
        System.debug(System.JSON.serializePretty(res));
        // /v1/PS_AccountManager/001Hu000038vjRiIAI
        /**
         * 1 - Get the Account ID from URL 
         *  1.1 - get last index of / 
         *  1.2 - use the substring method of your String Apex Class
         * 1.1.1
         *  - subStringAfterLast method of your String class
         * 2 - Query the Account with all the Informaton
         */
        String accountId = req.requestURI.substringAfterLast('/');

        Account accRecord = [SELECT 
                                Id, Name, Rating, Phone, Fax, Industry, BillingAddress, ShippingAddress
                                FROM 
                                    Account
                                WHERE
                                    Id =: accountId
                                LIMIT 1
                            ];
        return accRecord;

    }

    @httpPatch
    global static Account updateAccount(){
        RestRequest req  = RestContext.request;
        String accountId = req.requestURI.substringAfterLast('/');
        String request = req.requestBody.toString();
        Map<String,String> urlParams = req.params;
        // _HttpMethod=PATCH&name=Amit Singh
        // '_HttpMethod' => PATCH
        // 'name' => Amit Singh
        Map<String,String> headersMap = req.headers;
        Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(request);
        // Name, Active, Industry
        Account accountToUpdate   = new Account(Id = accountId);
        accountToUpdate.Name      = (String)responseMap.get('accountName');
        accountToUpdate.Active__c = (String)responseMap.get('active');
        accountToUpdate.Industry  = (String)responseMap.get('accountIndustry');
        accountToUpdate.AnnualRevenue  = (Decimal)responseMap.get('AnnualRevenue');
        Database.update(accountToUpdate);
        return accountToUpdate;
    }
    
    /** Create an Account - POST */

    @httpPost
    global static Account createAccount(){ // method arguments

        /** Get the information about Request */
        RestRequest req  = RestContext.request;
        System.debug(System.JSON.serializePretty(req));
        
        /** get the request body */
        String requeBody = req.requestBody?.toString(); // Convert Blob into String format
        System.debug( requeBody ); // JSON Format

        RestResponse res = RestContext.response;
        System.debug(System.JSON.serializePretty(res));

        if(String.isBlank(requeBody)){
            res.statusCode = 400;
            res.responseBody = Blob.valueOf('{"message": "Request Body can not be blank!"}');
            //return res;
        }

        Account acc = new Account();
        acc.Name     = UUID.randomUUID().toString();
        acc.Phone    = '98876655623';
        
        return acc;
    }
    
    public class AccountWrapper {
        public String id;
        public String name;
        public BillingAddress billigAddress;
    }

    public class BillingAddress {
        public String city;
    }
}