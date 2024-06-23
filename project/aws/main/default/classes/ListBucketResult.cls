/**
 * @description       : 
 * @author            : Amit Singh - PantherSchools
 * @group             : 
 * @last modified on  : 06-23-2024
 * @last modified by  : Amit Singh - PantherSchools
**/
public with sharing class ListBucketResult {
    public String name;
    public List<Contents> items;

    public class Contents {
        public String key;
        public String size;
    }
}