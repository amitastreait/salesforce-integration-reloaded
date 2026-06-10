public with sharing class FileManagerController {
    /**
     * @description Get stored files from DropBoxFile__c object for the specified account
     * @param accountId The ID of the account
     * @return List<DropBoxFile__c> List of stored files
     */
    @AuraEnabled(cacheable=true)
    public static List<DropBoxFile__c> getStoredFiles(String accountId) {
        try {
            return [
                SELECT Id, Name, ServerUrl__c, RecordId__c, FileExtension__c, ParentId__c,
                Dropbox_File_Id__c, Dropbox_Path__c, File_Size__c, Content_Document_Id__c,
                Is_Folder__c 
                FROM DropBoxFile__c
                WHERE RecordId__c = :accountId
                ORDER BY Name ASC
            ];
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving stored files: ' + e.getMessage());
        }
    }
}