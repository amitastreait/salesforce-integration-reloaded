/**
 * @description       : 
 * @author            : Amit Singh - PantherSchools
 * @group             : 
 * @last modified on  : 06-14-2024
 * @last modified by  : Amit Singh - PantherSchools
**/
public without sharing class CourseDetailService {
    
    @AuraEnabled(cacheable=true)
    public static sObject getCourseDetails(String recordId){
        try {
            return [SELECT Id, Name, Course__c, Course__r.Course_Cost__c,Course__r.Category__c,
                        Course__r.CourseCode__c, Course__r.Course_Duration__c,
                        Start_Date_Time__c, End_Date_Time__c, Trainer__r.Name,
                        EnableRSVP__c, BookingUrl__c, Thumbnail__c, 
                        Max_Seat__c, Mode__c, Status__c, TotalBooking__c,
                        Course__r.CourseDescription__c, Course__r.What_you_will_learn__c,
                        Course__r.Requirements__c, Course__r.Materials_Included__c,
                        Course__r.WhoisthisCourseFor__c, Course__r.Subheading__c,
                        Course__r.Why_You_Should_Attend_the_Course__c,
                        Course__r.LearnRightSection__c, Course__r.IncludedRightSection__c
                    FROM
                        ScheduledCourse__c 
                    WHERE
                        Id =: recordId
                ];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}