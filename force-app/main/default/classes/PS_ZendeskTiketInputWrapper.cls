/**
 * @description       : 
 * @author            : Amit Singh - PantherSchools
 * @group             : 
 * @last modified on  : 03-17-2024
 * @last modified by  : Amit Singh - PantherSchools
**/
public with sharing class PS_ZendeskTiketInputWrapper {
    
    public ticket ticket;

	public class ticket {
		public String subject;
		public String priority;
		public String type;
		public comment comment;
		public String assignee_id;
		public requester requester;
	}
	public class comment {
		public String body;
	}

	public class requester {
		public Integer locale_id;
		public String name;
		public String email;
	}
}