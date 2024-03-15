public with sharing class Assignment_DeployMetadataUtils implements Metadata.DeployCallback {
    public static final String JOB_ID = 'a0I0o00001MbaBJ';
    @TestVisible
    private static MetadataDeploymentResult__e[] eventsToPublish = new MetadataDeploymentResult__e[]{};

    public void handleResult(Metadata.DeployResult result, Metadata.DeployCallbackContext context) {
        if (result.status == Metadata.DeployStatus.Succeeded) {
            /* 
                TODO : Fire the Platform Event or Log the Success 
            */
            System.debug(' success : 😍 '+ result);
        } else {
            /* 
                TODO : Fire the Platform Event or Log the Error Message 
            */
            System.debug(' fail : 🥵 '+ result);
        }
        MetadataDeploymentResult__e deployResultEvent = new MetadataDeploymentResult__e(
            JobId__c        = result.id,
            Status__c       = String.valueOf(result.status).toLowerCase(),
            Payload__c      = JSON.serialize(result.details),
            ErrorMessage__c = result.errorMessage
        );
        eventsToPublish.add(deployResultEvent);
        publishEvents(eventsToPublish);
    }

    private static void publishEvents(List<MetadataDeploymentResult__e> eventsToPublish) {
        List<Database.SaveResult> results = EventBus.publish(eventsToPublish);
        Database.SaveResult sr = results[0];
        if(!sr.isSuccess()) {
            String error = 'Error firing MetadataDeploymentResult__e event.\n' + JSON.serialize(sr.getErrors());
            System.debug(error);
            throw createCustomException(error);
        }
    }

    private static CustomException createCustomException(String error) {
        CustomException ex = new CustomException(error);
        ex.setMessage(error);
        return ex;
    }

    private static void createAuraHandledException(String errorMessage){
        throw new AuraHandledException(errorMessage);
    }

    public class CustomException extends Exception {}

    public class FieldAccessException extends Exception {}
    
    public static Metadata.CustomMetadata prepareMetadata(String fullName, String label, Map<String, Object> fieldWithValuesMap){

        /* Step1 - Create the Custom Metadata Object from Metadata NameSpace */
        Metadata.CustomMetadata customMetadata =  new Metadata.CustomMetadata();
        customMetadata.fullName = fullName;
        customMetadata.label 	= label;
        
        for(String key : fieldWithValuesMap.keySet()){

            /* Step2 - Create the CustomMetadataValue Object from Metadata NameSpace */
            Metadata.CustomMetadataValue customField = new Metadata.CustomMetadataValue();

            /* Step2.1 - Prepare the field values */
            customField.field = key;
            customField.value = fieldWithValuesMap.get(key); 

            /* Step2.2 - Add the field values to the custom metadata */
            customMetadata.values.add(customField);
        }
        return customMetadata;
    }

    @AuraEnabled
    public static void manageRecords(List< Map<String, Object> > records){
        try {
            System.debug(JSON.serializePretty(records));
            /* Step3 - Create the DeployContainer Object from Metadata NameSpace */
            Metadata.DeployContainer mdContainer = new Metadata.DeployContainer();

            for(Map<String, Object> record : records){
                String label = (String)record.get('MasterLabel');
                record.remove('MasterLabel');
                /* Step1 - Create the Custom Metadata Object from Metadata NameSpace */
                Metadata.CustomMetadata customMetadata = prepareMetadata('Country.'+label.replaceAll(' ',''), label, record);
                /* Step4 - Add the metadata under container */
                mdContainer.addMetadata(customMetadata);
            }
            
            /* 
                Step5
                TODO: Deploy the metadata if test is not running using Operations  
            */
            Id jobId = Metadata.Operations.enqueueDeployment(mdContainer, new CreateUpdateMetadataUtils());
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<Country__mdt> getAllRecords(){
        try {
            List<Country__mdt> countriesRecords = Country__mdt.getAll().values();
            return countriesRecords;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}