// Anonymous Apex — PostGrid structured address verification
String line1      = '20-20 Bay St';
String line2      = 'Floor 2';
String city       = 'Toronto';
String state      = 'ON';
String postalCode = 'M5J 2N8';
String country    = 'CA';
String recipient  = 'Amit Singh';

PostGridAddressVerification.verifyStructuredAddress(
    line1,
    line2,
    city,
    state,
    postalCode,
    country,
    recipient
);