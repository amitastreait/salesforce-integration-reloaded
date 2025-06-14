public with sharing class DropboxFileManagerHandler {

    @AuraEnabled(cacheable=true)
    public static sObject queryName(String query){
        try {
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