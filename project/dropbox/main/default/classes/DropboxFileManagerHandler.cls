public with sharing class DropboxFileManagerHandler {

    /**
     * Example usage:
     * Object result = DropboxFileManagerHandler.invokeUploadFile('068Hu00000c7OA1IAM','/salesforce/external_service','001Hu000038vjS2IAI');
     * System.debug('Result: ' + result);
     */
    public static Object invokeUploadFile(String fileIdVersion, String filePath, String recordId) {

        // Initialize the External Service
        ExternalService.DropboxFileManagerHandler service = new ExternalService.DropboxFileManagerHandler();

        // Create request object
        ExternalService.DropboxFileManagerHandler.uploadFile_Request request = new ExternalService.DropboxFileManagerHandler.uploadFile_Request();

        // Set the request body
        // Create the body object with the required parameters
        ExternalService.DropboxFileManagerHandler_uploadFile_IN_body body = new ExternalService.DropboxFileManagerHandler_uploadFile_IN_body();

        body.fileId = fileIdVersion;
        body.filePath = filePath;
        body.recordId = recordId;

        request.body = body;
        System.debug('Request body set: ' + JSON.serializePretty(body));

        try {
            // Invoke the External Service operation
            ExternalService.DropboxFileManagerHandler.uploadFile_Response response = service.uploadFile(request);

            // Process the response
            // The response should contain the result from the @AuraEnabled method
            System.debug('Upload completed successfully');
            System.debug('Response: ' + JSON.serializePretty(response));

            return response;

        } catch (ExternalService.DropboxFileManagerHandler.uploadFile_ResponseException e) {
            // Handle External Service specific exceptions
            System.debug('External Service error: ' + e.getMessage());
            System.debug('Response code: ' + e.responseCode);

            if (e.responseCode == 400) {
                throw new AuraHandledException('Bad request: ' + e.getMessage());
            } else if (e.responseCode == 401 || e.responseCode == 403) {
                throw new AuraHandledException('Authentication error: ' + e.getMessage());
            } else if (e.responseCode == 404) {
                throw new AuraHandledException('Resource not found: ' + e.getMessage());
            } else if (e.responseCode == 500) {
                throw new AuraHandledException('Server error: ' + e.getMessage());
            } else {
                throw new AuraHandledException('Failed to upload file: ' + e.getMessage());
            }

        } catch (Exception e) {
            System.debug('Unexpected error: ' + e.getMessage());
            System.debug('Stack trace: ' + e.getStackTraceString());
            throw new AuraHandledException('Unexpected error: ' + e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static sObject queryName(String recordId, String fieldApiName, String objectApiName){
        try {
            String query = 'SELECT Id, '+ fieldApiName +' FROM ' + objectApiName + ' WHERE Id = \'' + recordId + '\' LIMIT 1';
            return Database.query(query);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static void uploadFile(String fileId, String filePath, String recordId){
        try {
            if(String.isBlank(filePath)){
                filePath = '/';
            }

            ContentVersion cv = [
                SELECT Id, Title, ContentDocumentId, FileExtension, VersionData, ContentSize, PathOnClient 
                FROM ContentVersion 
                WHERE Id = :fileId
                LIMIT 1
            ];

            // Determine file name - use PathOnClient if available, otherwise build from Title and FileExtension
            String fileName = cv.Title;
            if (String.isNotBlank(cv.FileExtension)) {
                fileName += '.' + cv.FileExtension;
            }

            // Get the file content as Blob
            Blob fileContent = cv.VersionData;
            DropboxFile file = Dropbox.uploadFile(fileContent, fileName, filePath);
            /** Store the information inside Salesforce */
            if(!String.isBlank(file.id)){
                DropBoxFile__c dropboxFile = new DropBoxFile__c();
                dropboxFile.Dropbox_File_Id__c = file.id;
                dropboxFile.Name = fileName;
                dropboxFile.Dropbox_Path__c = file.path;
                dropboxFile.File_Size__c = file.size;
                dropboxFile.RecordId__c = recordId;
                dropboxFile.Content_Document_Id__c = cv.ContentDocumentId;
                dropboxFile.ServerUrl__c = 'https://www.dropbox.com/home'+file.path;

                insert as system dropboxFile;
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}