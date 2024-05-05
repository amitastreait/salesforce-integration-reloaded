/**
 * @description       : 
 * @author            : Amit Singh - PantherSchools
 * @group             : 
 * @last modified on  : 05-05-2024
 * @last modified by  : Amit Singh - PantherSchools
**/
public with sharing class OrderTriggerHander {
    public static void publishEvent(List<Order> newRecords){
        List<Order> orderToPublish = [SELECT OrderNumber FROM Order WHERE Id IN:newRecords ];
        List<OrderStatus__e> orderStatusList = new List<OrderStatus__e>();
        for(Order ord: orderToPublish ){
            OrderStatus__e orderStatus = new OrderStatus__e();
            orderStatus.Order_Number__c = ord.OrderNumber;
            orderStatus.Total_Amount_in_USD__c = 0.00;
            orderStatusList.add(orderStatus);
        }
        EventBus.publish(orderStatusList);
        // throw the Error
        Integer i = 10/0;
    }
}