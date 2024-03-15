public class GoogleDriveIntegration {

    @AuraEnabled(cacheable=true)
    public static String fetchFileContent(String fileId) {
        String fileContent;
        
        Google_Config__mdt config = Google_Config__mdt.getInstance(System.Label.PS_GoogleTokenLabel); // Use Custom Label
        if(config != null){
            Boolean isValid = Assignment_GoogleAPITokenUtils.isValid(config);
            Map<String, Object> fieldWithValuesMap = new Map<String, Object>();
            String accessToken = config.access_token__c;
            if(!isValid){
                fieldWithValuesMap = Assignment_GoogleAPITokenUtils.refreshToken(config);
                accessToken = (String)fieldWithValuesMap.get('access_token__c');
            }
        
            // Make callout to Google Drive API to fetch file content
            String apiUrl = 'https://www.googleapis.com/drive/v3/files/' + fileId + '?alt=media';
            HttpRequest req = new HttpRequest();
            req.setEndpoint(apiUrl);
            req.setMethod('GET');
            req.setHeader('Authorization', 'Bearer ' + accessToken);
            
            Http http = new Http();
            HttpResponse res = http.send(req);
            
            if (res.getStatusCode() == 200) {
                // Extract file content from response
                fileContent = res.getBody();
            } else {
                // Handle error
                throw new AuraHandledException('Error fetching file content from Google Drive: ' + res.getBody());
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
        
        return fileContent;
    }

    @AuraEnabled(cacheable=true)
    public static List<GoogleDriveFile> fetchFilesFromGoogleDrive(String folderId) {
        List<GoogleDriveFile> files = new List<GoogleDriveFile>();
        
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
            String apiUrl = 'https://www.googleapis.com/drive/v3/files?q=\'' + folderId + '\'+in+parents';
            HttpRequest req = new HttpRequest();
            req.setEndpoint(apiUrl);
            req.setMethod('GET');
            req.setHeader('Authorization', 'Bearer ' + accessToken);
            
            Http http = new Http();
            HttpResponse res = http.send(req);
            System.debug(res.getBody());
            if (res.getStatusCode() == 200) {
                // Parse response and extract file information
                Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                List<Object> items = (List<Object>) responseMap.get('files');
                
                for (Object item : items) {
                    Map<String, Object> fileMap = (Map<String, Object>) item;
                    String name = (String) fileMap.get('name');
                    String fileId = (String) fileMap.get('id');
                    String mimeType = (String) fileMap.get('mimeType');
                    String thumbnailUrl = getThumbnailUrl(fileId); // Get thumbnail URL
                    files.add(new GoogleDriveFile(name, fileId, thumbnailUrl, mimeType));
                }
            } else {
                // Handle error
                throw new AuraHandledException('Error fetching files from Google Drive: ' + res.getBody());
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
        
        return files;
    }

    @AuraEnabled
    public static void uploadFileToGoogleDrive(String folderId, String fileName, String base64Data) {
        if (base64Data.length() > 4 * 1024 * 1024) {
            throw new AuraHandledException('File size exceeds the limit of 4 MB.');
        }

        Google_Config__mdt config = Google_Config__mdt.getInstance(System.Label.PS_GoogleTokenLabel); // Use Custom Label
        if(config != null){
            Boolean isValid = Assignment_GoogleAPITokenUtils.isValid(config);
            Map<String, Object> fieldWithValuesMap = new Map<String, Object>();
            String accessToken = config.access_token__c;
            if(!isValid){
                fieldWithValuesMap = Assignment_GoogleAPITokenUtils.refreshToken(config);
                accessToken = (String)fieldWithValuesMap.get('access_token__c');
            }

            String contentType = 'application/pdf';
            GoogleDriveAPI.UploadFile(fileName, base64Data, 'application/pdf', accessToken, folderId);
            
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
        
    }

    // Method to upload file to Google Drive
    // GoogleDriveIntegration.getFileData('068Hu00000bA49qIAC');
    public static void getFileData(String versionId){
        ContentVersion version = [SELECT Id, FileExtension, FileType, VersionData, Description, 
                                        ContentDocument.Title 
                                    FROM 
                                        ContentVersion 
                                    WHERE 
                                        Id =: versionId
                                ];
        String fileName = version.ContentDocument.Title+'.'+version.FileExtension;
        String parentId = '';
        Blob body = version.VersionData;
        GoogleDriveIntegration.uploadFileToGoogleDrive(parentId, fileName, body);
    }

    public static void uploadFileToGoogleDrive(String parentId, String fileName, Blob fileBody) {
        // Implement OAuth2 authentication to get access token
        Google_Config__mdt config = Google_Config__mdt.getInstance(System.Label.PS_GoogleTokenLabel); // Use Custom Label
        if(config != null){
            Boolean isValid = Assignment_GoogleAPITokenUtils.isValid(config);
            Map<String, Object> fieldWithValuesMap = new Map<String, Object>();
            String accessToken = config.access_token__c;
            if(!isValid){
                fieldWithValuesMap = Assignment_GoogleAPITokenUtils.refreshToken(config);
                accessToken = (String)fieldWithValuesMap.get('access_token__c');
            }

            // Create a resumable upload session
            String uploadSessionUrl = GoogleDriveAPI.createResumableUploadSession(accessToken, fileName, parentId);
            System.System.debug(uploadSessionUrl);
            // Upload file using resumable upload
            GoogleDriveAPI.uploadFileUsingResumableUpload(accessToken, uploadSessionUrl, fileBody);

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
        
    }

    // Method to get thumbnail URL for a file
    private static String getThumbnailUrl(String fileId) {
        return 'https://drive.google.com/thumbnail?id=' + fileId;
    }

    // Inner class to represent Google Drive file
    public class GoogleDriveFile {
        @AuraEnabled public String name;
        @AuraEnabled public String fileName;
        @AuraEnabled public String thumbnailUrl;
        @AuraEnabled public String mimeType;
        
        public GoogleDriveFile(String name, String fileName, String thumbnailUrl, String mimeType) {
            this.name = name;
            this.fileName = fileName;
            this.thumbnailUrl = thumbnailUrl;
            this.mimeType = mimeType;
        }
    }
}