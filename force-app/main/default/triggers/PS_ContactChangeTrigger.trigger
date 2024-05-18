/**
 * @description       : 
 * @author            : Amit Singh - PantherSchools
 * @group             : 
 * @last modified on  : 05-18-2024
 * @last modified by  : Amit Singh - PantherSchools
**/
trigger PS_ContactChangeTrigger on ContactChangeEvent (after insert) {
    for(ContactChangeEvent con: Trigger.new){
        // check the change type
        System.debug(System.JSON.serializePretty(con));
        EventBus.ChangeEventHeader header = con.ChangeEventHeader;
        String changeEntity = header.entityName;
        String changeOperation = header.changeType;
        if(changeOperation == 'CREATE'){
            System.debug('Contact Created: ' + con.FirstName);
        } else if(changeOperation == 'UPDATE'){
            System.debug('Contact Updated: ' + con.FirstName);
        } else if(changeOperation == 'DELETE'){
            System.debug('Contact Deleted: ' + con.FirstName);
        } else if(changeOperation == 'UNDELETE'){
            System.debug('Contact Restored: ' + con.FirstName);
        }
    }
}