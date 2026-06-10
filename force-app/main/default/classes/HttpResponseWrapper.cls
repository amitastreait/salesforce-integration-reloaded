public class HttpResponseWrapper {
    @AuraEnabled
    public Integer statusCode;
    @AuraEnabled
    public String message;
    @AuraEnabled
    public String errorMessage;
    @AuraEnabled
    public Boolean isSuccess;
}