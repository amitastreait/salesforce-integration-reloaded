/**
 * @description       : 
 * @author            : Amit Singh - PantherSchools
 * @group             : 
 * @last modified on  : 03-16-2024
 * @last modified by  : Amit Singh - PantherSchools
**/
public class DropboxAPI {
    
    // Method to list items inside a folder
    public static void listItems(String folderPath, String accessToken) {
        // Create HTTP request
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://api.dropboxapi.com/2/files/list_folder');
        req.setMethod('POST');
        req.setHeader('Authorization', 'Bearer ' + accessToken);
        req.setHeader('Content-Type', 'application/json');
        
        // Set request body
        String requestBody = '{"path": "' + folderPath + '","recursive":false}';
        req.setBody(requestBody);
        
        // Send HTTP request
        Http http = new Http();
        HttpResponse res = http.send(req);
        
        // Handle response
        if (res.getStatusCode() == 200) {
            // Successful response
            String responseBody = res.getBody();
            Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
            List<Object> items = (List<Object>) jsonResponse.get('entries');
            if (items != null && !items.isEmpty()) {
                for (Object item : items) {
                    Map<String, Object> itemMap = (Map<String, Object>) item;
                    String itemName = (String) itemMap.get('name');
                    System.debug('Item Name: ' + itemName);
                }
            }
        } else {
            // Error handling
            System.debug('Error: ' + res.getStatus());
            System.debug('Error Response: ' + res.getBody());
        }
    }
}