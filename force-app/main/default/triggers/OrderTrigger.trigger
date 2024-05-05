/**
 * @description       : 
 * @author            : Amit Singh - PantherSchools
 * @group             : 
 * @last modified on  : 05-05-2024
 * @last modified by  : Amit Singh - PantherSchools
**/
trigger OrderTrigger on Order (after insert) {
    OrderTriggerHander.publishEvent(Trigger.New);
}