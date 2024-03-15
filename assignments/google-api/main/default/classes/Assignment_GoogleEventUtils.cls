public with sharing class Assignment_GoogleEventUtils {
    
    //Assignment_GoogleEventUtils.createGoogleEvent();
    public static void createGoogleEvent(){
        Google_Config__mdt config = Google_Config__mdt.getInstance(System.Label.PS_GoogleTokenLabel); // Use Custom Label
        if(config != null){

            Boolean isValid = Assignment_GoogleAPITokenUtils.isValid(config);
            Map<String, Object> fieldWithValuesMap = new Map<String, Object>();
            String accessToken = config.access_token__c;
            if(!isValid){
                fieldWithValuesMap = Assignment_GoogleAPITokenUtils.refreshToken(config);
                accessToken = (String)fieldWithValuesMap.get('access_token__c');
            }

            String endpoint = config.Event_Url__c;
            endpoint = endpoint.replace('{calendar_email}', System.Label.PS_CalendarEmail);
            /**
             * ! Create the wrapper of the event class
             */
            Assignment_GoogleEventInputWrapper wrapper = new Assignment_GoogleEventInputWrapper();
            wrapper.summary = 'Salesforce Integration Course';
            wrapper.description = 'This event is created from the Salesforce Apex Using the Google Calendar API!';
            wrapper.location = 'Tokyo';

            /* 
                ! Prepare the Organizer of the event 
            */
            wrapper.organizer = new Assignment_GoogleEventInputWrapper.organizer();
            wrapper.organizer.displayName = 'Amit Singh';
            wrapper.organizer.email = System.Label.PS_CalendarEmail;

            /**
             * ! Prepare the Event Start Date/DateTime
            */
            wrapper.start = new Assignment_GoogleEventInputWrapper.EventStart();
            wrapper.start.date_x = '2024-04-05';
            /**
             * !Prepare the Event End Date/DateTime
            */
            wrapper.end_x = new Assignment_GoogleEventInputWrapper.EventEnd();
            wrapper.end_x.date_x = '2024-04-06';
            /** 
             * ! If you want to use Date Time then you need to format the DateTime in 2024-03-14T02:29:11-02:29 format.
             * ! Using format method of DateTime Class in Salesforce. Example below 
             * String formattedString = System.now().format('yyyy-MM-dd\'T\'HH:mm:ss-HH:mm');
             * System.debug(formattedString);
             */ 
            
            /**
             * !Prepare the Attachments which are requred for the event 
            */
            wrapper.attachments = new List<Assignment_GoogleEventInputWrapper.attachments>();

            Assignment_GoogleEventInputWrapper.attachments attachment = new Assignment_GoogleEventInputWrapper.attachments();

            attachment.fileUrl = 'https://docs.google.com/document/d/1HZewqXUogDemO7epcQlqSkSQa0jhBeBTy1g5lZ2fb-Y/edit?usp=sharing';
            attachment.title = 'Salesforce Integration Notes!';
            
            /* 
                TODO: Add the files to the event 
            */
            wrapper.attachments.add(attachment);
            
            /**
             * !Prepare the Attendees which are needed for the event 
            */
            wrapper.attendees = new List<Assignment_GoogleEventInputWrapper.attendees>();

            Assignment_GoogleEventInputWrapper.attendees attendee = new Assignment_GoogleEventInputWrapper.attendees();
            attendee.displayName = 'Panther Schools';
            attendee.email = System.Label.PS_AttendeeEmail;

            /* 
                TODO: Add attendee to the event 
            */
            wrapper.attendees.add(attendee);
            
            String requestBody = JSON.serialize(wrapper)
                                    .replaceAll('end_x','end')
                                    .replaceAll('dateTime_x','dateTime')
                                    .replaceAll('date_x','date');
            System.debug( requestBody );

            HttpRequest httpReq = PS_CalloutUtils.prepareRequest(endpoint,'POST',requestBody,'application/json', 'application/json');
            httpReq.setHeader('Authorization', 'Bearer '+accessToken);
            try{
                HttpResponse httpRes = (new Http()).send(httpReq);
                if(httpRes.getStatusCode() == 200 || httpRes.getStatusCode() == 201 ){
                    System.debug('Success \n '+ httpRes.getBody() );
                }else{
                    System.debug('ERROR \n '+ httpRes.getBody() );
                }
            }catch(System.CalloutException ex){
                
            }catch(System.Exception ex){
                
            }
            /*
                TODO: Update The Custom Metadata with New Values
                ! Update the new Access Token
            */
            if(fieldWithValuesMap.size() >0 ){
                String fullName = 'Google_Config.'+System.Label.PS_GoogleTokenLabel;
                String label = System.Label.PS_GoogleTokenLabel;
                CreateUpdateMetadataUtils.createUpdateMetadata(fullName, label, fieldWithValuesMap);
            }
        }
    }
}