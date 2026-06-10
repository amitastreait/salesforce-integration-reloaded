public class FreshdeskTicketsController {
    @AuraEnabled
    public static HttpResponseWrapper createTicket(Map<String, Object> inputMap){
        HttpResponseWrapper wrapper = FreshdeskService.createTicket(inputMap);
        return wrapper;
    }
}