/**
 * @description       : 
 * @author            : Amit Singh - PantherSchools
 * @group             : 
 * @last modified on  : 04-25-2024
 * @last modified by  : Amit Singh - PantherSchools
**/
public class EventTriggerHandler {

    @future(callout = true)
    public static void createEventInGoogle(Id eventId){
        List<Event> eventList = [Select Id, StartDateTime, EndDate, EndDateTime, OwnerId, Subject 
                                 From Event Where Id = :eventId];
        if(!eventList.isEmpty()){
            Event eve = eventList.get(0);
            String email = [SELECT Email from User Where Id =: eve.OwnerId ].Email;

            String requestBody = '{'+
            '  "attendees": ['+
            '    {'+
            '      "email": "'+email+'"'+
            '    }'+
            '  ],'+
            '  "end": {'+
            '    "dateTime": "'+eve.EndDateTime.format('yyyy-MM-dd\'T\'HH:mm:ss-HH:mm')+'"'+
            '  },'+
            '  "reminders": {'+
            '    "useDefault": true'+
            '  },'+
            '  "start": {'+
            '    "dateTime": "'+eve.StartDateTime.format('yyyy-MM-dd\'T\'HH:mm:ss-HH:mm')+'"'+
            '  },'+
            '  "summary": "'+eve.Subject+'",'+
            '  "location": "Udemy.com Online Platform."'+
            '}';             
            GC_Events.createGoogleEvent(requestBody);
        }
    }
}