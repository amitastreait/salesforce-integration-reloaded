public class OpenCageReverseResponseWrapper{
	public results[] results;
	public class results {
		public components components;
		public Integer confidence;
		public String formatted;
		public geometry geometry;
	}
	public class components {
		public String city;	//Hanover
		public String city_district;	//Vahrenwald-List
		public String continent;	//Europe
		public String country;	//Germany
		public String country_code;	//de
		public String county;	//Region Hannover
		public String house_number;	//2
		public String office;	//Design Offices
		public String political_union;	//European Union
		public String postcode;	//30165
		public String road;	//Philipsbornstraße
		public String state;	//Lower Saxony
		public String state_code;	//NI
		public String suburb;	//Vahrenwald
	}
	public class geometry {
		public Double lat;	//52.387783
		public Double lng;	//9.7334394
	}
}