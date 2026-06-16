public class AddressVerifyRequest{
	public List<Addresses> addresses;
	public class Addresses {
		public String line1;
		public String city;	
		public String provinceOrState;
		public String postalOrZip;	
		public String country;
	}
}