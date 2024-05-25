/**
 * @description       : 
 * @author            : Amit Singh - PantherSchools
 * @group             : 
 * @last modified on  : 05-22-2024
 * @last modified by  : Amit Singh - PantherSchools
**/
public with sharing class BulkAPIService {
    
    public static void processCSVFromFiles(String fileTitle) {
        ContentVersion file = [SELECT Id, Title, VersionData FROM ContentVersion WHERE Title = :fileTitle LIMIT 1];
        Blob csvBlob = file.VersionData;
        String csvContent = csvBlob.toString();
        bulkAPIOperation(csvContent);
    }

    private static void bulkAPIOperation(String csvContent) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(URL.getOrgDomainUrl().toExternalForm() + '/services/data/v60.0/jobs/ingest/');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());

        String jobBody = '{"object":"Account","operation":"insert","contentType":"CSV","lineEnding": "LF"}';
        req.setBody(jobBody);

        Http http = new Http();
        HttpResponse res = http.send(req);
        System.debug(res.getBody());
        if (res.getStatusCode() != 200) {
            System.debug('Failed to create job: ' + res.getBody());
            return;
        }

        Map<String, Object> jobInfo = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
        String jobId = (String) jobInfo.get('id');

        HttpRequest batchReq = new HttpRequest();
        batchReq.setEndpoint(URL.getOrgDomainUrl().toExternalForm() + '/services/data/v60.0/jobs/ingest/'+jobId+'/batches/');
        batchReq.setMethod('PUT');
        batchReq.setHeader('Content-Type', 'text/csv');
        batchReq.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
        batchReq.setBody(csvContent);

        HttpResponse batchRes = http.send(batchReq);
        System.debug(batchRes.getBody());
        if (batchRes.getStatusCode() != 201 && batchRes.getStatusCode() != 200) {
            System.debug('Failed to add batch: ' + batchRes.getBody());
            return;
        }

        HttpRequest closeReq = new HttpRequest();
        closeReq.setEndpoint(URL.getOrgDomainUrl().toExternalForm() + '/services/data/v60.0/jobs/ingest/' + jobId);
        closeReq.setMethod('PATCH');
        closeReq.setHeader('Content-Type', 'application/json');
        closeReq.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
        closeReq.setBody('{"state":"UploadComplete"}');

        HttpResponse closeRes = http.send(closeReq);
        System.debug(closeRes.getBody());
        if (closeRes.getStatusCode() != 200 && closeRes.getStatusCode() != 201) {
            System.debug('Failed to close job: ' + closeRes.getBody());
        }
    }
}
