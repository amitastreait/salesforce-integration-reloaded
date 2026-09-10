/**
 * @description       : Auth Provider Registration Handler for the LinkedIn Auth. Provider. Salesforce
 *                      invokes this class during the LinkedIn Single Sign-On flow to decide whether a
 *                      user may be provisioned, to create the User record on the first login and to
 *                      sync the User record on every subsequent login.
 * @author            : Amit Singh - PantherSchools
 * @group             : LinkedIn Integration
 * @last modified on  : 09-10-2026      
 * @last modified by  : Amit Singh - PantherSchools
**/
global class LinkedInRegistrationHandlerV1 implements Auth.RegistrationHandler{

    /**
    * @description Creates the User record for the LinkedIn user logging in for the first time. The
    *              returned User is not inserted here, Salesforce inserts it once this method returns.
    *              Username is derived from the LinkedIn email to keep it unique across the org and the
    *              alias is trimmed to the 8 character limit of the Alias field.
    * @author Amit Singh | 09-10-2026
    * @param portalId Id of the Community/Experience Cloud site the user is logging into, null for internal logins
    * @param data User information returned by the LinkedIn Auth. Provider
    * @return User The unsaved User record to be provisioned for this LinkedIn identity
    **/
    global User createUser(Id portalId, Auth.UserData data){
        System.debug(JSON.serializePretty(data));
        User u = new User();
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Chatter Free User' LIMIT 1];
        u.username = data.email.substringBefore('@') + '@integration.com.dev';
        u.email = data.email;
        u.lastName = data.attributeMap?.get('localizedFirstName') ?? data.attributeMap?.get('localizedLastName');
        u.firstName = data.attributeMap?.get('localizedLastName') ?? data.attributeMap?.get('localizedFirstName');
        String alias = data.email;
        if(alias.length() > 8) {
            alias = alias.substring(0, 8);
        }
        u.alias = alias;
        u.languagelocalekey = 'en_US';
        u.localesidkey = UserInfo.getLocale();
        u.emailEncodingKey = 'UTF-8';
        u.timeZoneSidKey = 'America/Los_Angeles';
        u.profileId = p.Id;
        return u;
    }

    /**
    * @description Called by Salesforce on every login after the User has been provisioned, so the
    *              existing User record can be kept in sync with the latest LinkedIn profile data.
    *              Currently only logs the payload, the update is intentionally commented out.
    * @author Amit Singh | 09-10-2026
    * @param userId Id of the existing Salesforce User mapped to this LinkedIn identity
    * @param portalId Id of the Community/Experience Cloud site the user is logging into, null for internal logins
    * @param data User information returned by the LinkedIn Auth. Provider
    * @return void
    **/
    global void updateUser(Id userId, Id portalId, Auth.UserData data){
        System.debug(JSON.serializePretty(data));
        /* User u = new User(id=userId);
        u.email = data.email;
        u.lastName = data.lastName;
        u.firstName = data.firstName;
        update(u); */
    }

    /**
    * @description Gate that decides whether a User record should be provisioned for the incoming
    *              LinkedIn identity. Only pantherschools.com email addresses are allowed, every other
    *              LinkedIn account is rejected and the login fails.
    * @author Amit Singh | 09-10-2026
    * @param data User information returned by the LinkedIn Auth. Provider
    * @return boolean true when the LinkedIn email belongs to the pantherschools.com domain, false otherwise
    **/
    global boolean canCreateUser(Auth.UserData data) {
        return data.email.endsWith('@pantherschools.com');
    }
}
