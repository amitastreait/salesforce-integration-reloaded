public with sharing class PS_AccountUtils {
    // PS_AccountUtils.createAccount('Ravi Grover', 'Hot');
    public static void createAccount(String name, String rating){
        sfdc_Config__mdt config = sfdc_Config__mdt.getInstance(System.Label.PS_SalesforceTokenLabel); // Use Custom Label
        if(config != null){

            Boolean isValid = PS_SalesforceTokenUtils.isValid(config);
            Map<String, Object> fieldWithValuesMap = new Map<String, Object>();
            String accessToken = config.accesstoken__c;
            if(!isValid){
                // config.accesstoken__c ~= Token Expired
                // Get the Access Token using Refresh Token
                fieldWithValuesMap = PS_SalesforceTokenUtils.refreshToken(config);
                accessToken = (String)fieldWithValuesMap.get('accesstoken__c');
            }

            String endpoint = config.instanceurl__c+'/services/data/v60.0/sobjects/Account';
            String requestBody = '{'+
            '    "Name": "'+name+'",'+
            '    "Rating": "'+rating+'",'+
            '    "Phone": "9876543210",'+
            '    "Industry": "Education",'+
            '    "Active__c": "Yes"'+
            '}';

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
                //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, ex.getMessage() ));
            }catch(System.Exception ex){
                //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, ex.getMessage() ));
            }
            /*
                TODO: Update The Custom Metadata with New Values
                ! Update the new Access Token
            */
            if(fieldWithValuesMap.size() >0 ){
                String fullName = 'sfdc_Config.'+System.Label.PS_SalesforceTokenLabel;
                String label = System.Label.PS_SalesforceTokenLabel;
                CreateUpdateMetadataUtils.createUpdateMetadata(fullName, label, fieldWithValuesMap);
            }
        }
    }
}