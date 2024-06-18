/**
 * @description       : 
 * @author            : Amit Singh - PantherSchools
 * @group             : 
 * @last modified on  : 06-18-2024
 * @last modified by  : Amit Singh - PantherSchools
**/
public without sharing class RazorpayPaymentLinkHelper {
    
    public static HttpResponse initiate(RazorpayPaymentLinkHelper input){
        String requestBody = '{'+
		'    "amount": '+(input.amount)*100+','+
		'    "currency": "INR",'+
		'    "accept_partial": true,'+
		'    "first_min_partial_amount": '+(input.amount)*100+','+
		'    "reference_id": "'+input.reference_id+'",'+
		'    "description": "RSVP Ticket Booking for MuleDreamin Event 2024",'+
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
		'        "event_name": "Mule Dreamin 2024"'+
		'    },'+
		'    "options": {'+
		'        "checkout": {'+
		'            "name": "Mule Dreamin",'+
		'            "partial_payment": {'+
		'                "min_amount_label": "Minimum Booking Amount to be paid",'+
		'                "partial_amount_label": "Pay in parts",'+
		'                "partial_amount_description": "Pay at least ₹'+input.amount+'",'+
		'                "full_amount_label": "Pay the entire booking amount"'+
		'            }'+
		'        },'+
		'        "hosted_page": {'+
		'            "label": {'+
		'                "receipt": "Ref No.",'+
		'                "description": "Event Name",'+
		'                "amount_payable": "Booking Amount Payable",'+
		'                "amount_paid": "Booking Amount Paid",'+
		'                "partial_amount_due": "Booking Amount Due",'+
		'                "partial_amount_paid": "Booking Amount Paid",'+
		'                "expire_by": "Pay Before",'+
		'                "expired_on": "Link Expired. Please contact Admin",'+
		'                "amount_due": "Booking Amount Due"'+
		'            },'+
		'            "show_preferences": {'+
		'                "issued_to": true'+
		'            }'+
		'        }'+
		'    },'+
		'    "callback_url": "'+input.callback_url+'",'+
		'    "callback_method": "get"'+
		'}';
		//System.debug(requestBody);
		RazorpayConfig__mdt config = RazorpayConfig.config('Sandbox');
		HttpResponse httpRes = HTTPUtil.call('callout:RazorPay'+'/v1/payment_links/', requestBody, 'POST', null, 'application/json');
		return httpRes;
    }

    public Decimal amount;
	public String reference_id;
    public String callback_url;
	public customer customer;
	public class customer {
		public String name;
		public String contact;
		public String email;
	}
}