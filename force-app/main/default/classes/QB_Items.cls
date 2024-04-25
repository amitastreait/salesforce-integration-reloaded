/**
 * @description       : 
 * @author            : Amit Singh - PantherSchools
 * @group             : 
 * @last modified on  : 04-20-2024
 * @last modified by  : Amit Singh - PantherSchools
**/
public with sharing class QB_Items {

    // QB_Items.testCreateItem();
    public static void testCreateItem(){
        List<Product2> products = [Select Id, Name FROM Product2 WHERE QBExternalID__c = null ];
        // System.CalloutException: You have uncommitted work pending. Please commit or rollback before calling out
        /**
         * Callout
         * Callout
         * Callout
         * Callout
         * DML - Works
         
         * Callout
         * DML
         * Callout - Fails System.CalloutException: You have uncommitted work pending. Please commit or rollback before calling out
         */
        for(Product2 prod: products){
            createItemInQB(prod); // Not a Best Practice, but will do for POC
        }
        update products;
    }
    
    public static Product2 createItemInQB(Product2 productRecord){
        /** Get the config from the Custom Metadta */
        List<qb_Metadata__mdt> configList = [SELECT Id, DeveloperName, MasterLabel,  Environment__c, Prod_Base_URL__c, Sanbdox_Base_URL__c,
                                        access_token__c, auth_url__c, expires_in__c, expires_in_time__c, minorversion__c, 
                                        realmId__c, refresh_token__c, token_type__c, token_url__c 
                                        FROM qb_Metadata__mdt 
                                        WHERE DeveloperName = 'QBToken' 
                                        LIMIT 1]; // Token Details Are Stored Here...
        if(configList?.size() > 0){
            qb_Metadata__mdt config = configList.get(0);
            
            String accessToken = config.access_token__c;
            
            Boolean isValid = PS_QBTokenUtil.isValid(config);
            Map<String, Object> fieldWithValuesMap;

            if(isValid == false){ // Token is Expired
                // Refresh the Token
                fieldWithValuesMap = PS_QBTokenUtil.refreshToken(config);
                accessToken = (String)fieldWithValuesMap.get('access_token__c'); // null/blank
            }

            HttpRequest httReq = new HttpRequest();
            httReq.setMethod('POST');
            httReq.setHeader('Content-Type', 'application/json');
            httReq.setHeader('Authorization', 'Bearer '+accessToken);
            httReq.setHeader('Accept', 'application/json');
            
            String endpoint = config.Prod_Base_URL__c+'/v3/company/'+config.realmId__c+'/item?minorversion='+config.minorversion__c;
            if(config.Environment__c.equals('Sandbox')){
                endpoint = config.Sanbdox_Base_URL__c+'/v3/company/'+config.realmId__c+'/item?minorversion='+config.minorversion__c;
            }
            
            httReq.setEndpoint(endpoint);
            
            String requestBody = '{'+
            '    "TrackQtyOnHand": false,'+
            '    "Name": "'+productRecord.Name+'",'+
            '    "QtyOnHand": 180,'+
            '    "IncomeAccountRef": {'+
            '        "name": "'+System.Label.IncomeAccountRefName+'",'+
            '        "value": "'+System.Label.IncomeAccountRefValue+'"'+
            '    },'+
            '    "AssetAccountRef": {'+
            '        "name": "'+System.Label.AssetAccountRefName+'",'+
            '        "value": "'+System.Label.AssetAccountRefValue+'"'+
            '    },'+
            '    "InvStartDate": "2025-01-01",'+
            '    "Type": "Service",'+
            '    "ExpenseAccountRef": {'+
            '        "name": "'+System.Label.ExpenseAccountRefName+'",'+
            '        "value": "'+System.Label.ExpenseAccountRefValue+'"'+
            '    }'+
            '}';
            
            httReq.setBody(requestBody);
            try {
                HttpResponse httpRes = (new Http()).send(httReq);
                if(httpRes.getStatusCode() == 200 || httpRes.getStatusCode() == 201 ){
                    Map<String,Object> responseMap = (Map<String,Object>)System.JSON.deserializeUntyped(httpRes.getBody());
                    Object item = responseMap.get('Item'); // {}
                    Map<String,Object> itemMap = (Map<String,Object>)item;
                    System.debug(' itemMap \n '+System.JSON.serializePretty(itemMap));
                    productRecord.QBExternalID__c = (String)itemMap.get('Id');
                    productRecord.Synced_With_Quickbooks__c = true; 

                    //upsert productRecord QBExternalID__c;
                    
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
        return productRecord;
    }
}