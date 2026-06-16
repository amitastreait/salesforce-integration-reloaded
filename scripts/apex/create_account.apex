List<Account> accountsToInsert = new List<Account>{
    new Account(
        Name = 'Acme Technologies US',
        BillingStreet = '350 5th Ave',
        BillingCity = 'New York',
        BillingState = 'NY',
        BillingPostalCode = '10118',
        BillingCountry = 'US',
        ShippingStreet = '1 Liberty Island',
        ShippingCity = 'New York',
        ShippingState = 'NY',
        ShippingPostalCode = '10004',
        ShippingCountry = 'US'
    ),
    new Account(
        Name = 'Pacific Retail Group',
        BillingStreet = '600 Montgomery St',
        BillingCity = 'San Francisco',
        BillingState = 'CA',
        BillingPostalCode = '94111',
        BillingCountry = 'US',
        ShippingStreet = '1 Market St',
        ShippingCity = 'San Francisco',
        ShippingState = 'CA',
        ShippingPostalCode = '94105',
        ShippingCountry = 'US'
    ),
    new Account(
        Name = 'Lone Star Logistics',
        BillingStreet = '2200 Ross Ave',
        BillingCity = 'Dallas',
        BillingState = 'TX',
        BillingPostalCode = '75201',
        BillingCountry = 'US',
        ShippingStreet = '2323 Victory Ave',
        ShippingCity = 'Dallas',
        ShippingState = 'TX',
        ShippingPostalCode = '75219',
        ShippingCountry = 'US'
    ),
    new Account(
        Name = 'Windy City Manufacturing',
        BillingStreet = '233 S Wacker Dr',
        BillingCity = 'Chicago',
        BillingState = 'IL',
        BillingPostalCode = '60606',
        BillingCountry = 'US',
        ShippingStreet = '875 N Michigan Ave',
        ShippingCity = 'Chicago',
        ShippingState = 'IL',
        ShippingPostalCode = '60611',
        ShippingCountry = 'US'
    ),
    new Account(
        Name = 'Sunshine Healthcare',
        BillingStreet = '200 S Biscayne Blvd',
        BillingCity = 'Miami',
        BillingState = 'FL',
        BillingPostalCode = '33131',
        BillingCountry = 'US',
        ShippingStreet = '401 Biscayne Blvd',
        ShippingCity = 'Miami',
        ShippingState = 'FL',
        ShippingPostalCode = '33132',
        ShippingCountry = 'US'
    ),
    new Account(
        Name = 'Maple Leaf Consulting',
        BillingStreet = '100 King St W',
        BillingCity = 'Toronto',
        BillingState = 'ON',
        BillingPostalCode = 'M5X 1A9',
        BillingCountry = 'CA',
        ShippingStreet = '181 Bay St',
        ShippingCity = 'Toronto',
        ShippingState = 'ON',
        ShippingPostalCode = 'M5J 2T3',
        ShippingCountry = 'CA'
    ),
    new Account(
        Name = 'Vancouver Digital Solutions',
        BillingStreet = '1055 W Georgia St',
        BillingCity = 'Vancouver',
        BillingState = 'BC',
        BillingPostalCode = 'V6E 3N9',
        BillingCountry = 'CA',
        ShippingStreet = '200 Burrard St',
        ShippingCity = 'Vancouver',
        ShippingState = 'BC',
        ShippingPostalCode = 'V6C 3L6',
        ShippingCountry = 'CA'
    ),
    new Account(
        Name = 'Prairie Energy Corp',
        BillingStreet = '585 8 Ave SW',
        BillingCity = 'Calgary',
        BillingState = 'AB',
        BillingPostalCode = 'T2P 1G1',
        BillingCountry = 'CA',
        ShippingStreet = '855 2 St SW',
        ShippingCity = 'Calgary',
        ShippingState = 'AB',
        ShippingPostalCode = 'T2P 4K7',
        ShippingCountry = 'CA'
    ),
    new Account(
        Name = 'Ottawa Government Services',
        BillingStreet = '240 Sparks St',
        BillingCity = 'Ottawa',
        BillingState = 'ON',
        BillingPostalCode = 'K1A 0X8',
        BillingCountry = 'CA',
        ShippingStreet = '111 Wellington St',
        ShippingCity = 'Ottawa',
        ShippingState = 'ON',
        ShippingPostalCode = 'K1A 0A9',
        ShippingCountry = 'CA'
    ),
    new Account(
        Name = 'Montreal Innovations',
        BillingStreet = '1250 Rene-Levesque Blvd W',
        BillingCity = 'Montreal',
        BillingState = 'QC',
        BillingPostalCode = 'H3B 4W8',
        BillingCountry = 'CA',
        ShippingStreet = '800 Rue De La Gauchetiere O',
        ShippingCity = 'Montreal',
        ShippingState = 'QC',
        ShippingPostalCode = 'H5A 1K6',
        ShippingCountry = 'CA'
    )
};

insert accountsToInsert;

System.debug('Inserted ' + accountsToInsert.size() + ' Accounts.');