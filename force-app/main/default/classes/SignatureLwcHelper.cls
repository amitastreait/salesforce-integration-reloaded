/**
 * @description       :
 * @author            : Amit Singh
 * @group             :
 * @last modified on  : 05-16-2024
 * @last modified by  : Amit Singh - PantherSchools
**/
public with sharing class SignatureLwcHelper {

    /**
    * @description
    * @author Amit Singh | 10-29-2021
    * @param ContentVersionData
    * @param recordId
    * @return String
    **/
    @AuraEnabled
    public static String saveSignature(String ContentVersionData, Id recordId){

        /*
            Create Content Version Object and then after content document link
        */
        ContentVersion cVersion = new ContentVersion();
        cVersion.ContentLocation = 'S';
        cVersion.PathOnClient = 'Signature-'+System.now() +'.png';
        cVersion.Origin = 'H';
        cVersion.Title = 'Signature-'+System.now() +'.png';
        cVersion.VersionData = EncodingUtil.base64Decode(ContentVersionData);
        Insert cVersion;

        Id conDocument = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cVersion.Id].ContentDocumentId;

        ContentDocumentLink cDocLink = new ContentDocumentLink();
        cDocLink.ContentDocumentId = conDocument;
        cDocLink.LinkedEntityId = recordId;
        cDocLink.ShareType = 'I';
        cDocLink.Visibility = 'AllUsers';
        Insert cDocLink;

        return cVersion.Id;
    }
}