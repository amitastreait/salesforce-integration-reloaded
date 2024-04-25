/**
 * @description       : 
 * @author            : Amit Singh - PantherSchools
 * @group             : 
 * @last modified on  : 04-20-2024
 * @last modified by  : Amit Singh - PantherSchools
**/
public with sharing class QB_Customers {
    // QB_Customers.testCreateCustomer();
    public static void testCreateCustomer(){
        QB_CustomerInput customer = new QB_CustomerInput();
        customer.CompanyName = 'PantherSchools.com';
        customer.DisplayName = 'PantherSchools.com';
        customer.FamilyName = 'Singh';
        customer.FullyQualifiedName = 'PantherSchools.com-Amit-Singh';
        customer.GivenName = 'Amit';
        customer.MiddleName = '';
        customer.Notes = 'Testing from Apex Class';
        customer.Suffix = 'Jr.';
        customer.Title = 'Mr';

        /* Prepare PrimaryEmailAddr */
        QB_CustomerInput.PrimaryEmailAddr email = new QB_CustomerInput.PrimaryEmailAddr();
        email.Address = 'asingh@zmail.com';
        /*
            "PrimaryEmailAddr": {
                "Address": "{{$randomEmail}}"
            }
        */
        customer.PrimaryEmailAddr = email;

        /* Prepare PrimaryPhone */
        QB_CustomerInput.PrimaryPhone phone = new QB_CustomerInput.PrimaryPhone();
        phone.FreeFormNumber = '987653210';
        customer.PrimaryPhone = phone;

        /* Prepare BillAddr */

        createCustomer(customer);
    }

    public static void createCustomer(QB_CustomerInput customer){

        /** Get the config from the Custom Metadta */
        List<qb_Metadata__mdt> configList = [SELECT Id, DeveloperName, MasterLabel,  Environment__c, Prod_Base_URL__c, Sanbdox_Base_URL__c,
                                        access_token__c, auth_url__c, expires_in__c, expires_in_time__c, minorversion__c, 
                                        realmId__c, refresh_token__c, token_type__c, token_url__c 
                                        FROM qb_Metadata__mdt 
                                        WHERE DeveloperName = 'QBToken' 
                                        LIMIT 1]; // Token Details Are Stored Here...
        if(configList?.size() > 0){
            qb_Metadata__mdt config = configList.get(0);
            System.debug(config.access_token__c);
            String accessToken = config.access_token__c;
            System.debug(accessToken);
            Boolean isValid = PS_QBTokenUtil.isValid(config);
            Map<String, Object> fieldWithValuesMap;

            if(isValid == false){ // Token is Expired
                // Refresh the Token
                fieldWithValuesMap = PS_QBTokenUtil.refreshToken(config);
                accessToken = (String)fieldWithValuesMap.get('access_token__c'); // null/blank
            }

            //System.debug(JSON.serializePretty(fieldWithValuesMap));

            HttpRequest httReq = new HttpRequest();
            httReq.setMethod('POST');
            httReq.setHeader('Content-Type', 'application/json');
            httReq.setHeader('Authorization', 'Bearer '+accessToken);
            httReq.setHeader('Accept', 'application/json');
            
            String endpoint = config.Prod_Base_URL__c+'/v3/company/'+config.realmId__c+'/customer?minorversion='+config.minorversion__c;
            if(config.Environment__c.equals('Sandbox')){
                endpoint = config.Sanbdox_Base_URL__c+'/v3/company/'+config.realmId__c+'/customer?minorversion='+config.minorversion__c;
            }
            System.debug(endpoint);
            httReq.setEndpoint(endpoint);
            
            String requestBody = System.JSON.serializePretty(customer);
            System.debug(requestBody);
            httReq.setBody(requestBody);
            try {
                HttpResponse httpRes = (new Http()).send(httReq);
                if(httpRes.getStatusCode() == 200 || httpRes.getStatusCode() == 201 ){
                    Map<String,Object> responseMap = (Map<String,Object>)System.JSON.deserializeUntyped(httpRes.getBody());
                    String customerId = (String)responseMap.get('Id');
                    System.debug('Successfully Inserted Customer '+ customerId);
                    /*
                        Update the information in Salesforce 
                        OR Return the Response from here back to the calling class...
                    */
                    
                }else{
                    System.debug(' httpRes getBody '+httpRes.getBody());
                    System.debug(' httpRes getStatusCode '+httpRes.getStatusCode());
                }
            }catch(CalloutException ex) {
                System.debug('Exception Executed '+ex);
            }catch(Exception ex) {
                System.debug('Not Callout Exception Executed '+ex);
            }
            /**
             * Update the Custom metadata record with the latest values...
             */
            if(fieldWithValuesMap?.size() > 0){
                System.debug('Updating the Custom Metadata... ');
                String fullName = 'qb_Metadata.QBToken';
                String label    = 'QBToken';
                // Deploy/Update the Custom Metadata
                CreateUpdateMetadataUtils.createUpdateMetadata(fullName, label, fieldWithValuesMap);
            }
        }else{
            // Enhance this...
        }
    }

}