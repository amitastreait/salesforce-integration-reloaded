/**
 * @description       : 
 * @author            : Amit Singh - PantherSchools
 * @group             : 
 * @last modified on  : 05-25-2024
 * @last modified by  : Amit Singh - PantherSchools
**/
public with sharing class MetadataUtils {
    
    public static MetadataService.MetadataPort createService() {
        MetadataService.MetadataPort service = new MetadataService.MetadataPort();
        service.SessionHeader = new MetadataService.SessionHeader_element();
        service.SessionHeader.sessionId = UserInfo.getSessionId();
        return service;
    }

    // MetadataUtils.listMetadata();
    public static void listMetadata(){
        MetadataService.MetadataPort service = createService();

        List<MetadataService.ListMetadataQuery> queries = new List<MetadataService.ListMetadataQuery>();
        
        MetadataService.ListMetadataQuery query = new MetadataService.ListMetadataQuery();
        query.type_x = 'CustomObject';

        MetadataService.ListMetadataQuery query_profile = new MetadataService.ListMetadataQuery();
        query_profile.type_x = 'Profile';
        
        queries.add(query);
        queries.add(query_profile);

        List<MetadataService.FileProperties> properties = service.listMetadata(queries, 60);
        System.debug(System.JSON.serializePretty(properties));
    }
    // MetadataUtils.readMetadata();
    public static void readMetadata(){
        MetadataService.MetadataPort service = createService();
        List<String> itemList = new String[] { 'Admin' };
        //itemList.add();

        /*
            MetadataService.IReadResult result = service.readMetadata('Profile', itemList);
            MetadataService.Profile profileDetails = (MetadataService.Profile) result.getRecords().get(0);
        */
        MetadataService.Profile profileDetails = (MetadataService.Profile)
                            service.readMetadata('Profile', itemList).getRecords()[0];
        //System.debug(System.JSON.serializePretty(profileDetails));
        MetadataService.ProfileLoginHours loginHours = profileDetails.loginHours;
        MetadataService.ProfileLoginIpRange[] loginIpRanges = profileDetails.loginIpRanges;
        System.debug(' loginHours \n '+loginHours);
        System.debug(' loginIpRanges \n '+loginIpRanges);
    }

}