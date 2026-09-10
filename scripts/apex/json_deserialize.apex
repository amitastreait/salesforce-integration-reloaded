// Input JSON
String jsonStr = '{' +
  '"Name":"Acme Corp",' +
  '"Industry":"Technology",' +
  '"AnnualRevenue":5000000,' +
  '"Phone":"415-555-0100"' +
'}';

// deserialize
Account acc = (Account) JSON.deserialize(jsonStr, Account.class);
System.debug(acc.Name);           // Acme Corp
System.debug(acc.Industry);       // Technology
System.debug(acc.AnnualRevenue);  // 5000000
System.debug(acc.Phone);          // 415-555-0100

// deserializeStrict — throws JSONException if JSON has unknown fields
String jsonWithExtra = '{"Name":"Acme","UnknownField":"oops"}';
Account safe   = (Account) JSON.deserialize(jsonWithExtra, Account.class);       // OK
Account strict = (Account) JSON.deserializeStrict(jsonWithExtra, Account.class); // throws

// Input JSON
String jsonStr = '{' +
  '"LastName":"Connor",' +
  '"FirstName":"Sarah",' +
  '"Email":"sarah.connor@acme.com",' +
  '"Title":"VP of Engineering"' +
'}';

// deserialize
Contact con = (Contact) JSON.deserialize(jsonStr, Contact.class);
System.debug(con.FirstName);   // Sarah
System.debug(con.LastName);    // Connor
System.debug(con.Email);       // sarah.connor@acme.com
System.debug(con.Title);       // VP of Engineering
System.debug(con.Phone);       // null — not in JSON
System.debug(con.Department);  // null
System.debug(con.Birthdate);   // null


// JSON array
String jsonStr = '[' +
  '{"Name":"Acme Corp","Industry":"Technology","AnnualRevenue":5000000},' +
  '{"Name":"Globex Inc","Industry":"Manufacturing","AnnualRevenue":12000000},' +
  '{"Name":"Initech","Industry":"Finance","AnnualRevenue":3500000}' +
']';

// deserialize to List<Account>
List<Account> accounts = (List<Account>) JSON.deserialize(jsonStr, List<Account>.class);
System.debug(accounts.size());            // 3
System.debug(accounts[0].Name);          // Acme Corp
System.debug(accounts[1].Industry);      // Manufacturing
System.debug(accounts[2].AnnualRevenue); // 3500000

// Iterate and insert
List<Account> toInsert = new List<Account>();
for (Account a : accounts) {
    a.OwnerId = UserInfo.getUserId();
    toInsert.add(a);
}
insert toInsert;


// deserializeUntyped — dynamic/unknown shape
String jsonStr = '{' +
  '"Name":"Acme Corp",' +
  '"AnnualRevenue":5000000,' +
  '"Active":true,' +
  '"Tags":["CRM","ERP","Cloud"]' +
'}';

Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(jsonStr);
System.debug(result.get('Name'));           // Acme Corp (String)
System.debug(result.get('AnnualRevenue'));  // 5000000   (Integer)
System.debug(result.get('Active'));         // true      (Boolean)

// Reading a nested array
List<Object> tags = (List<Object>) result.get('Tags');
for (Object tag : tags) {
    System.debug((String) tag);  // CRM, ERP, Cloud
}

// Map<String, String> — flat string payloads
String flat = '{"Name":"Acme","Industry":"Tech","Phone":"415-555-0100"}';
Map<String, String> fields = (Map<String, String>) JSON.deserialize(flat, Map<String, String>.class);
System.debug(fields.get('Name'));  // Acme
System.debug(fields.keySet());     // {Name, Industry, Phone}