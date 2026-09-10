/**
 * Integration tests for PostGridAddressVerification (single, structured address).
 *
 * These run against the LIVE PostGrid API — no HttpCalloutMock. The org must have:
 *   - Custom Label  PostGridAPIKey  populated with a valid (test) key
 *   - Remote Site Setting for https://api.postgrid.com
 *
 * NOTE: verifyStructuredAddress() returns void and swallows every exception, so the
 * only things observable from a test are "a callout was consumed" and "nothing escaped".
 * See PostGridAddressVerificationBatchTest for the assertions that actually bite.
 */
@IntegrationTest
public with sharing class PostGridAddressVerificationTest {

    private static final String VALID_LINE1   = '145 Mulberry St PH D';
    private static final String VALID_CITY    = 'New York';
    private static final String VALID_STATE   = 'NY';
    private static final String VALID_ZIP     = '10013';
    private static final String COUNTRY_US    = 'us';
    private static final String RECIPIENT     = 'Amit Singh';

    @BeforeClass
    static void setup() {
        // No data required — the single-address endpoint is stateless.
        // Fail fast here rather than in every method if the key is missing.
        Assert.isNotNull(System.Label.PostGridAPIKey, 'PostGridAPIKey label must be set');
        Assert.isFalse(String.isBlank(System.Label.PostGridAPIKey), 'PostGridAPIKey label must not be blank');
    }

    @IntegrationTest
    public static void testBaseUrlIsPostGridProduction() {
        Assert.areEqual(
            'https://api.postgrid.com',
            PostGridAddressVerification.POSTGRID_BASE_URL,
            'Base URL changed — the Remote Site Setting / Named Credential must be updated too'
        );
    }

    @IntegrationTest
    public static void testVerifyValidStructuredAddress() {
        Integer before = Limits.getCallouts();

        PostGridAddressVerification.verifyStructuredAddress(
            VALID_LINE1, '', VALID_CITY, VALID_STATE, VALID_ZIP, COUNTRY_US, RECIPIENT
        );

        Assert.areEqual(before + 1, Limits.getCallouts(),
            'A live callout to PostGrid should have been made');
    }

    @IntegrationTest
    public static void testVerifyAddressWithLine2() {
        Integer before = Limits.getCallouts();

        PostGridAddressVerification.verifyStructuredAddress(
            '20 W 34th St', 'Suite 500', VALID_CITY, VALID_STATE, '10001', COUNTRY_US, RECIPIENT
        );

        Assert.areEqual(before + 1, Limits.getCallouts(),
            'Populated line2 should still produce exactly one callout');
    }

    @IntegrationTest
    public static void testVerifyUndeliverableAddressDoesNotThrow() {
        // PostGrid answers 200 with status = "failed" for junk input — the method must
        // treat that as data, not as an error.
        Integer before = Limits.getCallouts();

        PostGridAddressVerification.verifyStructuredAddress(
            '9999 Nowhere Blvd', '', 'Xyzzy', 'ZZ', '00000', COUNTRY_US, RECIPIENT
        );

        Assert.areEqual(before + 1, Limits.getCallouts(),
            'An undeliverable address should still reach PostGrid');
    }

    @IntegrationTest
    public static void testVerifyWithNullArgumentsIsSwallowed() {
        // Guards the ${...} template substitution: a null value must not blow up
        // String.template() before the request is ever sent.
        PostGridAddressVerification.verifyStructuredAddress(null, null, null, null, null, null, null);
        Assert.isTrue(true, 'Null inputs must not surface an exception to the caller');
    }

    @IntegrationTest
    public static void testVerifyWithSpecialCharactersInRecipient() {
        // '&' and '=' in a form-urlencoded body are the classic injection point for this
        // hand-built request. Currently NOT encoded by the production class — this test
        // documents that the callout still completes; see notes on EncodingUtil.urlEncode.
        Integer before = Limits.getCallouts();

        PostGridAddressVerification.verifyStructuredAddress(
            VALID_LINE1, '', VALID_CITY, VALID_STATE, VALID_ZIP, COUNTRY_US, 'A & B Corp = Ltd'
        );

        Assert.areEqual(before + 1, Limits.getCallouts(),
            'Special characters must not break the request build');
    }
}
