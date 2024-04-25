/**
 * @description       : 
 * @author            : Amit Singh - PantherSchools
 * @group             : 
 * @last modified on  : 04-20-2024
 * @last modified by  : Amit Singh - PantherSchools
**/
public with sharing class PS_QBTokenUtil {
    /** Prepare the Auth Url */
    public PageReference authorize(){
        /** Get the config from the Custom Metadta */
        qb_Metadata__mdt config = qb_Metadata__mdt.getInstance('QBToken');
        if(config !=null){
            // https://integration-org2-dev-ed--c.develop.vf.force.com/apex/PS_QuickBooksToken
            String redirect_uri = System.URL.getOrgDomainURL().toExternalForm()+'/apex/'+config.PageName__c;
            System.System.debug( redirect_uri );
            // https://integration-org2-dev-ed.develop.my.salesforce.com/apex/PS_QuickBooksToken
            /* 
                https://appcenter.intuit.com/connect/oauth2?
                client_id=Q3ylJatCvnkYqVKLmkxxxxxxxxxxxxxxxkYB36b5mws7HkKUEv9aI&response_type=code&
                scope=com.intuit.quickbooks.accounting&
                redirect_uri=https://www.mydemoapp.com/oauth-redirect&
                state=security_token%3D138r5719ru3e1%26url%3Dhttps://www.mydemoapp.com/oauth-redirect
            */
            
            String authorizeUrl = config.auth_url__c+'?client_id='+config.Client_Id__c+'&response_type=code'
                            +'&scope=openid profile email com.intuit.quickbooks.accounting com.intuit.quickbooks.payment'
                            +'&redirect_uri='+redirect_uri+'&state='+UserInfo.getOrganizationId()+redirect_uri;
                            
            System.System.debug( authorizeUrl );
            return new PageReference(authorizeUrl);
        }else{
            // Show the Error
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, 'Config not found' ));
            return null;
        }
    }
    /** Get the Access Token and Store into Metadata */
    public static void get_accessToken(){

        // https://integration-org2-dev-ed--c.develop.vf.force.com/apex/PS_QuickBooksToken?
        //code=AB11712461984Hf0QnBcF20niOWQjxnRlnnH1xNowVdBkpk0Hd
        //&state=00DHu000003NXeOMAWhttps%3A%2F%2Fintegration-org2-dev-ed.develop.my.salesforce.com%2Fapex%2FPS_QuickBooksToken
        //&realmId=9341452084525746

        /** Get the config from the Custom Metadta */
        qb_Metadata__mdt config = qb_Metadata__mdt.getInstance('QBToken');
        if(config !=null){
            String code    = ApexPages.currentPage().getParameters().get('code');
            String realmId = ApexPages.currentPage().getParameters().get('realmId');
            
            String redirect_uri = System.URL.getOrgDomainURL().toExternalForm()+'/apex/'+config.PageName__c;
            System.System.debug( redirect_uri );

            HttpRequest httReq = new HttpRequest();
            httReq.setMethod('POST');
            httReq.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            httReq.setHeader('Accept', 'application/json');
            httReq.setEndpoint(config.token_url__c);
            /*
                grant_type=authorization_code&
                code=L3114709614564VSU8JSEiPkXx1xhV8D9mv4xbv6sZJycibMUI&
                redirect_uri=https://www.mydemoapp.com/oauth-redirect
            */
            String tokenBody = 'grant_type=authorization_code&code='+code+'&redirect_uri='+redirect_uri
                            +'&client_id='+config.Client_Id__c+'&client_secret='+config.Client_Secret__c;
            httReq.setBody(tokenBody);

            try {
                HttpResponse httpRes = (new Http()).send(httReq);
                if(httpRes.getStatusCode() == 200 || httpRes.getStatusCode() == 201){
                    // Parse the Response
                    /**
                     * {
                            "token_type": "bearer",
                            "expires_in": 3600,
                            "refresh_token":"Q311488394272qbajGfLBwGmVsbF6VoNpUKaIO5oL49aXLVJUB",
                            "x_refresh_token_expires_in":15551893,
                            "access_token":"eJlb"
                        }
                     */
                    Map<String, Object> fieldWithValuesMap = prepareMetadata(httpRes.getBody(),'');
                    String fullName = 'qb_Metadata.QBToken';
                    String label    = 'QBToken';
                    // Deploy/Update the Custom Metadata
                    CreateUpdateMetadataUtils.createUpdateMetadata(fullName, label, fieldWithValuesMap);
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Successfull!'));
                }else{
                    System.debug(httpRes.getBody());
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, httpRes.getBody() ));
                }
            }catch (CalloutException ex) {
                System.debug(ex);
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, ex.getMessage() ));
            }catch (Exception ex) {
                System.debug(ex);
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, ex.getMessage() ));
            }
        }else{
            // Show the Error
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, 'Config not found' ));
        }
    }

    public static Boolean isValid(qb_Metadata__mdt config){
        Boolean isValid = true;
        if(config.expires_in_time__c <= System.now()){
            isValid = false;
        }
        return isValid;
    }

    public static Map<String, Object> refreshToken(qb_Metadata__mdt config){
        
        String tokenUrl = config.token_url__c;
        
        String requestBody = 'grant_type=refresh_token&client_id='+config.client_id__c
                            +'&client_secret='+config.client_secret__c+'&refresh_token='+config.refresh_token__c;
        
        System.debug(requestBody);
        HttpRequest httpReq = PS_CalloutUtils.prepareRequest(tokenUrl,'POST',requestBody,'application/json', 'application/x-www-form-urlencoded');
        Map<String, Object> fieldWithValuesMap = new Map<String, Object>();
        try{
            HttpResponse httpRes = (new Http()).send(httpReq);
            if(httpRes.getStatusCode() == 200 || httpRes.getStatusCode() == 201 ){
                fieldWithValuesMap = prepareMetadata(httpRes.getBody(),'');
            }else{
                
            }
        }catch(System.CalloutException ex){
            
        }catch(System.Exception ex){
            
        }
        return fieldWithValuesMap;
    }

    public static Map<String, Object> prepareMetadata(String requestBody, String realmId){
        Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(requestBody);
        String access_token  = (String)responseMap.get('access_token');
        String refresh_token = (String)responseMap.get('refresh_token');
        Integer expires_in   = (Integer)responseMap.get('expires_in');
        
        Map<String, Object> fieldWithValuesMap = new Map<String, Object>();
        fieldWithValuesMap.put('access_token__c', access_token);
        fieldWithValuesMap.put('expires_in__c',expires_in);
        fieldWithValuesMap.put('expires_in_time__c', System.now().addSeconds(expires_in) );
        fieldWithValuesMap.put('refresh_token__c', refresh_token);
        if(!String.isBlank(realmId)){
            fieldWithValuesMap.put('realmId__c', realmId);
        }
        return fieldWithValuesMap;
    }
}