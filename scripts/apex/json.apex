CustomerWrapper customer = new CustomerWrapper();
customer.name = 'John Doe';
customer.age = 34;
customer.email = 'john.doe@gmail.com';
customer.phone = null;

//String requestBody = JSON.serialize(customer, true);

String requestBody = JSON.serializePretty(customer, true);
System.debug(requestBody);

// Standard sObject — no wrapper class needed
Account acc = new Account();
acc.Name          = 'Acme Corp';
acc.Industry      = 'Technology';
acc.AnnualRevenue  = 5000000;
acc.Phone         = '415-555-0100';
acc.BillingCity   = null;   
acc.Website       = null;  

String requestBody = JSON.serialize(acc, true);
System.debug(requestBody);