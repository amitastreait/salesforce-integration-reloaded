/**
 * @description       : 
 * @author            : Amit Singh - PantherSchools
 * @group             : 
 * @last modified on  : 05-18-2024
 * @last modified by  : Amit Singh - PantherSchools
**/
public with sharing class PS_XeroHandler implements Database.Batchable<sObject>, Database.AllowsCallouts {
    public Database.QueryLocator start(Database.BatchableContext bc) {
        // 100 callouts
        return Database.getQueryLocator('Select Id, Name FROM Account');
    }

    public void execute(Database.BatchableContext bc, List<Account> records){
        // Making Callout
        // Too Many Callouts : 1
        // 100 callouts
    }

    public void finish(Database.BatchableContext bc){
        // 100 callouts
        // execute any post-processing operations
    }
}