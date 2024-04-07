/**
 * @description       : 
 * @author            : Amit Singh - PantherSchools
 * @group             : 
 * @last modified on  : 03-31-2024
 * @last modified by  : Amit Singh - PantherSchools
**/
public with sharing class SharepointTokenUtil {
    /*
        ContentVersion version = [SELECT Id, VersionData, Title, FileExtension FROM ContentVersion WHERE Id = '068Hu00000bBYf4IAG' ];
        SharepointTokenUtil.uploadFileToSharePoint(version.Title+'.'+version.FileExtension, version.VersionData);
    */

    // Method to upload a file to SharePoint list
    public static void uploadFileToSharePoint(String fileName, Blob fileBody) {
        try {
            // Ensure file name and body are not empty
            if (String.isBlank(fileName) || fileBody == null || fileBody.size() == 0) {
                throw new IllegalArgumentException('File name and content cannot be empty.');
            }
            // GetFolderByServerRelativeUrl('/Library Name/Folder Name')/Files/add(url='a.txt',overwrite=true)
            String sharepointUrl = 'https://yoursite.sharepoint.com/sites/PSFamily/_api/web/';
            String folderRelativeUrl = 'GetFolderByServerRelativeUrl(\'/Documents/Salesforce\')/Files/add';
            // Create SharePoint HTTP request
            HttpRequest req = new HttpRequest();
            req.setEndpoint(sharepointUrl+folderRelativeUrl+'(url=\'' + EncodingUtil.urlEncode(fileName, 'UTF-8') + '\',overwrite=true)');
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/json;odata=verbose');
            req.setHeader('Accept', 'application/json;odata=verbose');
            req.setHeader('Authorization', 'Bearer ' + getSharePointAccessToken()); // Obtain SharePoint access token
            req.setBodyAsBlob(fileBody);
            
            // Send HTTP request
            Http http = new Http();
            HttpResponse res = http.send(req);
            
            // Check response status
            if (res.getStatusCode() >= 200 && res.getStatusCode() < 300) {
                System.debug('File uploaded successfully to SharePoint.');
            } else {
                throw new CalloutException('Error uploading file to SharePoint. Status code: ' + res.getStatusCode() + ', Response: ' + res.getBody());
            }
        } catch (Exception e) {
            // Proper error handling
            System.debug('Error uploading file to SharePoint: ' + e.getMessage());
            // Handle the error according to your business logic, e.g., log, notify admin, etc.
        }
    }

    // Method to obtain SharePoint access token (replace with your authentication mechanism)
    private static String getSharePointAccessToken() {
        // Implement logic to obtain SharePoint access token, e.g., using OAuth, JWT, etc.
        // Return access token
        return '';
    }

    public static String getAuthorizationUrl() {
        String clientId = 'your_client_id';
        String redirectUri = 'your_redirect_uri';
        String scope = 'openid+profile+email'; // Adjust scope as needed
        
        return 'https://your-sharepoint-authorization-server/authorize?' +
               'response_type=code' +
               '&client_id=' + EncodingUtil.urlEncode(clientId, 'UTF-8') +
               '&redirect_uri=' + EncodingUtil.urlEncode(redirectUri, 'UTF-8') +
               '&scope=' + EncodingUtil.urlEncode(scope, 'UTF-8');
    }

    public static String getAccessToken() {
        String clientId = 'your_client_id';
        String clientSecret = 'your_client_secret';
        String redirectUri = 'your_redirect_uri';
        String authorizationCode = 'authorization_code_from_previous_step';
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://your-sharepoint-authorization-server/token');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.setBody('grant_type=authorization_code' +
                    '&client_id=' + EncodingUtil.urlEncode(clientId, 'UTF-8') +
                    '&client_secret=' + EncodingUtil.urlEncode(clientSecret, 'UTF-8') +
                    '&redirect_uri=' + EncodingUtil.urlEncode(redirectUri, 'UTF-8') +
                    '&code=' + EncodingUtil.urlEncode(authorizationCode, 'UTF-8'));
        
        Http http = new Http();
        HttpResponse res = http.send(req);
        
        if (res.getStatusCode() == 200) {
            Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
            return (String)responseMap.get('access_token');
        } else {
            return null;
        }
    }
}