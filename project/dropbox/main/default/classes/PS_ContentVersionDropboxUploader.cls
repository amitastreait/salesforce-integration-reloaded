/**
 * @description Example method to upload a Salesforce ContentVersion file to Dropbox
 */
public with sharing class PS_ContentVersionDropboxUploader {
    
    // PS_ContentVersionDropboxUploader.uploadContentVersionToDropbox('0680o00000eUcbGAAS', '/Blogs/Salesforce Integration');
    /**
     * @description Uploads a ContentVersion document to Dropbox
     * @param contentVersionId The ID of the ContentVersion to upload
     * @param dropboxPath The Dropbox folder path where the file should be uploaded
     * @return PS_DropboxService.DropboxFile The uploaded file metadata from Dropbox
     */
    @AuraEnabled(cacheable=true)
    public static PS_DropboxService.DropboxFile uploadContentVersionToDropbox(Id contentVersionId, String dropboxPath) {
        // Input validation
        if (contentVersionId == null || String.isBlank(dropboxPath)) {
            throw new IllegalArgumentException('ContentVersion ID and Dropbox path are required');
        }
        
        try {
            // Query the ContentVersion record
            ContentVersion cv = [
                SELECT Id, Title, FileExtension, VersionData, ContentSize, PathOnClient 
                FROM ContentVersion 
                WHERE Id = :contentVersionId
                LIMIT 1
            ];
            
            // Determine file name - use PathOnClient if available, otherwise build from Title and FileExtension
            String fileName = cv.Title;
            if (String.isNotBlank(cv.FileExtension)) {
                fileName += '.' + cv.FileExtension;
            }
            
            // Get the file content as Blob
            Blob fileContent = cv.VersionData;
            
            // Log the upload attempt
            System.debug(LoggingLevel.INFO, 'Uploading file: ' + fileName + ' (' + cv.ContentSize + ' bytes) to Dropbox path: ' + dropboxPath);
            
            // Call the PS_DropboxService to upload the file
            PS_DropboxService.DropboxFile uploadedFile = PS_DropboxService.uploadFile(fileContent, fileName.toLowerCase(), dropboxPath);
            
            // Log the successful upload
            System.debug(LoggingLevel.INFO, 'File uploaded successfully to Dropbox. File ID: ' + uploadedFile.id);
            
            return uploadedFile;
        } catch (QueryException qe) {
            throw new AuraHandledException('ContentVersion record not found: ' + qe.getMessage());
        } catch (Exception e) {
            // Log the error and rethrow
            System.debug(LoggingLevel.ERROR, 'Error uploading ContentVersion to Dropbox: ' + e.getMessage() + '\n' + e.getStackTraceString());
            throw new AuraHandledException('Error uploading file to Dropbox: ' + e.getMessage());
        }
    }
    
    /**
     * @description Batch uploads multiple ContentVersion documents to Dropbox
     * @param contentVersionIds List of ContentVersion IDs to upload
     * @param dropboxPath The Dropbox folder path where the files should be uploaded
     * @return Map<Id, PS_DropboxService.DropboxFile> Map of ContentVersion ID to uploaded Dropbox file metadata
     */
    // PS_ContentVersionDropboxUploader.batchUploadContentVersionsToDropbox(new List<Id>{'068GB00000sA74VYAS'}, '/Amazon.com');
    @AuraEnabled
    public static Map<Id, PS_DropboxService.DropboxFile> batchUploadContentVersionsToDropbox(List<Id> contentVersionIds, String dropboxPath) {
        // Input validation
        if (contentVersionIds == null || contentVersionIds.isEmpty() || String.isBlank(dropboxPath)) {
            throw new IllegalArgumentException('ContentVersion IDs and Dropbox path are required');
        }
        
        Map<Id, PS_DropboxService.DropboxFile> uploadResults = new Map<Id, PS_DropboxService.DropboxFile>();
        
        try {
            // Query the ContentVersion records
            List<ContentVersion> contentVersions = [
                SELECT Id, Title, FileExtension, VersionData, ContentSize, PathOnClient 
                FROM ContentVersion 
                WHERE Id IN :contentVersionIds
            ];
            
            // Process each ContentVersion
            for (ContentVersion cv : contentVersions) {
                try {
                    // Determine file name - use PathOnClient if available, otherwise build from Title and FileExtension
                    String fileName = cv.Title;
                    if (String.isNotBlank(cv.FileExtension)) {
                        fileName += '.' + cv.FileExtension;
                    }
                    
                    // Upload to Dropbox
                    PS_DropboxService.DropboxFile uploadedFile = PS_DropboxService.uploadFile(cv.VersionData, fileName.toLowerCase(), dropboxPath);
                    
                    // Store result
                    uploadResults.put(cv.Id, uploadedFile);
                } catch (Exception e) {
                    // Log individual file upload errors but continue with other files
                    System.debug(LoggingLevel.ERROR, 'Error uploading ContentVersion ' + cv.Id + ': ' + e.getMessage());
                    throw new AuraHandledException('Error uploading ContentVersion ' + cv.Title + ': ' + e.getMessage());
                }
            }
            
            return uploadResults;
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error in batch upload to Dropbox: ' + e.getMessage() + '\n' + e.getStackTraceString());
            throw new AuraHandledException('Error in batch upload to Dropbox: ' + e.getMessage());
        }
    }
    
    /**
     * @description Uploads a ContentVersion document to Dropbox and associates the Dropbox file ID with a record
     * @param contentVersionId The ID of the ContentVersion to upload
     * @param dropboxPath The Dropbox folder path where the file should be uploaded
     * @param recordId The Salesforce record ID to associate the Dropbox file with
     * @param dropboxFileIdField The API name of the field on the record to store the Dropbox file ID
     * @return PS_DropboxService.DropboxFile The uploaded file metadata from Dropbox
     */
    @AuraEnabled(cacheable=true)
    public static PS_DropboxService.DropboxFile uploadAndLinkToRecord(Id contentVersionId, String dropboxPath, Id recordId) {
        // Input validation
        if (contentVersionId == null || String.isBlank(dropboxPath) || recordId == null ) {
            throw new IllegalArgumentException('All parameters are required');
        }
        try {
            // Upload the file to Dropbox
            PS_DropboxService.DropboxFile uploadedFile = uploadContentVersionToDropbox(contentVersionId, dropboxPath);
            return uploadedFile;
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error uploading and linking file: ' + e.getMessage() + '\n' + e.getStackTraceString());
            throw new AuraHandledException('Error uploading and linking file: ' + e.getMessage());
        }
    }

    /**
     * @description Lists files in a specified Dropbox folder
     * @param dropboxFolderPath The path to the folder in Dropbox to list contents from
     * @param recursive Whether to list files in subfolders as well
     * @return List<PS_DropboxService.DropboxFile> List of file metadata from the specified folder
     */
    // ContentVersionDropboxUploader.listDropboxFiles('/Blogs/Salesforce%20Integration');
    @AuraEnabled(cacheable=true)
    public static List<PS_DropboxService.DropboxFile> listDropboxFiles(String dropboxFolderPath) {
        // Input validation
        if (String.isBlank(dropboxFolderPath)) {
            throw new IllegalArgumentException('Dropbox folder path is required');
        }
        
        try {
            // Ensure path starts with a slash
            if (!dropboxFolderPath.startsWith('/')) {
                dropboxFolderPath = '/' + dropboxFolderPath;
            }
            
            // Log the listing attempt
            System.debug(LoggingLevel.INFO, 'Listing files in Dropbox folder: ' + dropboxFolderPath );
            
            // Call the PS_DropboxService to list files
            List<PS_DropboxService.DropboxFile> files = PS_DropboxService.listFiles(dropboxFolderPath);
            
            // Log the number of files found
            System.debug(LoggingLevel.INFO, 'Found ' + files.size() + ' files in Dropbox folder');
            System.debug(LoggingLevel.INFO, 'Files: ' + JSON.serializePretty(files));
            return files;
        } catch (Exception e) {
            // Log the error and rethrow
            System.debug(LoggingLevel.ERROR, 'Error listing files from Dropbox folder: ' + e.getMessage() + '\n' + e.getStackTraceString());
            throw new AuraHandledException('Error listing files from Dropbox folder: ' + e.getMessage());
        }
    }

    /**
     * @description Downloads a file from Dropbox and creates a ContentVersion record
     * @param dropboxFilePath The full path to the file in Dropbox
     * @param folderId Optional ContentWorkspace (Library) ID to associate the file with
     * @return Id The ID of the created ContentVersion
     */
    // ContentVersionDropboxUploader.downloadFileFromDropbox('/Blogs/Salesforce%20Integration/panther schools.png', '0010o00002xBPHiAAO');
    @AuraEnabled(cacheable=true)
    public static void downloadFileFromDropbox(String dropboxFilePath, String recordId) {
        // Input validation
        if (String.isBlank(dropboxFilePath)) {
            throw new IllegalArgumentException('Dropbox file path is required');
        }
        
        try {
            // Log the download attempt
            System.debug(LoggingLevel.INFO, 'Downloading file from Dropbox path: ' + dropboxFilePath);
            
            // Call the PS_DropboxService to download the file
            PS_DropboxService.DropboxFile downloadResult = PS_DropboxService.downloadFile(dropboxFilePath, recordId);
            createDownloadedFiles(downloadResult);
            // Log successful download
            System.debug(LoggingLevel.INFO, 'File downloaded successfully from Dropbox and saved as ContentVersion: ' );
            
            //return cv.Id;
        } catch (Exception e) {
            // Log the error and rethrow
            System.debug(LoggingLevel.ERROR, 'Error downloading file from Dropbox: ' + e.getMessage() + '\n' + e.getStackTraceString());
            throw new AuraHandledException('Error downloading file from Dropbox: ' + e.getMessage());
        }
    }


    public static void createDownloadedFiles(PS_DropboxService.DropboxFile file){
        // Extract file information
        String dropboxFileId = (String) file?.metadata.get('id');
        String fileName = (String) file?.metadata.get('name');
        String dropboxPath = (String) file?.metadata.get('path_display');
        Long fileSize = (Long) file?.metadata.get('size');

        // Step 2: Create ContentVersion record
        ContentVersion cv = new ContentVersion();
        cv.Title = fileName;
        cv.PathOnClient = fileName;
        cv.VersionData = file?.fileContent;
        cv.Origin = 'H';
        if (file?.recordId != null) {
            cv.FirstPublishLocationId = file?.recordId;
        }
        
        insert cv;
        
        cv = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];
        DropBoxFile__c dropboxFile = new DropBoxFile__c();
        dropboxFile.Dropbox_File_Id__c = dropboxFileId;
        dropboxFile.Name = fileName;
        dropboxFile.Dropbox_Path__c = dropboxPath;
        dropboxFile.File_Size__c = fileSize;
        dropboxFile.RecordId__c = file?.recordId;
        dropboxFile.Content_Document_Id__c = cv.ContentDocumentId;
        dropboxFile.ServerUrl__c = 'https://www.dropbox.com/home'+dropboxPath;
        // Extract file extension
        if (fileName.contains('.')) {
            String fileExtension = fileName.substring(fileName.lastIndexOf('.') + 1);
            dropboxFile.FileExtension__c = fileExtension;
        }
        insert dropboxFile;
    }
}