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
global class LinkedInRegistrationHandler implements Auth.RegistrationHandler{

    @TestVisible
    private static final String INTERNAL_PROFILE_NAME = 'Chatter Free User';
    @TestVisible
    private static final String COMMUNITY_PROFILE_NAME = 'Customer Community User';

    /**
    * @description Entry point called by Salesforce for the LinkedIn user logging in for the first time.
    *              Routes the provisioning to the Community flow when the login comes from an Experience
    *              Cloud site, otherwise to the internal flow. The returned User is not inserted here,
    *              Salesforce inserts it once this method returns.
    * @author Amit Singh | 09-10-2026
    * @param portalId Id of the Community/Experience Cloud site the user is logging into, null for internal logins
    * @param data User information returned by the LinkedIn Auth. Provider
    * @return User The unsaved User record to be provisioned for this LinkedIn identity
    **/
    global User createUser(Id portalId, Auth.UserData data){
        System.debug(JSON.serializePretty(data));
        if(String.isNotBlank(portalId)) {
            return createCommunityUser(portalId, data);
        }
        return createInternalUser(data);
    }

    /**
    * @description Provisions an Experience Cloud user. The Account and the Contact are inserted here
    *              because a Community User cannot exist without a Contact, and the Contact cannot exist
    *              without an Account. The User is only built and returned, Salesforce inserts it.
    * @author Amit Singh | 09-10-2026
    * @param portalId Id of the Community/Experience Cloud site the user is logging into
    * @param data User information returned by the LinkedIn Auth. Provider
    * @return User The unsaved Community User record linked to the newly created Contact
    **/
    private User createCommunityUser(Id portalId, Auth.UserData data){
        Account account = new Account(
            Name = buildAccountName(data)
        );
        insert account;

        Contact contact = new Contact(
            AccountId = account.Id,
            FirstName = resolveFirstName(data),
            LastName  = resolveLastName(data),
            Email     = data.email
        );
        insert contact;

        User u = buildUser(data, COMMUNITY_PROFILE_NAME);
        u.contactId = contact.Id;
        return u;
    }

    /**
    * @description Provisions an internal (non Community) user. No Account or Contact is needed here, so
    *              only the User record is built and handed back to Salesforce for insertion.
    * @author Amit Singh | 09-10-2026
    * @param data User information returned by the LinkedIn Auth. Provider
    * @return User The unsaved internal User record for this LinkedIn identity
    **/
    private User createInternalUser(Auth.UserData data){
        return buildUser(data, INTERNAL_PROFILE_NAME);
    }

    /**
    * @description Builds the User record shared by both the Community and the internal flow. Username is
    *              derived from the LinkedIn email to keep it unique across the org and the alias is
    *              trimmed to the 8 character limit of the Alias field.
    * @author Amit Singh | 09-10-2026
    * @param data User information returned by the LinkedIn Auth. Provider
    * @param profileName Developer facing name of the Profile to assign to the new User
    * @return User The unsaved User record with the common fields populated
    **/
    private User buildUser(Auth.UserData data, String profileName){
        User u = new User();
        Profile p = [SELECT Id FROM Profile WHERE Name = :profileName LIMIT 1];
        u.username = data.email.substringBefore('@') + '@integration.com.dev';
        u.email = data.email;
        u.lastName = resolveLastName(data);
        u.firstName = resolveFirstName(data);
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
    * @description Resolves the first name from the LinkedIn attribute map, falling back to the other
    *              localized name attribute when the expected one is not returned by LinkedIn.
    * @author Amit Singh | 09-10-2026
    * @param data User information returned by the LinkedIn Auth. Provider
    * @return String The first name to stamp on the Contact and the User
    **/
    private String resolveFirstName(Auth.UserData data){
        return data.attributeMap?.get('localizedLastName') ?? data.attributeMap?.get('localizedFirstName');
    }

    /**
    * @description Resolves the last name from the LinkedIn attribute map, falling back to the other
    *              localized name attribute when the expected one is not returned by LinkedIn.
    * @author Amit Singh | 09-10-2026
    * @param data User information returned by the LinkedIn Auth. Provider
    * @return String The last name to stamp on the Contact and the User
    **/
    private String resolveLastName(Auth.UserData data){
        return data.attributeMap?.get('localizedFirstName') ?? data.attributeMap?.get('localizedLastName');
    }

    /**
    * @description Builds the Account name for the Community user, using the LinkedIn name when available
    *              and falling back to the email so the Account is never created without a Name.
    * @author Amit Singh | 09-10-2026
    * @param data User information returned by the LinkedIn Auth. Provider
    * @return String The Name to use on the Account created for this LinkedIn identity
    **/
    private String buildAccountName(Auth.UserData data){
        String accountName = ((resolveFirstName(data) ?? '') + ' ' + (resolveLastName(data) ?? '')).trim();
        if(String.isBlank(accountName)) {
            accountName = data.email;
        }
        return accountName + ' Account';
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
