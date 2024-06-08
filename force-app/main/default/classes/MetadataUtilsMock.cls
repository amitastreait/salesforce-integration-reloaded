/**
 * @description       : 
 * @author            : Amit Singh - PantherSchools
 * @group             : 
 * @last modified on  : 06-08-2024
 * @last modified by  : Amit Singh - PantherSchools
**/
@IsTest
public with sharing class MetadataUtilsMock implements WebServiceMock {
    
    public void doInvoke(Object stub, Object soapRequest, Map<String,Object> responseMap, String endpoint,
        String soapAction, String requestName,
        String responseNamespace, String responseName, String responseType){
        if(soapRequest instanceof MetadataService.listMetadata_element ){
            MetadataService.listMetadataResponse_element response_x = new MetadataService.listMetadataResponse_element();
            responseMap.put('response_x', response_x);
        } else if(soapRequest instanceof MetadataService.readMetadata_element){
            MetadataService.Profile profile = new MetadataService.Profile();
            profile.fullName = 'Admin';
            
            MetadataService.ReadProfileResult result = new MetadataService.ReadProfileResult();
            result.records = new MetadataService.Profile[] { profile };
            
            MetadataService.readProfileResponse_element responseElement = new MetadataService.readProfileResponse_element();
            responseElement.result = result;
            
            responseMap.put('response_x', responseElement);
        } else if(soapRequest instanceof MetadataService.createMetadata_element){
            MetadataService.createMetadataResponse_element response_x = new MetadataService.createMetadataResponse_element();
            responseMap.put('response_x', response_x);
        }
        
    }
}