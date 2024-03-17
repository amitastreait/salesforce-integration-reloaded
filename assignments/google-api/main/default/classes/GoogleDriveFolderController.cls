/**
 * @description       : 
 * @author            : Amit Singh - PantherSchools
 * @group             : 
 * @last modified on  : 03-16-2024
 * @last modified by  : Amit Singh - PantherSchools
**/

public with sharing class GoogleDriveFolderController {

    // Method to download a file from Google Drive
    @AuraEnabled
    public static String downloadFile(String fileId) {
        String downloadUrl;
        Google_Config__mdt config = Google_Config__mdt.getInstance(System.Label.PS_GoogleTokenLabel); // Use Custom Label
        if(config != null){
            Boolean isValid = Assignment_GoogleAPITokenUtils.isValid(config);
            Map<String, Object> fieldWithValuesMap = new Map<String, Object>();
            String accessToken = config.access_token__c;
            if(!isValid){
                fieldWithValuesMap = Assignment_GoogleAPITokenUtils.refreshToken(config);
                accessToken = (String)fieldWithValuesMap.get('access_token__c');
            }
        
            String apiUrl = 'https://www.googleapis.com/drive/v3/files/' + EncodingUtil.urlEncode(fileId, 'UTF-8') + '?fields=webContentLink';
            HttpRequest req = new HttpRequest();
            req.setEndpoint(apiUrl);
            req.setMethod('GET');
            req.setHeader('Authorization', 'Bearer ' + accessToken);
            
            Http http = new Http();
            HttpResponse res = http.send(req);
            
            if (res.getStatusCode() == 200) {
                // Parse response to get download URL
                Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                downloadUrl = (String) responseMap.get('webContentLink');
            } else {
                throw new AuraHandledException('Error fetching file metadata from Google Drive: ' + res.getBody());
            }
            if(fieldWithValuesMap.size() >0 ){
                String fullName = 'Google_Config.'+System.Label.PS_GoogleTokenLabel;
                String label = System.Label.PS_GoogleTokenLabel;
                CreateUpdateMetadataUtils.createUpdateMetadata(fullName, label, fieldWithValuesMap);
            }
        }
        return downloadUrl;
    }

    // Method to fetch Google Drive folders
    @AuraEnabled(cacheable=true)
    public static List<GoogleDriveFolder> fetchFolders() {
        List<GoogleDriveFolder> folders = new List<GoogleDriveFolder>();
        
        Google_Config__mdt config = Google_Config__mdt.getInstance(System.Label.PS_GoogleTokenLabel); // Use Custom Label
        if(config != null){
            Boolean isValid = Assignment_GoogleAPITokenUtils.isValid(config);
            Map<String, Object> fieldWithValuesMap = new Map<String, Object>();
            String accessToken = config.access_token__c;
            if(!isValid){
                fieldWithValuesMap = Assignment_GoogleAPITokenUtils.refreshToken(config);
                accessToken = (String)fieldWithValuesMap.get('access_token__c');
            }
        
            // Make callout to Google Drive API
            String queryParams = 'mimeType=\'application/vnd.google-apps.folder\' and \'root\' in parents and trashed=false';
            String apiUrl = 'https://www.googleapis.com/drive/v3/files?q='+EncodingUtil.urlEncode(queryParams, 'UTF-8');
            HttpRequest req = new HttpRequest();
            req.setEndpoint(apiUrl);
            req.setMethod('GET');
            req.setHeader('Authorization', 'Bearer ' + accessToken);
            
            Http http = new Http();
            HttpResponse res = http.send(req);
            System.debug(res.getBody());
            if (res.getStatusCode() == 200) {
                // Parse response and extract folder information
                Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                List<Object> items = (List<Object>) responseMap.get('files');
                
                for (Object item : items) {
                    Map<String, Object> folderMap = (Map<String, Object>) item;
                    String name = (String) folderMap.get('name');
                    String folderId = (String) folderMap.get('id');
                    folders.add(new GoogleDriveFolder(name, folderId));
                }
            } else {
                // Handle error
                throw new AuraHandledException('Error fetching Google Drive folders: ' + res.getBody());
            }

            /*
                TODO: Update The Custom Metadata with New Values
                ! Update the new Access Token
            */
            if(fieldWithValuesMap.size() >0 ){
                String fullName = 'Google_Config.'+System.Label.PS_GoogleTokenLabel;
                String label = System.Label.PS_GoogleTokenLabel;
                CreateUpdateMetadataUtils.createUpdateMetadata(fullName, label, fieldWithValuesMap);
            }
        }
        
        return folders;
    }
    
    // Inner class to represent Google Drive folder
    public class GoogleDriveFolder {
        @AuraEnabled public String name;
        @AuraEnabled public String folderId;
        
        public GoogleDriveFolder(String name, String folderId) {
            this.name = name;
            this.folderId = folderId;
        }
    }


}
