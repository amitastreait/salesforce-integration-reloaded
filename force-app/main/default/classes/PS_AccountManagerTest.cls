/**
 * @description       : 
 * @author            : Amit Singh - PantherSchools
 * @group             : 
 * @last modified on  : 06-08-2024
 * @last modified by  : Amit Singh - PantherSchools
**/
@IsTest
public with sharing class PS_AccountManagerTest {
    
    @IsTest
    public static void deleteRecordsTest(){

        Account acc = new Account(
            Name = 'Salesforce.com'
        );
        insert acc;

        RestRequest req = new RestRequest();
        req.requestURI = '/v1/PS_AccountManager/'+acc.Id;

        RestContext.request = req;

        Test.startTest();
        PS_AccountManager.deleteRecords();
        Test.stopTest();
    }

    @IsTest
    private static void getAccountListTest(){
        Account acc = new Account(
            Name = 'Salesforce.com'
        );
        insert acc;

        RestRequest req = new RestRequest();
        req.requestURI = '/v1/PS_AccountManager/'+acc.Id;

        RestContext.request = req;

        Test.startTest();
        Account accRecord = PS_AccountManager.getAccountList();
        Test.stopTest();
        Assert.areEqual('Salesforce.com', accRecord.Name, 'The account name does not match!');
    }

    @IsTest
    private static void createAccountTest(){
        RestRequest req = new RestRequest();
        req.requestURI = '/v1/PS_AccountManager/';

        String requestBody = '{'+
            '"Name" : "Salesforce.com",'+
            '"Rating": "Hot"'+
        '}';

        req.requestBody = Blob.valueOf(requestBody);

        RestContext.request = req;
        Test.startTest();
        PS_AccountManager.createAccount();
        Test.stopTest();
    }

    @IsTest
    private static void createAccountErrorTest(){
        RestRequest req = new RestRequest();
        req.requestURI = '/v1/PS_AccountManager/';

        RestContext.request = req;

        RestResponse res = new RestResponse();
        RestContext.response = res;

        Test.startTest();
        PS_AccountManager.createAccount();
        Test.stopTest();
    }

    @IsTest
    private static void updateAccountTest(){
        Account acc = new Account(
            Name = 'Salesforce.com'
        );
        insert acc;

        RestRequest req = new RestRequest();
        req.requestURI = '/v1/PS_AccountManager/'+acc.Id;

        req.addHeader('X-API-Key', 'api_key_uuyuy564');
        req.addParameter('FirstName', 'Amit Singh');

        String requestBody = '{'+
            '"accountName" : "PantherSchools.com",'+
            '"active" : "Yes",'+
            '"accountIndustry" : "Education",'+
            '"AnnualRevenue" : 8983454.345'+
        '}';
        req.requestBody = Blob.valueOf(requestBody);
        
        RestContext.request = req;
        Test.startTest();
        Account accRecord = PS_AccountManager.updateAccount();
        Test.stopTest();

        Assert.areEqual('PantherSchools.com', accRecord.Name, 'The account name does not match!');
        Assert.areEqual('Education', accRecord.Industry);
    }
}