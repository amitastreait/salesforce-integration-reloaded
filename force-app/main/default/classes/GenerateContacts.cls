/**
 * @description       : 
 * @author            : Amit Singh - PantherSchools
 * @group             : 
 * @last modified on  : 05-18-2024
 * @last modified by  : Amit Singh - PantherSchools
**/
public class GenerateContacts {

    public static void createContacts(Integer numberOfContacts) {
        List<Contact> contactsToCreate = new List<Contact>();
        String[] firstNames = new String[]{'John', 'Jane', 'Michael', 'Sarah', 'David', 'Laura', 'Robert', 'Emily', 'James', 'Emma'};
        String[] lastNames = new String[]{'Smith', 'Johnson', 'Williams', 'Jones', 'Brown', 'Davis', 'Miller', 'Wilson', 'Moore', 'Taylor'};
        String[] titles = new String[]{'Sales Manager', 'Marketing Director', 'Software Engineer', 'Project Manager', 'Consultant', 'Product Manager', 'Business Analyst', 'HR Manager', 'Accountant', 'Support Specialist'};
        String[] departments = new String[]{'Sales', 'Marketing', 'Engineering', 'HR', 'Finance', 'Customer Support', 'IT', 'Operations', 'Legal', 'Administration'};

        for (Integer i = 0; i < numberOfContacts; i++) {
            String firstName = firstNames[Math.mod(Math.abs(Crypto.getRandomInteger()), firstNames.size())];
            String lastName = lastNames[Math.mod(Math.abs(Crypto.getRandomInteger()), lastNames.size())];
            String title = titles[Math.mod(Math.abs(Crypto.getRandomInteger()), titles.size())];
            String department = departments[Math.mod(Math.abs(Crypto.getRandomInteger()), departments.size())];
            String email = firstName.toLowerCase() + '.' + lastName.toLowerCase() + '@example.com';
            String phone = generatePhoneNumber();
            String fax = generatePhoneNumber();

            Contact contact = new Contact(
                FirstName = firstName,
                LastName = lastName,
                Email = email,
                Phone = phone,
                Title = title,
                Department = department,
                Fax = fax
            );
            contactsToCreate.add(contact);
        }

        if (!contactsToCreate.isEmpty()) {
            insert contactsToCreate;
            System.debug('Successfully created ' + numberOfContacts + ' contacts.');
        }
    }

    private static String generatePhoneNumber() {
        String phoneNumber = '(';
        phoneNumber += String.valueOf(Math.mod(Math.abs(Crypto.getRandomInteger()), 900) + 100) + ') ';
        phoneNumber += String.valueOf(Math.mod(Math.abs(Crypto.getRandomInteger()), 900) + 100) + '-';
        phoneNumber += String.valueOf(Math.mod(Math.abs(Crypto.getRandomInteger()), 10000) + 1000);
        return phoneNumber;
    }
}