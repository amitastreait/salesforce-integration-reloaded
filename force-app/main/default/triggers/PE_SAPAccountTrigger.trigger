/**
 * @description       : 
 * @author            : Amit Singh - PantherSchools
 * @group             : 
 * @last modified on  : 05-05-2024
 * @last modified by  : Amit Singh - PantherSchools
**/
trigger PE_SAPAccountTrigger on SAP_Account__e (after insert) {
    System.debug('SAP_Account__e Trigger Executed');
    System.debug('SAP_Account__e Data \n '+ JSON.serializePretty(Trigger.new));
}