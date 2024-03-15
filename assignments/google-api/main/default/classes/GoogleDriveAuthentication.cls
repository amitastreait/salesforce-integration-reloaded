// Apex Class to handle OAuth2 Authentication
public class GoogleDriveAuthentication {
    // Method to get access token from OAuth2
    public static String getAccessToken() {
        Google_Config__mdt config = Google_Config__mdt.getInstance(System.Label.PS_GoogleTokenLabel); // Use Custom Label
        if(config != null){
            Boolean isValid = Assignment_GoogleAPITokenUtils.isValid(config);
            Map<String, Object> fieldWithValuesMap = new Map<String, Object>();
            String accessToken = config.access_token__c;
            if(!isValid){
                fieldWithValuesMap = Assignment_GoogleAPITokenUtils.refreshToken(config);
                accessToken = (String)fieldWithValuesMap.get('access_token__c');
            }

            /*
                TODO: Update The Custom Metadata with New Values
                ! Update the new Access Token
            */
            if(fieldWithValuesMap.size() >0 ){
                String fullName = 'Google_Config.'+System.Label.PS_GoogleTokenLabel;
                String label = System.Label.PS_GoogleTokenLabel;
                CreateUpdateMetadataUtils.createUpdateMetadata(fullName, label, fieldWithValuesMap);
            }
            return accessToken;
        }
        return '';
    }
}
