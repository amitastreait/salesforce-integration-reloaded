public with sharing class Project_DropBoxManager {

    // Project_DropBoxManager.uploadFile('0680o00000RziOVAAZ','0010o00002xBPHiAAO');
    public static void uploadFile(String recordId, String parentId){
        
        HttpRequest httpReq = new HttpRequest();
        httpReq.setEndpoint('callout:DropBox/2/files/upload');
        httpReq.setHeader('Content-Type', 'application/octet-stream');
        httpReq.setMethod('POST');
        httpReq.setTimeout(120000);
        List<ContentVersion> versions = [SELECT VersionData, Title, ContentDocumentId, FileExtension 
                                            FROM
                                                ContentVersion 
                                            WHERE 
                                                Id = :recordId 
                                                AND IsLatest = true 
                                            LIMIT 1
                                    ];
        if(versions !=null && versions.size() > 0 ){
            ContentVersion file = versions.get(0);
            String filePath = '/Documents/'+file.Title.subStringBeforeLast('.')+'.'+file.FileExtension;
            httpReq.setHeader('Dropbox-API-Arg', '{"path":"'+filePath+'","mode":{".tag":"add"},"autorename":false,"mute":false}');
            httpReq.setBodyAsBlob(file.VersionData);
            Http http = new Http();
            try{
                HTTPResponse response = http.send(httpReq);
                System.debug(' response '+ response.getBody() );
                if(response.getStatusCode() == 200 || response.getStatusCode() == 201){
                    /*DropBoxFile__c content = new DropBoxFile__c(
                    	Name = file.Title+'.'+file.FileExtension,
                        ServerUrl__c = 'https://www.dropbox.com/home'+filePath,
                        FileExtension__c = file.FileExtension,
                        RecordId__c = parentId
                    );
                    insert content;*/
                }
            }catch(System.CalloutException calloutEx){
                System.debug(' CalloutException Executed '+ calloutEx.getStackTraceString() );
            }catch(System.Exception ex){
                System.debug(' Exception Executed '+ ex.getStackTraceString() );
            }
        }
    }
}