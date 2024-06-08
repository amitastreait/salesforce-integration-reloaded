/**
 * @description       : 
 * @author            : Amit Singh - PantherSchools
 * @group             : 
 * @last modified on  : 06-08-2024
 * @last modified by  : Amit Singh - PantherSchools
**/
@IsTest
public with sharing class Assignment_CaseTriggerErrorMock implements HttpCalloutMock {
    public HttpResponse respond(HttpRequest req){

        String json = '{ "errorMessage": "This is an error message!" }';

        HttpResponse response = new HttpResponse();
        response.setBody(json);
        response.setHeader('Content-Type', 'application/json');
        response.setStatusCode(403);
        response.setStatus('ERROR');
        return response;
    }
}