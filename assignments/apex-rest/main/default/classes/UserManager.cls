/**
 * @description       : 
 * @author            : Amit Singh - PantherSchools
 * @group             : 
 * @last modified on  : 03-31-2024
 * @last modified by  : Amit Singh - PantherSchools
**/
@RestResource(urlMapping='/v1/UserManager/*')
global with sharing class UserManager {
    
    @HttpPost
    global static void createUser(){

    }

    @httpGet
    global static void fetchUser(){

    }

    @httpPatch
    global static void updateProfile(){

    }

    @httpDelete
    global static void deleteProfile(){

    }
}