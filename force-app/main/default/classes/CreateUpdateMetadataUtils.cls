/* 
    ? Use Metadata Name space to deploy/update the Custom Metadat Record.
    TODO: Using Metadata.DeployCallback interface
*/
public class CreateUpdateMetadataUtils implements Metadata.DeployCallback {
    public static final String JOB_ID = 'a0I0o00001MbaBJ';

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
    }
    
    public static void createUpdateMetadata(String fullName, String label, Map<String, Object> fieldWithValuesMap){

        /* Step1 - Create the Custom Metadata Object from Metadata NameSpace */
        Metadata.CustomMetadata customMetadata =  new Metadata.CustomMetadata();
        customMetadata.fullName = fullName; // sfdc_Config.PS_SalesforceToken
        // API Name - Custom metadata Record
        customMetadata.label 	= label; // 'Salesforce Token'
        
        for(String key : fieldWithValuesMap.keySet()){

            /* Step2 - Create the CustomMetadataValue Object from Metadata NameSpace */
            Metadata.CustomMetadataValue customField = new Metadata.CustomMetadataValue();

            /* Step2.1 - Prepare the field values */
            customField.field = key;
            customField.value = fieldWithValuesMap.get(key); 

            /* Step2.2 - Add the field values to the custom metadata */
            customMetadata.values.add(customField);
        }

        /* Step3 - Create the DeployContainer Object from Metadata NameSpace */
        Metadata.DeployContainer mdContainer = new Metadata.DeployContainer();

        /* Step4 - Add the metadata under container */
        mdContainer.addMetadata(customMetadata);
        
        /* 
            Step5
            TODO: Deploy the metadata if test is not running using Operations  
         */
        Id jobId = Metadata.Operations.enqueueDeployment(mdContainer, new CreateUpdateMetadataUtils());
    }
}