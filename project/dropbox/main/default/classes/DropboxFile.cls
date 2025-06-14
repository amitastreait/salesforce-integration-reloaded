public with sharing class DropboxFile {
    @AuraEnabled public String id;
    @AuraEnabled public String name;
    @AuraEnabled public String path;
    @AuraEnabled public Boolean isFolder;
    @AuraEnabled public Integer size;
    @AuraEnabled public String modifiedTime;

    public DropboxFile() {
        this.id = '';
        this.name = '';
        this.path = '';
        this.isFolder = false;
        this.size = 0;
        this.modifiedTime = '';
    }
}