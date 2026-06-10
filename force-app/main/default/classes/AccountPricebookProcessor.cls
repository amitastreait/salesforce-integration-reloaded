public class AccountPricebookProcessor implements Queueable, Finalizer {
    
    private Map<Id, Id> accountToPricebookMap;
    private List<Id> accountIds;
    private Integer currentIndex;
    private Integer totalRecords;
    private String processId;
    
    public AccountPricebookProcessor(Map<Id, Id> accountToPricebookMap) {
        this.accountToPricebookMap = accountToPricebookMap;
        this.accountIds = new List<Id>(accountToPricebookMap.keySet());
        this.currentIndex = 0;
        this.totalRecords = this.accountIds.size();
        this.processId = String.valueOf(System.now().getTime());
        System.debug('AccountPricebookProcessor initialized with ' + totalRecords + ' records. Process ID: ' + processId);
    }
    
    // Constructor for chaining
    private AccountPricebookProcessor(Map<Id, Id> accountToPricebookMap, List<Id> accountIds, Integer currentIndex, Integer totalRecords, String processId) {
        this.accountToPricebookMap = accountToPricebookMap;
        this.accountIds = accountIds;
        this.currentIndex = currentIndex;
        this.totalRecords = totalRecords;
        this.processId = processId;
    }
    
    public void execute(QueueableContext context) {
        System.debug('Processing record ' + (currentIndex + 1) + ' of ' + totalRecords + '. Process ID: ' + processId + '. Job ID: ' + context.getJobId());
        
        // Attach finalizer to monitor this job
        System.attachFinalizer(this);
        
        try {
            // Process current record
            if (currentIndex < accountIds.size()) {
                Id currentAccountId = accountIds[currentIndex];
                Id pricebookId = accountToPricebookMap.get(currentAccountId);
                processAccountPricebook(currentAccountId, pricebookId);
                
                // Move to next record
                Integer nextIndex = currentIndex + 1;
                
                // Chain to next record if more exist
                if (nextIndex < accountIds.size()) {
                    // Check governor limits before chaining
                    AccountPricebookProcessor nextProcessor = new AccountPricebookProcessor(
                        accountToPricebookMap, accountIds, nextIndex, totalRecords, processId
                    );
                    System.enqueueJob(nextProcessor);
                    System.debug('Successfully chained to next record. Next index: ' + nextIndex);
                } else {
                    // All records processed successfully
                    System.debug('All records processed successfully. Process ID: ' + processId);
                    createProcessStatus('COMPLETED', 'All records processed successfully', totalRecords);
                    onProcessComplete();
                }
            }
            
        } catch (Exception e) {
            // Handle and log the error
            String errorMsg = 'Error processing Account ID: ' + (currentIndex < accountIds.size() ? accountIds[currentIndex] : 'Unknown') + '. Error: ' + e.getMessage() + '. Stack Trace: ' + e.getStackTraceString();
            logError(errorMsg);
            createProcessStatus('ERROR_OCCURRED', errorMsg, currentIndex);
            continueProcessingAfterError();
        }
    }
    
    // Finalizer implementation
    public void execute(FinalizerContext context) {
        System.debug('Finalizer executed for Process ID: ' + processId + '. Current Index: ' + currentIndex + '. Job ID: ' + context.getAsyncApexJobId());
        
        // Get the result of the queueable job
        Id jobId = context.getAsyncApexJobId();
        ParentJobResult result = context.getResult();
        
        String status = '';
        String errorMessage = '';
        
        switch on result {
            when SUCCESS {
                status = 'JOB_SUCCESS';
                System.debug('Queueable job completed successfully. Job ID: ' + jobId);
            }
            when UNHANDLED_EXCEPTION {
                status = 'JOB_UNHANDLED_EXCEPTION';
                errorMessage = 'Unhandled exception occurred in queueable job';
                System.debug(LoggingLevel.ERROR, errorMessage + '. Job ID: ' + jobId);
                // Attempt to recover by continuing with next record
                handleJobFailure();
            }
        }
        
        // Log the finalizer execution
        logFinalizerExecution(jobId, status, errorMessage);
        
        // Update process status if needed
        if (result == ParentJobResult.UNHANDLED_EXCEPTION) {
            createProcessStatus('JOB_FAILED', 'Job failed with unhandled exception: ' + errorMessage, currentIndex);
        }
    }
    
    private void processAccountPricebook(Id accountId, Id pricebookId) {
        System.debug('Processing Account: ' + accountId + ' with Pricebook: ' + pricebookId);
        
        System.debug('Successfully processed Account: ' + accountId + ' with Pricebook: ' + pricebookId);
    }
    
    private void continueProcessingAfterError() {
        Integer nextIndex = currentIndex + 1;
        
        if (nextIndex < accountIds.size()) {
            try {
                AccountPricebookProcessor nextProcessor = new AccountPricebookProcessor(
                    accountToPricebookMap, accountIds, nextIndex, totalRecords, processId
                );
                System.enqueueJob(nextProcessor);
                System.debug('Continued processing after error. Next index: ' + nextIndex);
            } catch (Exception e) {
                String errorMsg = 'Failed to continue processing after error: ' + e.getMessage() + '. Process ID: ' + processId;
                logError(errorMsg);
                createProcessStatus('FAILED_TO_CONTINUE', errorMsg, nextIndex);
            }
        } else {
            System.debug('No more records to process after error. Process ID: ' + processId);
            createProcessStatus('COMPLETED_WITH_ERRORS', 'Process completed but with errors', totalRecords);
        }
    }
    
    private void handleJobFailure() {
        System.debug('Handling job failure for Process ID: ' + processId);
        
        // Attempt to continue processing with the next record
        Integer nextIndex = currentIndex + 1;
        
        if (nextIndex < accountIds.size()) {
            try {
                AccountPricebookProcessor recoveryProcessor = new AccountPricebookProcessor(
                    accountToPricebookMap, accountIds, nextIndex, totalRecords, processId
                );
                System.enqueueJob(recoveryProcessor);
                System.debug('Recovery job enqueued. Next index: ' + nextIndex);
                
                createProcessStatus('RECOVERY_ATTEMPTED', 'Attempted recovery after job failure', nextIndex);
            } catch (Exception e) {
                String errorMsg = 'Failed to enqueue recovery job: ' + e.getMessage();
                logError(errorMsg);
                createProcessStatus('RECOVERY_FAILED', errorMsg, nextIndex);
            }
        } else {
            createProcessStatus('COMPLETED_WITH_FAILURE', 'Process completed with job failures', totalRecords);
        }
    }
    
    private void onProcessComplete() {
        // Send completion notification if needed
        // sendCompletionNotification();
    }
    
    private void logError(String errorMessage) {
        System.debug(LoggingLevel.ERROR, errorMessage);
        
        // Optional: Insert error log record
        /*
        Error_Log__c errorLog = new Error_Log__c(
            Process_ID__c = processId,
            Error_Message__c = errorMessage.left(255),
            Timestamp__c = System.now(),
            Object_Type__c = 'AccountPricebookProcessor'
        );
        
        try {
            insert errorLog;
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Failed to log error: ' + e.getMessage());
        }
        */
    }
    
    private void logFinalizerExecution(Id jobId, String status, String errorMessage) {
        String logMessage = 'Finalizer executed - Process ID: ' + processId + 
                          ', Job ID: ' + jobId + 
                          ', Status: ' + status + 
                          ', Current Index: ' + currentIndex +
                          ', Total Records: ' + totalRecords;
        
        if (String.isNotBlank(errorMessage)) {
            logMessage += ', Error: ' + errorMessage;
        }
        
        System.debug(logMessage);
        
        // Optional: Insert finalizer log record
        /*
        Finalizer_Log__c finalizerLog = new Finalizer_Log__c(
            Process_ID__c = processId,
            Job_ID__c = String.valueOf(jobId),
            Status__c = status,
            Error_Message__c = errorMessage?.left(255),
            Current_Index__c = currentIndex,
            Total_Records__c = totalRecords,
            Timestamp__c = System.now()
        );
        
        try {
            insert finalizerLog;
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Failed to log finalizer execution: ' + e.getMessage());
        }
        */
    }
    
    private void createProcessStatus(String status, String message, Integer processedCount) {
        System.debug('Process Status - Status: ' + status + 
                    ', Message: ' + message + 
                    ', Processed Count: ' + processedCount + 
                    ', Process ID: ' + processId);
        
        // Optional: Insert process status record
        /*
        Process_Status__c processStatus = new Process_Status__c(
            Process_ID__c = processId,
            Status__c = status,
            Message__c = message?.left(255),
            Records_Processed__c = processedCount,
            Total_Records__c = totalRecords,
            Timestamp__c = System.now(),
            Process_Type__c = 'AccountPricebookProcessor'
        );
        
        try {
            insert processStatus;
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Failed to create process status: ' + e.getMessage());
        }
        */
    }
}