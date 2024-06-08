/**
 * @description       : 
 * @author            : Amit Singh - PantherSchools
 * @group             : 
 * @last modified on  : 06-08-2024
 * @last modified by  : Amit Singh - PantherSchools
**/
@IsTest
public with sharing class Assignment_CaseTriggerTest {
    
    @IsTest
    private static void createCaseTest(){
        Account acc = new Account(
            Name = 'Salesforce.com'
        );
        insert acc;
        Contact con = new Contact(
            FirstName = 'Amit',
            LastName = 'Singh',
            Email = 'amit.singh@gmail.com',
            Phone = '9087654321',
            AccountId = acc.Id
        );
        insert con;
        Case caseRecord = new Case(
            ContactId = con.Id,
            Subject = 'Test Class',
            Description = 'Test Class',
            Status = 'New',
            Priority = 'High',
            Origin = 'Web'
        );
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Assignment_CaseTriggerMock());
        insert caseRecord;
        Test.stopTest();
    }

    @IsTest
    private static void createCaseErrorTest(){
        Account acc = new Account(
            Name = 'Salesforce.com'
        );
        insert acc;
        Contact con = new Contact(
            FirstName = 'Amit',
            LastName = 'Singh',
            Email = 'amit.singh@gmail.com',
            Phone = '9087654321',
            AccountId = acc.Id
        );
        insert con;
        Case caseRecord = new Case(
            ContactId = con.Id,
            Subject = 'Test Class',
            Description = 'Test Class',
            Status = 'New',
            Priority = 'High',
            Origin = 'Web'
        );
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Assignment_CaseTriggerErrorMock());
        insert caseRecord;
        Test.stopTest();
        List<Case> caseList = [SELECT Id, CaseNumber, Subject, ZendeskErrorMessage__c FROM Case WHERE Id =: caseRecord.Id LIMIT 1];
        if(caseList?.size() > 0){
            Case updateCase = caseList.get(0);
            System.debug(updateCase.ZendeskErrorMessage__c);
            Assert.areEqual('{ "errorMessage": "This is an error message!" }', updateCase.ZendeskErrorMessage__c, 'Error message is not matching!');
        }
    }
}