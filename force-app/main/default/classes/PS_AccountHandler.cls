/**
 * @description       : 
 * @author            : Amit Singh - PantherSchools
 * @group             : 
 * @last modified on  : 05-12-2024
 * @last modified by  : Amit Singh - PantherSchools
**/
public with sharing class PS_AccountHandler implements Database.Batchable<sObject>, Database.RaisesPlatformEvents {
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator('Select Id, Name FROM Account');
    }

    public void execute(Database.BatchableContext bc, List<Account> records){
        Integer i = 100/0;
    }

    public void finish(Database.BatchableContext bc){
        // execute any post-processing operations
    }
}