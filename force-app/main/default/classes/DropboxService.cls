/**
 * @description       : 
 * @author            : Amit Singh - PantherSchools
 * @group             : 
 * @last modified on  : 05-24-2024
 * @last modified by  : Amit Singh - PantherSchools
**/
public with sharing class DropboxService {

    private static final Integer CHUNK_SIZE = 4 * 1024 * 1024;

    private static HttpRequest createRequest(String path, String method, String body) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:DropboxFiles'+path);
        req.setMethod(method);
        System.debug(body);
        req.setHeader('Content-Type', 'application/json');
        if (body != null) {
            req.setBody(body);
        }
        return req;
    }

    @AuraEnabled(cacheable=true)
    public static List<String> getDropboxItems(String path) {
        Http http = new Http();
        HttpRequest req = createRequest('/2/files/list_folder', 'POST', '{"path": "' + path + '"}');
        HttpResponse res = http.send(req);
        if (res.getStatusCode() == 200) {
            System.debug(res.getBody());
            Map<String, Object> response = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            List<Object> entries = (List<Object>) response.get('entries');
            List<String> items = new List<String>();
            for (Object entry : entries) {
                Map<String, Object> entryMap = (Map<String, Object>) entry;
                items.add((String) entryMap.get('name'));
            }
            return items;
        } else {
            //throw new AuraHandledException('Failed to fetch Dropbox items');
            System.debug(res.getBody());
            return null;
        }
    }

    // DropboxService.processUploadFile('068Hu00000bBYf4IAG','google.com');
    public static void processUploadFile(String fileId, String folderName){
        ContentVersion file = [SELECT Id, Title, VersionData, FileExtension, FileType FROM ContentVersion WHERE Id = :fileId LIMIT 1];
        System.debug(file);
        Blob csvBlob = file.VersionData;
        String csvContent = csvBlob.toString();
        folderName += '/'+file.Title+'.'+file.FileExtension;
        uploadFile(folderName, csvContent);
    }

    @AuraEnabled
    public static void uploadFile(String path, String content) {
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:Dropbox/2/files/upload');
        req.setMethod('POST');
        req.setHeader('Dropbox-API-Arg', '{"path": "' + path + '","mode": "add","autorename": true,"mute": false,"strict_conflict": false}');
        req.setHeader('Content-Type', 'application/octet-stream');
        req.setBody(content);
        HttpResponse res = http.send(req);
        if (res.getStatusCode() != 200) {
            throw new AuraHandledException('Failed to upload file to Dropbox');
        }
    }

    @AuraEnabled
    public static Blob downloadFile(String dropboxFilePath) {
        HttpRequest req = new HttpRequest();
        if(String.isBlank(dropboxFilePath)){
            dropboxFilePath = '/google.com/system.jpeg';
        }
        req.setEndpoint('callout:Dropbox'+'/2/files/download');
        req.setMethod('POST');
        req.setHeader('Dropbox-API-Arg', '{"path": "' + dropboxFilePath + '"}');
        //req.setHeader('Authorization', 'Bearer sl.B13MftuX7qZipSxgiH-HpkpstxPbRYo');
        System.debug(req.getEndpoint());
        Http http = new Http();
        HttpResponse res = http.send(req);
        
        if (res.getStatusCode() == 200) {
            System.debug(res.getBodyAsBlob());
            ContentVersion contentVersion_1 = new ContentVersion(
                Title='system', 
                PathOnClient ='system.jpeg',
                VersionData = res.getBodyAsBlob(), 
                origin = 'H',
                FirstPublishLocationId = '00QHu00003i3V7BMAU'
            );
            insert contentVersion_1;
            System.debug(contentVersion_1.Id);
            return res.getBodyAsBlob();
        } else {
            System.debug('Error: ' + res.getStatus());
            System.debug('Error Message: ' + res.getStatusCode());
            return null;
        }
    }

    @AuraEnabled
    public static void downloadZipFile(String dropboxFilePath, String zipFileName) {
        HttpRequest req = new HttpRequest();
        if(String.isBlank(dropboxFilePath)){
            dropboxFilePath = '/google.com';
        }
        req.setEndpoint('callout:Dropbox'+'/2/files/download_zip');
        req.setMethod('POST');
        req.setHeader('Dropbox-API-Arg', '{"path": "' + dropboxFilePath + '"}');
        //req.setHeader('Authorization', 'Bearer sl.B13MftuX7qZipSxgiH-HpkpstxPbRYo');
        System.debug(req.getEndpoint());
        Http http = new Http();
        HttpResponse res = http.send(req);
        
        if (res.getStatusCode() == 200) {
            
            ContentVersion contentVersion_1 = new ContentVersion(
                Title        =  zipFileName, 
                PathOnClient =  zipFileName,
                VersionData  =  res.getBodyAsBlob(), 
                origin       = 'H',
                FirstPublishLocationId = '00QHu00003i3V7BMAU'
            );
            insert contentVersion_1;
            System.debug(contentVersion_1.Id);
            
        } else {
            System.debug('Error: ' + res.getStatus());
            System.debug('Error Message: ' + res.getStatusCode());
            
        }
    }
}