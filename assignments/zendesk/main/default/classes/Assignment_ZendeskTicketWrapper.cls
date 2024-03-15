public with sharing class Assignment_ZendeskTicketWrapper {
    public ticket ticket;
	public class ticket {
		public String url;
		public Integer id;
		public String created_at;
		public String updated_at;
		public String type;
		public String subject;
		public String raw_subject;
		public String description;
		public String priority;
		public String status;
		public String requester_id;
		public String submitter_id;
		public String assignee_id;
		public String organization_id;
		public String group_id;
	}
}