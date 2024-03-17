/**
 * @description       : 
 * @author            : Amit Singh - PantherSchools
 * @group             : 
 * @last modified on  : 03-17-2024
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
     * @hpptPatch - PATCH
     * @delete - DELETE
     */
    
    /** List all the Salesforce Accounts  - GET */
    @httpGet
    global static List<Account> getAccountList(){

        RestRequest req  = RestContext.request;
        System.debug(System.JSON.serializePretty(req));

        RestResponse res = RestContext.response;
        System.debug(System.JSON.serializePretty(res));

        return [SELECT Id, Name, Industry, Phone, Fax FROM Account LIMIT 10];

    }
    
    /** Create an Account - POST */

    @httpPost
    global static Account createAccount(){ // method arguments

        /** Get the information about Request */
        RestRequest req  = RestContext.request;
        System.debug(System.JSON.serializePretty(req));
        
        /** get the request body */
        String requeBody = req.requestBody?.toString(); // Convert Blob into String format
        System.debug( requeBody );

        RestResponse res = RestContext.response;
        System.debug(System.JSON.serializePretty(res));
        //PS_AccountService.formatString(null);

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
}