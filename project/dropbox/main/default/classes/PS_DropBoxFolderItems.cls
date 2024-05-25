/**
 * @description       : 
 * @author            : Amit Singh - PantherSchools
 * @group             : 
 * @last modified on  : 05-24-2024
 * @last modified by  : Amit Singh - PantherSchools
**/
public with sharing class PS_DropBoxFolderItems {
    public Entries[] entries;
	public String cursor;
	public boolean has_more;
	public class Entries {
		public String tag;
		public String name;
		public String path_lower;
		public String path_display;
		public String id;
	}
}