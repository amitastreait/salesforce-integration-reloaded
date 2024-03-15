// Apex Class to handle Google Drive API calls
public class GoogleDriveAPI {

    public static Http http = new Http();
    public static HTTPResponse response;
    public static HttpRequest request;

    // Method to upload file
    public static void uploadFile(String accessToken, String folderId, String fileName, String base64Data) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://www.googleapis.com/upload/drive/v3/files?uploadType=media');
        req.setMethod('POST');
        req.setHeader('Authorization', 'Bearer ' + accessToken);
        req.setHeader('Content-Type', 'application/octet-stream');
        req.setBodyAsBlob(Blob.valueOf(base64Data));
        
        // Add parent folder ID to request body
        String requestBody = '{ "name" : "' + fileName + '", "parents" : ["' + folderId + '"] }';
        req.setBody(requestBody);
        
        Http http = new Http();
        HttpResponse res = http.send(req);
        System.debug(res.getBody());
        if (res.getStatusCode() == 200 || res.getStatusCode() == 201) {
            // Handle successful upload
        } else {
            // Handle upload failure
            throw new AuraHandledException('Error uploading file to Google Drive: ' + res.getBody());
        }
    }

    // Method to create resumable upload session
    public static String createResumableUploadSession(String accessToken, String fileName, String parentId) {
        // Implement logic to create resumable upload session with Google Drive API
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://www.googleapis.com/upload/drive/v3/files?uploadType=resumable');
        req.setMethod('POST');
        req.setHeader('Authorization', 'Bearer ' + accessToken);
        req.setHeader('Content-Type', 'application/json');
        
        String body = '{"name":"' + fileName + '","parents":["' + parentId + '"]}';
        req.setBody(body);
        
        Http http = new Http();
        HttpResponse res = http.send(req);
        System.debug(res.getBody());
        if (res.getStatusCode() == 200 || res.getStatusCode() == 201) {
            String uploadSessionUrl = res.getHeader('Location');
            System.debug(' uploadSessionUrl '+ uploadSessionUrl);
            return uploadSessionUrl;
        } else {
            // Handle error
            return null;
        }
    }
    
    // Method to upload file using resumable upload
    public static void uploadFileUsingResumableUpload(String accessToken, String uploadSessionUrl, Blob fileBody) {
        // Implement logic to upload file using resumable upload with Google Drive API
        HttpRequest req = new HttpRequest();
        req.setEndpoint(uploadSessionUrl);
        req.setMethod('PUT');
        req.setHeader('Authorization', 'Bearer ' + accessToken);
        req.setHeader('Content-Length', String.valueOf(fileBody.size()));
        req.setHeader('Content-Type', 'application/octet-stream');
        req.setBodyAsBlob(fileBody);
        
        Http http = new Http();
        HttpResponse res = http.send(req);
        System.debug(res.getBody());
        if (res.getStatusCode() != 200 && res.getStatusCode() != 201) {
            // Handle error
        }
    }

    public static void getProfile(String userEmail) {
        request = new HttpRequest();
        request.setMethod('GET');
        request.setEndpoint('callout:Google_Drive/gmail/v1/users/' + userEmail + '/profile');
        response = http.send(request);
        System.debug(response.getBody());
    }

    public static void getUserDrafts(String userEmail) {
        request = new HttpRequest();
        request.setMethod('GET');
        request.setEndpoint('callout:Google_Drive/gmail/v1/users/' + userEmail + '/drafts');
        response = http.send(request);
        System.debug(response.getBody());
    }

    public static void getMyCalendar() {
        request = new HttpRequest();
        request.setMethod('GET');
        request.setEndpoint('callout:Google_Drive/calendar/v3/users/me/calendarList');
        response = http.send(request);
        System.debug(response.getBody());
    }

    public static void run(){

    }

    public static void exportWorkSpaceFiles(String fileId, String mimeType){
        if(String.isBlank(fileId)){
            fileId = '1AH9M7xYsK8jBxbghLO8Ie0bqqnf4qALe';
        }
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        req.setEndpoint('callout:Google_Drive'+'/drive/v2/files/'+ fileId+'/export?mimeType='+mimeType);
        req.setHeader('Content-Type', 'application/json');
        req.setTimeout(12000);

        HttpResponse resp = new HttpResponse();
        resp = http.send(req);
        if(resp.getStatusCode() == 200){
            ContentVersion contentVersion_1 = new ContentVersion(
                Title='What is Salesforce Administration and How to Get Certified?',
                PathOnClient ='What is Salesforce Administration and How to Get Certified?.docx',
                VersionData = resp.getBodyAsBlob(),
                origin = 'H'
            );
            insert contentVersion_1;
            System.debug ('Content Version Created '+ contentVersion_1.Id);
        }else{
            System.debug(' '+ resp.getBody() );
        }
    }

    // Method to fetch files from G Drive.
    public static void getSingleFile(String fileId) {
        if(String.isBlank(fileId)){
            fileId = '1AH9M7xYsK8jBxbghLO8Ie0bqqnf4qALe';
        }
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        req.setEndpoint('callout:Google_Drive'+'/drive/v2/files/'+ fileId+'?alt=media');
        req.setHeader('Content-Type', 'application/json');
        req.setTimeout(12000);

        HttpResponse resp = new HttpResponse();
        resp = http.send(req);

        if(resp.getStatusCode() == 200){
            //Blob bodyBlob=Blob.valueOf(test);
            ContentVersion contentVersion_1 = new ContentVersion(
                Title='Published [CRS-Sep-8 - AmitS] What is Salesforce Administration and How to Get Certified?',
                PathOnClient ='Published [CRS-Sep-8 - AmitS] What is Salesforce Administration and How to Get Certified?.docx',
                //VersionData = bodyblob,
                VersionData = resp.getBodyAsBlob(),
                origin = 'H'
            );
            insert contentVersion_1;
        }else{
            System.debug(' '+resp.getBody() );
        }
    }
    public static void getFiles() {
        request = new HttpRequest();
        request.setMethod('GET');
        request.setEndpoint('callout:Google_Drive/drive/v3/files');
        response = http.send(request);
        System.debug(response.getBody());
    }
    
    public static void UploadFile(String fileName, String bodyEncoded, String contentType, String accessToken, String folderId) {
        String fileExtension = fileName.substring(fileName.indexOf('.')+1, fileName.length());
        String boundary = '----WebKitFormBoundary7MA4YWxkTrZu0gW';
        String header = '\r\n--' + boundary + '\r\n';
        String footer = '\r\n--' + boundary + '--';
        String fileNameToUpload = fileName;
        List<String> listofFolderId = new List<String>();
        listofFolderId.add(folderId.trim());
        String body = header + 'Content-Type: application/json\r\n\r\n'
            +'{ "title" : "' + fileNameToUpload + '",' + '"parents": [{"kind": "drive#fileLink","id": "'+folderId+'"}]'+','
            + ' "mimeType" : "' + contentType + '" }' + header + 'Content-Type: ' + contentType
            + '\r\n' + 'Content-Transfer-Encoding: base64\r\n' + '\r\n' + bodyEncoded + footer;
        Http https = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://www.googleapis.com/upload/drive/v2/files?uploadType=multipart');
        req.setHeader('Content-Type', 'multipart/mixed; boundary="' + boundary + '"');
        req.setHeader('Content-length', String.valueOf(body.length()));
        req.setBody(body);
        req.setMethod('POST');
        req.setHeader('Authorization', 'Bearer ' + accessToken);
        HttpResponse response = https.send(req);
        System.debug(' response '+response.getBody() );
    }

    public class GoogleInputWrapper{
        public String fileId;
        public String mimeType;
        public String fileName;
    }
}