/**
 * @description       : 
 * @author            : Amit Singh - PantherSchools
 * @group             : 
 * @last modified on  : 06-13-2024
 * @last modified by  : Amit Singh - PantherSchools
**/
public without sharing class CourseListService {

    @AuraEnabled(cacheable=true)
    public static List<sObject> listCourses(){
        try {
            List<ScheduledCourse__c> courseList = [SELECT Id, Name, Course__c, Course__r.Course_Cost__c,Course__r.Category__c,
                            Course__r.CourseCode__c, Course__r.Course_Duration__c,
                            Start_Date_Time__c, End_Date_Time__c, Trainer__c,
                            EnableRSVP__c, BookingUrl__c, Thumbnail__c, 
                            Max_Seat__c, Mode__c, Status__c, Training_Center__c, Zoom_Link__c, TotalBooking__c 
                        FROM
                            ScheduledCourse__c 
                        WHERE
                            Status__c = 'Confirmed'
                    ];
            return courseList;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}