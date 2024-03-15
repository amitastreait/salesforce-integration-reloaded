public with sharing class Assignment_GoogleEventInputWrapper {
    
    public EventEnd end_x;
	public EventStart start;
	public attendees[] attendees;
	public attachments[] attachments;
	public String summary;
	public String description;
    public String location;
	public organizer organizer;

	public class EventEnd {
		public String date_x;
        public String dateTime_x;
	}

	public class EventStart {
		public String date_x;
        public String dateTime_x;
	}

	public class attendees {
		public String email;
		public String displayName;
	}

	public class attachments {
		public String fileUrl;
		public String title;
	}

	public class organizer {
		public String displayName;
		public String email;
	}
	
    @TestVisible
	private static String testParse() {
		String fakeResponse =		'{'+
		'    "end": {'+
		'        "date": "2024-04-05"'+
		'    },'+
		'    "start": {'+
		'        "date": "2024-04-04"'+
		'    },'+
		'    "attendees": ['+
		'        {'+
		'            "email": "engineeringkipathshala@gmail.com",'+
		'            "displayName": "Engineering ki Pathshala"'+
		'        }'+
		'    ],'+
		'    "attachments": ['+
		'        {'+
		'            "fileUrl": "https://www.canva.com/design/DAF8IHx0BZ0/f-Mrh9VaKOTwa3WQI0h6Qw/edit",'+
		'            "title": "Canva Files"'+
		'        }'+
		'    ],'+
		'    "summary": "This is the Test Google Event",'+
		'    "description": "This is the Test Google Event",'+
		'    "organizer": {'+
		'        "displayName": "Engineering ki Pathshala",'+
		'        "email": "sfdcpanther@gmail.com"'+
		'    }'+
		'}';
		return fakeResponse;
	}

}