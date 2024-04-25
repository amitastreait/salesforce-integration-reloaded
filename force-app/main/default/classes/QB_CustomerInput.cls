/**
 * @description       : 
 * @author            : Amit Singh - PantherSchools
 * @group             : 
 * @last modified on  : 04-20-2024
 * @last modified by  : Amit Singh - PantherSchools
**/
public with sharing class QB_CustomerInput {
    public String FullyQualifiedName;
	public PrimaryEmailAddr PrimaryEmailAddr;
	public String DisplayName;
	public String Suffix;
	public String Title;
	public String MiddleName;
	public String Notes;
	public String FamilyName;
	public PrimaryPhone PrimaryPhone;
	public String CompanyName;
	public BillAddr BillAddr;
	public String GivenName;
	public class PrimaryEmailAddr {
		public String Address;
	}
	public class PrimaryPhone {
		public String FreeFormNumber;
	}
	public class BillAddr {
		public String CountrySubDivisionCode;
		public String City;
		public String PostalCode;
		public String Line1;
		public String Country;
	}
}