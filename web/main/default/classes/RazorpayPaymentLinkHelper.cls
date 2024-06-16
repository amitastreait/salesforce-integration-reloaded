/**
 * @description       : 
 * @author            : Amit Singh - PantherSchools
 * @group             : 
 * @last modified on  : 06-14-2024
 * @last modified by  : Amit Singh - PantherSchools
**/
public without sharing class RazorpayPaymentLinkHelper {
    
    public static void initiate(RazorpayPaymentLinkHelper input){
        String json = '{'+
		'    "amount": '+(input.amount)*100+','+
		'    "currency": "INR",'+
		'    "accept_partial": false,'+
		'    "reference_id": "'+input.reference_id+'",'+
		'    "description": "RSCP Ticket Booking for MuleDreamin Event 2024 - "'+input.reference_id+','+
		'    "customer": {'+
		'        "name": "'+input.customer.name+'",'+
		'        "contact": "'+input.customer.contact+'",'+
		'        "email": "'+input.customer.email+'"'+
		'    },'+
		'    "notify": {'+
		'        "sms": true,'+
		'        "email": true'+
		'    },'+
		'    "reminder_enable": true,'+
		'    "notes": {'+
		'        "event_name": "MuleDreamin 2024"'+
		'    },'+
		'    "callback_url": "'+input.callback_url+'",'+
		'    "callback_method": "get"'+
		'}';
    }

    public Integer amount;
	public String reference_id;
    public String callback_url;
	public customer customer;
	public class customer {
		public String name;
		public String contact;
		public String email;
	}
}