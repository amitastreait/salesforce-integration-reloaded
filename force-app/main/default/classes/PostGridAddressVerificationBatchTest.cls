/**
 * Integration tests for PostGridAddressVerificationBatch.
 *
 * Runs against the LIVE PostGrid batch endpoint — no HttpCalloutMock. The org must have:
 *   - Custom Label  PostGridAPIKey  populated with a valid (test) key
 *   - Remote Site Setting for https://api.postgrid.com
 *
 * execute() is invoked directly with a null BatchableContext so the callout and the
 * subsequent DML happen synchronously and can be asserted on. testFullBatchRun covers
 * the scheduled path end to end.
 */
@IntegrationTest
public with sharing class PostGridAddressVerificationBatchTest {

    private static final String VALID_NAME   = 'PostGridTest Deliverable';
    private static final String INVALID_NAME = 'PostGridTest Undeliverable';
    private static final String UNTOUCHED_NAME = 'PostGridTest AlreadyVerified';

    @BeforeClass
    static void setup() {
        List<Account> accounts = new List<Account>{
            new Account(
                Name              = VALID_NAME,
                BillingStreet     = '145 Mulberry St PH D',
                BillingCity       = 'New York',
                BillingState      = 'NY',
                BillingPostalCode = '10013',
                BillingCountry    = 'us'
            ),
            new Account(
                Name              = INVALID_NAME,
                BillingStreet     = '9999 Nowhere Blvd',
                BillingCity       = 'Xyzzy',
                BillingState      = 'ZZ',
                BillingPostalCode = '00000',
                BillingCountry    = 'us'
            ),
            new Account(
                Name                            = UNTOUCHED_NAME,
                BillingStreet                   = '20 W 34th St',
                BillingCity                     = 'New York',
                BillingState                    = 'NY',
                BillingPostalCode               = '10001',
                BillingCountry                  = 'us',
                AddressVerificationStatus__c    = 'VERIFIED'
            )
        };
        insert as user accounts;
        // Platform auto-commits. No commitTestOnly() needed in @BeforeClass
    }

    /* ------------------------------------------------------------------ start() */

    @IntegrationTest
    public static void testStartSelectsUnverifiedAccountsCreatedToday() {
        Database.QueryLocator locator = new PostGridAddressVerificationBatch().start(null);
        Database.QueryLocatorIterator it = locator.iterator();

        Set<String> selectedNames = new Set<String>();
        while (it.hasNext()) {
            selectedNames.add(((Account) it.next()).Name);
        }

        Assert.isTrue(selectedNames.contains(VALID_NAME),
            'Accounts with a null verification status must be picked up');
        Assert.isTrue(selectedNames.contains(INVALID_NAME),
            'Accounts with a null verification status must be picked up');
    }

    @IntegrationTest
    public static void testStartSkipsAlreadyVerifiedAccounts() {
        Database.QueryLocator locator = new PostGridAddressVerificationBatch().start(null);
        Database.QueryLocatorIterator it = locator.iterator();

        Set<String> selectedNames = new Set<String>();
        while (it.hasNext()) {
            selectedNames.add(((Account) it.next()).Name);
        }

        Assert.isFalse(selectedNames.contains(UNTOUCHED_NAME),
            'VERIFIED accounts must not be re-sent to PostGrid');
    }

    @IntegrationTest
    public static void testStartRequeryablePicksUpFailedAccounts() {
        Account acc = queryByName(VALID_NAME);
        acc.AddressVerificationStatus__c = 'FAILED';
        update as user acc;
        System.commitTestOnly();

        Database.QueryLocatorIterator it = new PostGridAddressVerificationBatch().start(null).iterator();
        Boolean found = false;
        while (it.hasNext()) {
            if (((Account) it.next()).Name == VALID_NAME) { found = true; }
        }

        Assert.isTrue(found, 'FAILED accounts must be retried on the next run');

        acc.AddressVerificationStatus__c = null;
        update as user acc;
        System.commitTestOnly();
    }

    /* ---------------------------------------------------------------- execute() */

    @IntegrationTest
    public static void testExecuteVerifiesDeliverableAddress() {
        Account acc = queryByName(VALID_NAME);

        new PostGridAddressVerificationBatch().execute(null, new List<Account>{ acc });
        System.commitTestOnly();

        Account updated = queryByName(VALID_NAME);
        Assert.isNotNull(updated.AddressVerificationStatus__c,
            'PostGrid must stamp a verification status on the Account');
        Assert.isTrue(
            new Set<String>{ 'VERIFIED', 'CORRECTED' }.contains(updated.AddressVerificationStatus__c),
            'A real NYC address should come back verified or corrected, got: '
                + updated.AddressVerificationStatus__c
        );
        Assert.areEqual('NEW YORK', updated.BillingCity,
            'The normalised city from PostGrid should be written back');
    }

    @IntegrationTest
    public static void testExecuteFlagsUndeliverableAddress() {
        Account acc = queryByName(INVALID_NAME);

        new PostGridAddressVerificationBatch().execute(null, new List<Account>{ acc });
        System.commitTestOnly();

        Account updated = queryByName(INVALID_NAME);
        Assert.areEqual('FAILED', updated.AddressVerificationStatus__c,
            'A junk address must be marked FAILED');
        Assert.isNotNull(updated.AddressVerificationError__c,
            'The PostGrid error payload must be captured for triage');
    }

    @IntegrationTest
    public static void testExecuteKeepsResultsAlignedWithAccounts() {
        // The class pairs response results to accounts by list index. If PostGrid ever
        // reorders or drops a result, every Account gets the wrong verdict — this is the
        // assertion that catches it.
        List<Account> batch = new List<Account>{
            queryByName(VALID_NAME),
            queryByName(INVALID_NAME)
        };

        new PostGridAddressVerificationBatch().execute(null, batch);
        System.commitTestOnly();

        Account good = queryByName(VALID_NAME);
        Account bad  = queryByName(INVALID_NAME);

        Assert.areNotEqual('FAILED', good.AddressVerificationStatus__c,
            'The deliverable address received the undeliverable result — index misalignment');
        Assert.areEqual('FAILED', bad.AddressVerificationStatus__c,
            'The undeliverable address received the deliverable result — index misalignment');
    }

    @IntegrationTest
    public static void testExecuteDoesNotWipeCityOnFailure() {
        // EXPECTED TO FAIL against the current implementation: execute() assigns
        // result?.verifiedAddress?.city unconditionally, so a failed verification nulls
        // out BillingCity. Fix the class (only assign when the city is non-blank) rather
        // than the test.
        Account acc = queryByName(INVALID_NAME);
        String cityBefore = acc.BillingCity;

        new PostGridAddressVerificationBatch().execute(null, new List<Account>{ acc });
        System.commitTestOnly();

        Account updated = queryByName(INVALID_NAME);
        Assert.areEqual(cityBefore, updated.BillingCity,
            'A failed verification must not erase the address already on the record');
    }

    @IntegrationTest
    public static void testExecuteWithEmptyListDoesNotThrow() {
        // Salesforce never hands execute() an empty chunk, but a manual/retry caller can.
        // Note: the current implementation still spends a callout here — a guard clause
        // at the top of execute() would be worth adding.
        new PostGridAddressVerificationBatch().execute(null, new List<Account>());
        Assert.isTrue(true, 'An empty chunk must not surface an exception');
    }

    /* ----------------------------------------------------------------- finish() */

    @IntegrationTest
    public static void testFinishIsANoOp() {
        new PostGridAddressVerificationBatch().finish(null);
        Assert.isTrue(true, 'finish() must not throw');
    }

    /* ------------------------------------------------------------- full run */

    @IntegrationTest
    public static void testFullBatchRun() {
        // If the platform rejects Test.startTest()/stopTest() inside an @IntegrationTest
        // method, drop this test — the direct execute() tests above already cover the work.
        Test.startTest();
        Id jobId = Database.executeBatch(new PostGridAddressVerificationBatch(), 200);
        Test.stopTest();

        AsyncApexJob job = [SELECT Status, NumberOfErrors, JobItemsProcessed
                            FROM AsyncApexJob
                            WHERE Id = :jobId
                            WITH USER_MODE];
        Assert.areEqual('Completed', job.Status, 'The batch must complete without aborting');
        Assert.areEqual(0, job.NumberOfErrors, 'The batch must complete without errors');

        Account good = queryByName(VALID_NAME);
        Assert.isNotNull(good.AddressVerificationStatus__c,
            'The scheduled path must stamp a status just like a direct execute()');
    }

    /* ----------------------------------------------------------------- helpers */

    private static Account queryByName(String accountName) {
        return [SELECT Id, Name, BillingStreet, BillingCity, BillingState,
                       BillingPostalCode, BillingCountry,
                       AddressVerificationStatus__c, AddressVerificationError__c
                FROM Account
                WHERE Name = :accountName
                WITH USER_MODE
                LIMIT 1];
    }

    @TearDown
    public static void tearDown() {
        delete [SELECT Id FROM Account WHERE Name LIKE 'PostGridTest%' WITH USER_MODE];
    }
}
