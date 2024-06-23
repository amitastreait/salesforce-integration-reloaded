/**
 * @description       : 
 * @author            : Amit Singh - PantherSchools
 * @group             : 
 * @last modified on  : 06-23-2024
 * @last modified by  : Amit Singh - PantherSchools
**/
public with sharing class AWSS3Manager {
    
    public static void createBucket(String bucketName, String recordId, String region){

        bucketName = bucketName.toLowerCase().replaceAll(' ', '-') + '-'+recordId.toLowerCase();
        // Salesforce India Pvt Ltd --> salesforce-india-pvt-ltd-recordId
        System.debug(bucketName);
        HttpRequest httpReq = new HttpRequest();
        httpReq.setEndpoint('callout:AWSS3Cred'+'/'+ EncodingUtil.urlEncode(bucketName, 'UTF-8') );
        httpReq.setMethod('PUT');

        String requestBody = '<?xml version="1.0" encoding="UTF-8"?>' +
            '<CreateBucketConfiguration xmlns="http://s3.amazonaws.com/doc/2006-03-01/">' +
            '<LocationConstraint>'+region+'</LocationConstraint>' +
            '</CreateBucketConfiguration>';
        
        if(String.isNotBlank(region) && !region.equalsIgnoreCase('us-east-1') ){
            httpReq.setBody(requestBody);
        }

        try {
           HttpResponse response = (new Http()).send(httpReq);
           if(response.getStatusCode() == 200 || response.getStatusCode() == 201){
                

                createFolderInsideBucket(bucketName, 'opportunities');
                createFolderInsideBucket(bucketName, 'orders');

                // Update the account with the bucket Name
                Account acc = new Account(Id = recordId, S3BucketName__c = bucketName);
                update acc;
           } else {
                // handle Error
                System.debug( response.getBody() );
           }
        } catch (System.Exception ex) {
            System.debug(' '+ex.getMessage() );
        }
    }

    public static void createFolderInsideBucket(String bucketName, String folderName){
        HttpRequest httpReq = new HttpRequest();
        httpReq.setEndpoint('callout:AWSS3Cred'+'/'+ EncodingUtil.urlEncode(bucketName, 'UTF-8') + '/'+ EncodingUtil.urlEncode(folderName, 'UTF-8') +'/');
        httpReq.setMethod('PUT');
        httpReq.setHeader('Content-Length', '0');
        try {
           HttpResponse response = (new Http()).send(httpReq);
           if(response.getStatusCode() == 200 || response.getStatusCode() == 201){
                
           } else {
                System.debug( response.getBody() );
           }
        } catch (System.Exception ex) {
            System.debug(' '+ex.getMessage() );
        }
    }

    public static void createFolderInsideBucketFolder(String bucketName, String folderPath, String folderName){
        HttpRequest httpReq = new HttpRequest();
        httpReq.setEndpoint('callout:AWSS3Cred'+'/'+ EncodingUtil.urlEncode(bucketName, 'UTF-8') + '/'+ EncodingUtil.urlEncode(folderPath, 'UTF-8') +'/'+ EncodingUtil.urlEncode(folderName, 'UTF-8') +'/');
        httpReq.setMethod('PUT');
        httpReq.setHeader('Content-Length', '0');
        try {
           HttpResponse response = (new Http()).send(httpReq);
           if(response.getStatusCode() == 200 || response.getStatusCode() == 201){
                
           } else {
                System.debug( response.getBody() );
           }
        } catch (System.Exception ex) {
            System.debug(' '+ex.getMessage() );
        }
    }

    public static void createFolderInsideBucket(String endpoint){
        // EncodingUtil.urlEncode(bucketName, 'UTF-8') + '/'+ EncodingUtil.urlEncode(folderPath, 'UTF-8') +'/'+ EncodingUtil.urlEncode(folderName, 'UTF-8') +'/'
        HttpRequest httpReq = new HttpRequest();
        httpReq.setEndpoint('callout:AWSS3Cred'+'/'+ endpoint);
        httpReq.setMethod('PUT');
        httpReq.setHeader('Content-Length', '0');
        try {
           HttpResponse response = (new Http()).send(httpReq);
           if(response.getStatusCode() == 200 || response.getStatusCode() == 201){
                
           } else {
                System.debug( response.getBody() );
           }
        } catch (System.Exception ex) {
            System.debug(' '+ex.getMessage() );
        }
    }

    /*
        String endPoint = EncodingUtil.urlEncode('panther-schools-001hu00003cvddciaj', 'UTF-8') + '/'+ EncodingUtil.urlEncode('orders', 'UTF-8') +'/'+ EncodingUtil.urlEncode('00000107', 'UTF-8');
        AWSS3Manager.uploadFile('068Hu00000bBYf4IAG', endPoint);

        Trigger - Content Version
            ContentDocumentId
                LinkedEntityId FROM ContentDocumentLink WHERE ContentDocumentId =: 
                    if(link.LinkedEntityId.getSobjectType() == Order.getSobjectType() 
                        || link.LinkedEntityId.getSobjectType() == Opportunity.getSobjectType())
    */
    public static void uploadFile(String recordId, String endPoint){
        ContentVersion version = [SELECT Id, VersionNumber, Title, FileType, FileExtension, VersionData 
                                    FROM ContentVersion WHERE Id =: recordId];
        
        String fileName = version.Title+'.'+version.FileExtension;
        HttpRequest httpReq = new HttpRequest();
        httpReq.setEndpoint('callout:AWSS3Cred'+'/'+ endPoint +'/'+fileName );
        httpReq.setMethod('PUT');
        httpReq.setBodyAsBlob(version.VersionData);

        try {
           HttpResponse response = (new Http()).send(httpReq);
           if(response.getStatusCode() == 200 || response.getStatusCode() == 201){
                
           } else {
                // handle Error
                System.debug( response.getBody() );
           }
        } catch (System.Exception ex) {
            System.debug(' '+ex.getMessage() );
        }
    }

    /*
        String endPoint = EncodingUtil.urlEncode('panther-schools-001hu00003cvddciaj', 'UTF-8');
        AWSS3Manager.listBucketItems(endPoint);
    */
    public static void listBucketItems(String endPoint){
        HttpRequest httpReq = new HttpRequest();
        httpReq.setEndpoint('callout:AWSS3Cred'+'/'+ endPoint +'/' );
        httpReq.setMethod('GET');

        try {
           HttpResponse response = (new Http()).send(httpReq);
           String ns = 'http://s3.amazonaws.com/doc/2006-03-01/';
           if(response.getStatusCode() == 200 || response.getStatusCode() == 201){
                Dom.Document doc = response.getBodyDocument();
                Dom.XmlNode rootNote = doc.getRootElement();
                Dom.XmlNode nameNode = rootNote.getChildElement('Name', ns);
                String bucketName = '';
                if(nameNode != null){
                    bucketName = nameNode.getText();
                }

                ListBucketResult itemWrapper = new ListBucketResult();
                itemWrapper.name = bucketName;
                itemWrapper.items = new List<ListBucketResult.Contents>();

                for(Dom.XmlNode root : rootNote.getChildElements() ){
                    if(root.getName() == 'Contents'){ // multiple items
                        ListBucketResult.Contents item = new ListBucketResult.Contents();
                        for(Dom.XmlNode contentNode : root.getChildElements() ){
                            String nodeName = contentNode.getName();
                            String nodeValue = contentNode.getText();
                            switch on nodeName {
                                when 'Key' {
                                    item.key = nodeValue;
                                }
                                when 'LastModified' {
                                    
                                }
                                when 'ETag' {
                                    
                                }
                                when 'Size' {
                                    item.size = nodeValue;
                                }
                                when 'StorageClass' {
                                    
                                }
                                when 'Owner' {
                                    for(Dom.XmlNode ownerNode: contentNode.getChildElements() ) {
                                        String nodeOwnerName = contentNode.getName();
                                        switch on nodeOwnerName {
                                            when 'ID' {
                                                
                                            }
                                            when 'DisplayName' {
                                                
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        itemWrapper.items.add(item);
                    }
                }

                System.debug(itemWrapper);

           } else {
                // handle Error
                System.debug( response.getBody() );
           }
        } catch (System.Exception ex) {
            System.debug(' '+ex.getMessage() );
        }
    }
}