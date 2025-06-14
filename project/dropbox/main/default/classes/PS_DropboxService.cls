/**
 * @description Main service class for Dropbox API integration using Named Credentials
 * @author Amit Singh
 * @date 2025-05-06
 */
public with sharing class PS_DropboxService {
    
    // Named Credential to securely store Dropbox API details (OAuth 2.0)
    private static final String NAMED_CREDENTIAL = 'DropboxContent';

    /**
     * @description Lists files and folders in a Dropbox directory
     * @param path Directory path to list contents from
     * @return List<DropboxFile> List of files and folders
     */
    // DropboxService.listFiles('/Blogs/Salesforce%20Integration');
    public static List<DropboxFile> listFiles(String path) {
        List<DropboxFile> files = new List<DropboxFile>();
        
        try {
            HttpRequest request = prepareRequest('/2/files/list_folder', 'POST');
            request.setEndpoint('callout:DropboxAPI' + '/2/files/list_folder');
            Map<String, Object> requestBody = new Map<String, Object>{
                'path' => path,
                'recursive' => false,
                'include_media_info' => false,
                'include_deleted' => false
            };
            request.setBody(JSON.serialize(requestBody));

            HttpResponse response = sendRequest(request);

            if (response.getStatusCode() == 200) {
                Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                List<Object> entries = (List<Object>) responseMap.get('entries');
                System.debug('Files: ' + JSON.serializePretty(entries));
                for (Object entry : entries) {
                    Map<String, Object> fileMap = (Map<String, Object>) entry;
                    DropboxFile file = new DropboxFile();
                    file.id = (String) fileMap.get('id');
                    file.name = (String) fileMap.get('name');
                    file.path = (String) fileMap.get('path_display');
                    file.isFolder = 'folder'.equals(fileMap.get('.tag'));
                    file.size = fileMap.containsKey('size') ? (Integer) fileMap.get('size') : 0;
                    file.modifiedTime = fileMap.containsKey('server_modified') ? 
                                       (String) fileMap.get('server_modified') : '';
                    files.add(file);
                }
                System.debug('Files: ' + JSON.serializePretty(files));
            } else {
                handleErrorResponse(response);
            }
        } catch (Exception e) {
            throw new DropboxException('Error listing files: ' + e.getMessage());
        }
        
        return files;
    }

    /**
     * @description Uploads a file to Dropbox
     * @param fileContent Content of the file as Blob
     * @param fileName Name of the file
     * @param path Path where to upload the file
     * @return DropboxFile The uploaded file metadata
     */
    public static DropboxFile uploadFile(Blob fileContent, String fileName, String path) {
        try {
            HttpRequest request = new HttpRequest();
            request.setEndpoint('callout:' + NAMED_CREDENTIAL + '/2/files/upload');
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/octet-stream');
            fileName = EncodingUtil.urlEncode(fileName.replaceAll(' ', '_'), 'UTF-8');
            String fullPath = path.endsWith('/') ? path + fileName : path + '/' + fileName;
            Map<String, Object> argsMap = new Map<String, Object>{
                'path' => fullPath,
                'mode' => 'overwrite',
                'autorename' => true,
                'mute' => false
            };

            System.debug('File content size: ' + fileContent.size());
            System.debug('File name: ' + fileName);
            System.debug('Dropbox-API-Arg: ' + JSON.serialize(argsMap));
            System.debug('Full path: ' + fullPath);

            request.setHeader('Dropbox-API-Arg', JSON.serialize(argsMap));
            
            request.setBodyAsBlob(fileContent);

            HttpResponse response = sendRequest(request);

            if (response.getStatusCode() != 200) {
                System.debug('Error Status Code: ' + response.getStatusCode());
                System.debug('Error Response Body: ' + response.getBody());
                handleErrorResponse(response);
                return null;
            }
            
            if (response.getStatusCode() == 200) {
                Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                DropboxFile file = new DropboxFile();
                file.id = (String) responseMap.get('id');
                file.name = (String) responseMap.get('name');
                file.path = (String) responseMap.get('path_display');
                file.isFolder = false;
                file.size = (Integer) responseMap.get('size');
                file.modifiedTime = (String) responseMap.get('server_modified');
                return file;
            } else {
                handleErrorResponse(response);
                return null;
            }
        } catch (Exception e) {
            throw new DropboxException('Error uploading file: ' + e.getMessage());
        }
    }

    // DropboxService.downloadAndCreateRecordFile('/Blogs/Salesforce%20Integration/panther schools.png', '0010o00002xBPHiAAO');
    /**
     * @description Downloads a file from Dropbox
     * @param filePath Path of the file to download
     * @return Blob Content of the file
     */
    public static DropboxFile downloadFile(String filePath, String recordId) {
        try {
            HttpRequest request = new HttpRequest();
            request.setEndpoint('callout:' + NAMED_CREDENTIAL + '/2/files/download');
            request.setMethod('POST');
            request.setHeader('Content-Type', '');

            Map<String, Object> argsMap = new Map<String, Object>{
                'path' => filePath
            };
            request.setHeader('Dropbox-API-Arg', JSON.serialize(argsMap));
            HttpResponse response = sendRequest(request);
            if (response.getStatusCode() == 200) {
                Map<String, Object> metadata = (Map<String, Object>) JSON.deserializeUntyped(response.getHeader('Dropbox-Api-Result'));
                // Get file content
                Blob fileContent = response.getBodyAsBlob();
                DropboxFile file = new DropboxFile();
                file.fileContent = fileContent;
                file.metadata = metadata;
                file.recordId = recordId;
                return file;
            } else {
                handleErrorResponse(response);
                return null;
            }
        } catch (Exception e) {
            throw new DropboxException('Error downloading file: ' + e.getMessage());
        }
    }

    /**
     * @description Creates a folder in Dropbox
     * @param path Path where to create the folder
     * @return DropboxFile The created folder metadata
     */
    //DropboxService.createFolder('/Blogs/Salesforce%20Integration/PS_Testing');
    public static DropboxFile createFolder(String path) {
        try {
            HttpRequest request = prepareRequest('/2/files/create_folder_v2', 'POST');
            request.setEndpoint('callout:DropboxAPI' + '/2/files/create_folder_v2');
            Map<String, Object> requestBody = new Map<String, Object>{
                'path' => path,
                'autorename' => true
            };

            request.setBody(JSON.serialize(requestBody));

            HttpResponse response = sendRequest(request);

            if (response.getStatusCode() == 200) {
                Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                Map<String, Object> metadata = (Map<String, Object>) responseMap.get('metadata');

                DropboxFile folder = new DropboxFile();
                folder.id = (String) metadata.get('id');
                folder.name = (String) metadata.get('name');
                folder.path = (String) metadata.get('path_display');
                folder.isFolder = true;

                return folder;
            } else {
                handleErrorResponse(response);
                return null;
            }
        } catch (Exception e) {
            throw new DropboxException('Error creating folder: ' + e.getMessage());
        }
    }

    /**
     * @description Deletes a file or folder from Dropbox
     * @param path Path of the file or folder to delete
     * @return Boolean True if successfully deleted
     */
    public static Boolean deleteFile(String path) {
        try {
            HttpRequest request = prepareRequest('/2/files/delete_v2', 'POST');
            request.setEndpoint('callout:DropboxAPI' + '/2/files/create_folder_v2');
            Map<String, Object> requestBody = new Map<String, Object>{
                'path' => path
            };

            request.setBody(JSON.serialize(requestBody));

            HttpResponse response = sendRequest(request);

            if (response.getStatusCode() == 200) {
                return true;
            } else {
                handleErrorResponse(response);
                return false;
            }
        } catch (Exception e) {
            throw new DropboxException('Error deleting file: ' + e.getMessage());
        }
    }

    /**
     * @description Gets metadata for a file or folder
     * @param path Path of the file or folder
     * @return DropboxFile The file or folder metadata
     */
    public static DropboxFile getMetadata(String path) {
        try {
            HttpRequest request = prepareRequest('/files/get_metadata', 'POST');

            Map<String, Object> requestBody = new Map<String, Object>{
                'path' => path,
                'include_media_info' => false,
                'include_deleted' => false,
                'include_has_explicit_shared_members' => false
            };

            request.setBody(JSON.serialize(requestBody));

            HttpResponse response = sendRequest(request);

            if (response.getStatusCode() == 200) {
                Map<String, Object> metadata = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());

                DropboxFile file = new DropboxFile();
                file.id = (String) metadata.get('id');
                file.name = (String) metadata.get('name');
                file.path = (String) metadata.get('path_display');
                file.isFolder = '.folder'.equals(metadata.get('.tag'));
                file.size = metadata.containsKey('size') ? (Integer) metadata.get('size') : 0;
                file.modifiedTime = metadata.containsKey('server_modified') ? 
                                   (String) metadata.get('server_modified') : '';
                return file;
            } else {
                handleErrorResponse(response);
                return null;
            }
        } catch (Exception e) {
            throw new DropboxException('Error getting metadata: ' + e.getMessage());
        }
    }

    /**
     * @description Prepares an HTTP request with proper headers for Dropbox API
     * @param endpoint API endpoint to call
     * @param method HTTP method to use
     * @return HttpRequest The prepared request
     */
    private static HttpRequest prepareRequest(String endpoint, String method) {
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:' + NAMED_CREDENTIAL + endpoint);
        request.setMethod(method);
        request.setHeader('Content-Type', 'application/json');
        return request;
    }

    /**
     * @description Sends an HTTP request and handles rate limiting
     * @param request The request to send
     * @return HttpResponse The response from Dropbox
     */
    private static HttpResponse sendRequest(HttpRequest request) {
        Http http = new Http();
        HttpResponse response = http.send(request);
        if (response.getStatusCode() == 429) {
            Integer retryAfter = Integer.valueOf(response.getHeader('Retry-After'));
            if (retryAfter != null && retryAfter > 0 && retryAfter < 60) {
                Long millisToWait = retryAfter * 1000L;
                Long startTime = System.currentTimeMillis();
                while (System.currentTimeMillis() - startTime < millisToWait) {
                    // passive wait
                }
                return http.send(request);
            }
        }

        return response;
    }

    /**
     * @description Handles error responses from Dropbox API
     * @param response The HTTP response to process
     */
    private static void handleErrorResponse(HttpResponse response) {
        String errorMessage = 'Dropbox API Error: ' + response.getStatusCode() + ' ' + response.getStatus();
        try {
            Map<String, Object> errorMap = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            if (errorMap.containsKey('error_summary')) {
                errorMessage += ' - ' + errorMap.get('error_summary');
            } else if (errorMap.containsKey('error')) {
                errorMessage += ' - ' + JSON.serialize(errorMap.get('error'));
            }
        } catch (Exception e) {
            // Ignore parsing issues, just use default message
        }

        throw new DropboxException(errorMessage);
    }

    /**
     * @description Custom exception for Dropbox API errors
     */
    public class DropboxException extends Exception {}

    /**
     * @description Data structure for Dropbox files and folders
     */
    public class DropboxFile {
        @AuraEnabled public String id;
        @AuraEnabled public String name;
        @AuraEnabled public String path;
        @AuraEnabled public Boolean isFolder;
        @AuraEnabled public Integer size;
        @AuraEnabled public String modifiedTime;
        public Blob fileContent;
        public Map<String, Object> metadata;
        public Id recordId;

        public DropboxFile() {
            this.id = '';
            this.name = '';
            this.path = '';
            this.isFolder = false;
            this.size = 0;
            this.modifiedTime = '';
        }
    }
}