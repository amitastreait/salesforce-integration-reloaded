/**
 * @description       : 
 * @author            : Amit Singh - PantherSchools
 * @group             : 
 * @last modified on  : 06-26-2024
 * @last modified by  : Amit Singh - PantherSchools
**/
public with sharing class UploadFileController {
    
    @AuraEnabled
    public static void uploadFile(String recordId, String fileContent, String fieldApiName, String fileName){
        try {
            fileContent = EncodingUtil.urlDecode(fileContent, 'UTF-8');
            ContentVersion contentToInsert =new ContentVersion(); 
            contentToInsert.Title =fileName; 
            contentToInsert.VersionData=EncodingUtil.base64Decode(fileContent);
            contentToInsert.PathOnClient='/' + fileName ;
            contentToInsert.IsMajorVersion = false;
            contentToInsert.FirstPublishLocationId = recordId;
            insert contentToInsert; 

            ContentDistribution distribution = new ContentDistribution();
            distribution.ContentVersionId = contentToInsert.Id;
            distribution.Name = fileName;
            distribution.RelatedRecordId = recordId;
            distribution.PreferencesNotifyOnVisit = false;
            distribution.PreferencesAllowViewInBrowser = true;
            distribution.PreferencesAllowOriginalDownload=true;
            distribution.PreferencesAllowPDFDownload = true;
            insert distribution;

            ContentDistribution distributionRecord = [Select Id, ContentDownloadUrl 
                                                        FROM ContentDistribution 
                                                        WHERE Id =:distribution.Id
                                                    ];
            String picUrl = '';
            picUrl = distributionRecord.ContentDownloadUrl.replace('download/?' , 'renditionDownload?rendition=ORIGINAL_Jpg&');
            picUrl = picUrl.replace('&ids' , '&versionId');

            String sobjectName = string.valueOf(Id.valueOf(recordId).getSObjectType());
            sObject sObj = Schema.getGlobalDescribe().get(sobjectName).newSObject() ;

            sObj.put('Id', recordId);
            sObj.put(fieldApiName, picUrl);

            update sObj;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}