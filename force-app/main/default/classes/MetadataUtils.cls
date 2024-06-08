/**
 * @description       : 
 * @author            : Amit Singh - PantherSchools
 * @group             : 
 * @last modified on  : 06-08-2024
 * @last modified by  : Amit Singh - PantherSchools
**/
public with sharing class MetadataUtils {
    
    public static String getSessionId(){
        String sessionId = '';
        PageReference sessionPage = Page.SessionId;
        String vfContent = sessionPage.getContent().toString();
        /*String tempSessionId = vfContent.substringAfter('Start_Of_Session_Id');
        sessionId = tempSessionId.substringBeforeLast('End_Of_Session_Id');*/
        Integer startP = vfContent.indexOf('Start_Of_Session_Id') + 'Start_Of_Session_Id'.length();
        Integer endP   = vfContent.indexOf('End_Of_Session_Id');
        sessionId      = vfContent.substring(startP, endP);
        return sessionId;
    }

    public static MetadataService.MetadataPort createService() {
        MetadataService.MetadataPort service = new MetadataService.MetadataPort();
        service.SessionHeader = new MetadataService.SessionHeader_element();
        service.SessionHeader.sessionId = Test.isRunningTest() == True ? UserInfo.getSessionId() : getSessionId();
        return service;
    }

    // MetadataUtils.listMetadata();
    public static void listMetadata(){
        MetadataService.MetadataPort service = createService();

        List<MetadataService.ListMetadataQuery> queries = new List<MetadataService.ListMetadataQuery>();
        
        MetadataService.ListMetadataQuery query = new MetadataService.ListMetadataQuery();
        query.type_x = 'CustomObject';

        MetadataService.ListMetadataQuery query_profile = new MetadataService.ListMetadataQuery();
        query_profile.type_x = 'Profile';
        
        queries.add(query);
        queries.add(query_profile);

        List<MetadataService.FileProperties> properties = service.listMetadata(queries, 60);
        System.debug(System.JSON.serializePretty(properties));
    }
    // MetadataUtils.readMetadata();
    public static void readMetadata(){
        MetadataService.MetadataPort service = createService();
        List<String> itemList = new String[] { 'Admin' };
        //itemList.add();

        /*
            MetadataService.IReadResult result = service.readMetadata('Profile', itemList);
            MetadataService.Profile profileDetails = (MetadataService.Profile) result.getRecords().get(0);
        */
        MetadataService.Profile profileDetails = (MetadataService.Profile)
                            service.readMetadata('Profile', itemList).getRecords()[0];
        //System.debug(System.JSON.serializePretty(profileDetails));
        MetadataService.ProfileLoginHours loginHours = profileDetails.loginHours;
        MetadataService.ProfileLoginIpRange[] loginIpRanges = profileDetails.loginIpRanges;
        System.debug(' loginHours \n '+loginHours);
        System.debug(' loginIpRanges \n '+loginIpRanges);
    }

    // MetadataUtils.createObject();
    public static void createObject(String label, String pluralLabel){
        MetadataService.MetadataPort service = createService();
        MetadataService.CustomObject customObject = new MetadataService.CustomObject();
        customObject.label = label;
        customObject.pluralLabel = pluralLabel;
        customObject.fullName = label.deleteWhitespace()+'__c';
        customObject.enableHistory = true;
        customObject.enableActivities = true;
        customObject.enableSearch = true;
        customObject.enableReports = true;

        MetadataService.CustomField nameField = new MetadataService.CustomField();
        nameField.type_x = 'Text';
        nameField.label = 'Stripe Invoice ID';

        customObject.deploymentStatus = 'Deployed';
        customObject.sharingModel = 'ReadWrite';
        
        customObject.nameField = nameField;

        List<MetadataService.Metadata> customObjectList = new List<MetadataService.Metadata>();
        customObjectList.add(customObject);

        List<MetadataService.SaveResult> saveResult = service.createMetadata(customObjectList);
        System.debug(System.JSON.serializePretty(saveResult));
    }

    // MetadataUtils.createFields();
    public static void createFields(String objectApiName, String fielLabel){

        MetadataService.MetadataPort service     = createService();

        MetadataService.CustomField customField = new MetadataService.CustomField();
        // ObjectApiName.FieldApiName // Stripe UUID - StripeUUID
        customField.fullName         = objectApiName+'.'+fielLabel.deleteWhitespace()+'__c'; // Account - Active => Account.Active__c
        customField.label            = fielLabel;
        customField.type_x           = 'Text';
        customField.description      = 'This is the field created from Salesforce Metadata API';
        customField.inlineHelpText   = 'This is the field created from Salesforce Metadata API';
        customField.length           = 120;
        customField.required         = false;
        customField.unique           = false;
        customField.externalId       = true;
        //customField.defaultValue     = '"904242"';
        //customField.caseSensitive    = true;
        List<MetadataService.Metadata> metadata = new List<MetadataService.Metadata>();
        metadata.add(customField);
        List<MetadataService.SaveResult> results = service.createMetadata( metadata );
        System.debug(System.JSON.serializePretty(results));
    }
    // MetadataUtils.createLookupFields();
    public static void createLookupFields(){
        
        MetadataService.MetadataPort service     = createService();
        MetadataService.CustomField customField = new MetadataService.CustomField();
        customField.fullName                    = 'StripeInvoice__c.StripeCustomer__c';
        customField.label                       = 'Stripe Customer';
        customField.type_x                      = 'Lookup'; // Lookup // MasterDetail
        customField.description                 = 'This is the Lookup field related to Account Object';
        customField.inlineHelpText              = 'This is the Lookup field related to Account Object';
        customField.relationshipLabel           = 'Stripe Invoices';
        customField.relationshipName            = 'StripeInvoices';
        customField.referenceTo                 = 'Account';
        
        List<MetadataService.SaveResult> results = service.createMetadata( new MetadataService.Metadata[] { customField } );
        System.debug(System.JSON.serializePretty(results));
    }
    /*
        List<String> options = new List<String>{
            'Open',
            'Closed',
            'Paid',
            'Voided',
            'Part-Paid'
        };
        MetadataUtils.createPicklistField(options);
    */
    public static void createPicklistField(List<String> options){
        
        MetadataService.MetadataPort service     = createService();

        MetadataService.CustomField customField = new MetadataService.CustomField();

        customField.fullName         = 'StripeInvoice__c.InvoiceStatus__c';
        customField.label            = 'Invoice Status';
        customField.type_x           = 'Picklist';
        customField.description      = 'This is the picklist field created from Salesforce Metadata API';
        customField.inlineHelpText   = 'This is the picklist field created from Salesforce Metadata API';
        
        MetadataService.ValueSet valueSetDef          = new MetadataService.ValueSet();
        
        MetadataService.ValueSetValuesDefinition valueDefinition = new MetadataService.ValueSetValuesDefinition();
        
        List<MetadataService.CustomValue> values      = new List<MetadataService.CustomValue>();        
        for(String value : options){
            MetadataService.CustomValue customValue = new MetadataService.CustomValue();
            customValue.fullName  = value; 
            customValue.default_x = false;
            customValue.isActive  = true;
            customValue.label     = value;
            values.add(customValue);
        }
        valueDefinition.value              = values;
        valueDefinition.sorted             = true;
        
        valueSetDef.valueSetDefinition  = valueDefinition;
        valueSetDef.restricted          = true;
        
        customField.valueSet            = valueSetDef;
        customField.required            = true;
        List<MetadataService.SaveResult> results = service.createMetadata( new MetadataService.Metadata[] { customField } );
        System.debug(System.JSON.serializePretty(results));
        handleSaveResults(results.get(0));
    }
    /*
        List<String> names = new List<String>{'PS_ZoomToken'};
        MetadataUtils.deleteMetadataRecord('Google_Config', names);
    */
    public static void deleteMetadataRecord(String metadataType, List<String> names){
        MetadataService.MetadataPort service = createService();
        // MetadataObjectName.RecordName
        // Google_Config.PS_ZoomToken
        List<String> recordsToDelete = new List<String>();
        for(String name : names){
            recordsToDelete.add(metadataType+'.'+name);
        }
        MetadataService.DeleteResult[] deleteResults = service.deleteMetadata('CustomMetadata', recordsToDelete); //250
        handleDeleteResults(deleteResults.get(0));
    }

    public class MetadataServiceExamplesException extends Exception { }
    public static void handleSaveResults(MetadataService.SaveResult saveResult){
        // Nothing to see?
        if(saveResult==null || saveResult.success)
            return;
        // Construct error message and throw an exception
        System.debug(' saveResult.errors \n '+saveResult.errors);
        if(saveResult.errors!=null){
            List<String> messages = new List<String>();
            messages.add(
                (saveResult.errors.size()==1 ? 'Error ' : 'Errors ') +
                'occured processing component ' + saveResult.fullName + '.');
            for(MetadataService.Error error : saveResult.errors) {
                messages.add(
                    error.message + ' (' + error.statusCode + ').' +
                    ( error.fields!=null && error.fields.size()>0 ?
                     ' Fields ' + String.join(error.fields, ',') + '.' : '' ) );
            }
            if(messages.size()>0)
                throw new MetadataServiceExamplesException(String.join(messages, ' '));
            
            System.debug(' Message  '+String.join(messages, ' '));
        }
        if(!saveResult.success)
            throw new MetadataServiceExamplesException('Request failed with no specified error.');
    }
    
    
    public static void handleDeleteResults(MetadataService.DeleteResult deleteResult){
        // Nothing to see?
        if(deleteResult==null || deleteResult.success)
            return;
        // Construct error message and throw an exception
        if(deleteResult.errors!=null){
            List<String> messages = new List<String>();
            messages.add(
                (deleteResult.errors.size()==1 ? 'Error ' : 'Errors ') +
                'occured processing component ' + deleteResult.fullName + '.');
            for(MetadataService.Error error : deleteResult.errors)
                messages.add(
                    error.message + ' (' + error.statusCode + ').' +
                    ( error.fields!=null && error.fields.size()>0 ?
                     ' Fields ' + String.join(error.fields, ',') + '.' : '' ) );
            if(messages.size()>0)
                throw new MetadataServiceExamplesException(String.join(messages, ' '));
        }
        if(!deleteResult.success)
            throw new MetadataServiceExamplesException('Request failed with no specified error.');
    }
    
    
    public static void handleUpsertResults(MetadataService.UpsertResult upsertResult){
        // Nothing to see?
        if(upsertResult==null || upsertResult.success)
            return;
        // Construct error message and throw an exception
        if(upsertResult.errors!=null){
            List<String> messages = new List<String>();
            messages.add(
                (upsertResult.errors.size()==1 ? 'Error ' : 'Errors ') +
                'occured processing component ' + upsertResult.fullName + '.');
            for(MetadataService.Error error : upsertResult.errors)
                messages.add(
                    error.message + ' (' + error.statusCode + ').' +
                    ( error.fields!=null && error.fields.size()>0 ?
                     ' Fields ' + String.join(error.fields, ',') + '.' : '' ) );
            if(messages.size()>0)
                throw new MetadataServiceExamplesException(String.join(messages, ' '));
        }
        if(!upsertResult.success)
            throw new MetadataServiceExamplesException('Request failed with no specified error.');
    }

}