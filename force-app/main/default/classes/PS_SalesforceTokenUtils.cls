public with sharing class PS_SalesforceTokenUtils {
    
    public PageReference getAuthCode(){
        /*
            TODO: Get the Custom Metadata Record
        */

        sfdc_Config__mdt config = sfdc_Config__mdt.getInstance(System.Label.PS_SalesforceTokenLabel); // Use Custom Label
        if(config != null){

            List<String> codeVerifierChallenge = PS_PKCEAuthHelper.getDetails();
            //codeVerifierChallenge.get(0); code_verifier
            //codeVerifierChallenge.get(1); code_challenge

            String orgUrl  = config.Environment__c == 'Production' ? 'https://login.salesforce.com' : 'https://test.salesforce.com';

            System.System.debug( orgUrl );

            String redirect_uri = System.URL.getOrgDomainURL().toExternalForm()+'/apex/'+config.PageName__c;
            System.System.debug( redirect_uri );

            String authorizeUrl = orgUrl+config.authurl__c+'?client_id='+config.clientid__c
                            +'&redirect_uri='+redirect_uri+'&response_type=code'
                            +'&code_challenge='+codeVerifierChallenge.get(1);
            System.System.debug( authorizeUrl );

            // Insert the Custom Object code_verifier, code_challenge
            PKCEHelper__c helper = new PKCEHelper__c();
            helper.Active__c = true;
            helper.User__c = UserInfo.getUserId();
            helper.code_challenge__c = codeVerifierChallenge.get(1);
            helper.code_verifier__c  = codeVerifierChallenge.get(0);
            insert helper;

            return new PageReference(authorizeUrl);
        } else {
            return null;
        }
    }

    public void getAccessToken(){
        
        String code = ApexPages.currentPage().getParameters().get('code');
        System.debug(code);
        sfdc_Config__mdt config = sfdc_Config__mdt.getInstance(System.Label.PS_SalesforceTokenLabel); // Use Custom Label
        if(config != null){
            // Get the Custom Object code_verifier, code_challenge
            PKCEHelper__c helper = [SELECT Id, Name, code_verifier__c 
                                    FROM
                                        PKCEHelper__c 
                                    WHERE 
                                        User__c =: UserInfo.getUserId()
                                        AND Active__c = True
                                    LIMIT 1
                                ];

            String orgUrl  = config.Environment__c == 'Production' ? 'https://login.salesforce.com' : 'https://test.salesforce.com';
            String tokenUrl = orgUrl+config.tokenUrl__c;
            String redirect_uri = System.URL.getOrgDomainURL().toExternalForm()+'/apex/'+config.PageName__c;
            System.System.debug( redirect_uri );

            String requestBody = 'code='+code+'&grant_type=authorization_code&client_id='
                                +config.clientid__c+'&client_secret='+config.clientsecret__c
                                +'&redirect_uri='+redirect_uri+'&code_verifier='+helper.code_verifier__c;
            
            System.debug(requestBody);

            HttpRequest httpReq = new HttpRequest();
            httpReq.setEndpoint(tokenUrl);
            httpReq.setMethod('POST');
            httpReq.setBody(requestBody);
            httpReq.setHeader('Content-Type','application/x-www-form-urlencoded');
            httpReq.setHeader('Accept','application/json');

            Http http = new Http();
            try{
                HttpResponse httpRes = http.send(httpReq);
                if(httpRes.getStatusCode() == 200){
                    PS_SalesforceTokenWrapper wrapper = (PS_SalesforceTokenWrapper)System.JSON.deserialize(httpRes.getBody(), PS_SalesforceTokenWrapper.class);
                    /*
                        TODO: Deploy the Custom Metadata
                        ! How to to Deploy
                        Metadata is a NameSpace
                            CustomMetadata - Class
                            CustomMetadataValue - Class
                            Operations - Class
                            DeployCallback - Interface
                    */
                    String fullName = 'sfdc_Config.'+System.Label.PS_SalesforceTokenLabel;
                    String label = System.Label.PS_SalesforceTokenLabel;
                    Map<String, Object> fieldWithValuesMap = new Map<String, Object>();
                    fieldWithValuesMap.put('accesstoken__c', wrapper.access_token);
                    //fieldWithValuesMap.put('expires_in__c',wrapper.);
                    fieldWithValuesMap.put('expires_in_time__c', System.now().addHours(2) );
                    fieldWithValuesMap.put('instanceurl__c', wrapper.instance_url);
                    fieldWithValuesMap.put('refreshtoken__c', wrapper.refresh_token);
                    fieldWithValuesMap.put('scope__c',wrapper.scope);
                    fieldWithValuesMap.put('clientid__c',config.clientid__c);
                    fieldWithValuesMap.put('clientsecret__c',config.clientsecret__c);

                    System.debug('SUCCESS \n '+httpRes.getBody());
                    CreateUpdateMetadataUtils.createUpdateMetadata(fullName, label, fieldWithValuesMap);
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Successfull!'));
                    helper.Active__c = false;
                    // Success
                } else {
                    // 400
                    System.debug('ERROR \n '+ httpRes.getBody());
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, httpRes.getBody() ));
                    // error
                }
            }catch(System.CalloutException ex){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, ex.getMessage() ));
            }catch(System.Exception ex){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, ex.getMessage() ));
            }
        }
    }

    public static Boolean isValid(sfdc_Config__mdt config){
        Boolean isValid = true;
        if(config.expires_in_time__c < System.now()){
            isValid = false;
        }
        return isValid;
    }

    public static Map<String, Object> refreshToken(sfdc_Config__mdt config){
        String orgUrl  = config.Environment__c == 'Production' ? 'https://login.salesforce.com' : 'https://test.salesforce.com';
        String tokenUrl = orgUrl+config.tokenUrl__c;
        
        String requestBody = 'grant_type=refresh_token&client_id='+config.clientid__c
                            +'&client_secret='+config.clientsecret__c+'&refresh_token='+config.refreshtoken__c;
        
        System.debug(requestBody);
        HttpRequest httpReq = PS_CalloutUtils.prepareRequest(tokenUrl,'POST',requestBody,'application/json', 'application/x-www-form-urlencoded');
        Map<String, Object> fieldWithValuesMap = new Map<String, Object>();
        try{
            HttpResponse httpRes = (new Http()).send(httpReq);
            if(httpRes.getStatusCode() == 200 || httpRes.getStatusCode() == 201 ){
                PS_SalesforceTokenWrapper wrapper = (PS_SalesforceTokenWrapper)System.JSON.deserialize(httpRes.getBody(), PS_SalesforceTokenWrapper.class);
                fieldWithValuesMap.put('accesstoken__c', wrapper.access_token);
                fieldWithValuesMap.put('expires_in_time__c', System.now().addHours(2) );
                //CreateUpdateMetadataUtils.createUpdateMetadata(fullName, label, fieldWithValuesMap);
            }else{
                
            }
        }catch(System.CalloutException ex){
            
        }catch(System.Exception ex){
            
        }
        return fieldWithValuesMap;
    }
}