/**
 * @description       : 
 * @author            : Amit Singh - PantherSchools
 * @group             : 
 * @last modified on  : 03-17-2024
 * @last modified by  : Amit Singh - PantherSchools
**/
public with sharing class PS_InvoiceWrapper {
    
    public invoiceList[] invoiceList;
	public class invoiceList {
		public Double totalPrice;	//5.5
		public String statementDate;	//2011-10-04T16:58:54.858Z
		public lineItems[] lineItems;
		public Integer invoiceNumber;	//1
	}
	public class lineItems {
		public Decimal UnitPrice;	//1
		public Decimal Quantity;	//5
		public String ProductName;	//Pencil
        //public String productFamily;
	}
}