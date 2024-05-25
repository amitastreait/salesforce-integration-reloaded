/**
 * @description       : 
 * @author            : Amit Singh - PantherSchools
 * @group             : 
 * @last modified on  : 05-25-2024
 * @last modified by  : Amit Singh - PantherSchools
**/
public class GenerateOpportunities {
    // GenerateOpportunities.createOpportunities(120);
    public static void createOpportunities(Integer numberOfOpportunities) {
        List<Opportunity> opportunitiesToCreate = new List<Opportunity>();
        String[] names = new String[]{'Acme Corp', 'Global Industries', 'Tech Solutions', 'Innovative Systems', 'Dynamic Enterprises', 'Peak Performance', 'Superior Services', 'Bright Future', 'NextGen Technologies', 'Prime Ventures'};
        String description = 'This is a sample opportunity description.';
        Decimal[] amounts = new Decimal[]{5000, 10000, 15000, 20000, 25000, 30000, 35000, 40000, 45000, 50000};
        Date closeDate = Date.today().addMonths(1);

        for (Integer i = 0; i < numberOfOpportunities; i++) {
            String name = names[Math.mod(Math.abs(Crypto.getRandomInteger()), names.size())] + ' - ' + (i + 1);
            Decimal amount = amounts[Math.mod(Math.abs(Crypto.getRandomInteger()), amounts.size())];
            String orderNumber = generateRandomNumber(8);
            String trackingNumber = generateRandomNumber(12);

            Opportunity opportunity = new Opportunity(
                Name = name,
                CloseDate = closeDate,
                StageName = 'Prospecting',
                Description = description,
                Amount = amount,
                Type = 'New Customer',
                LeadSource = 'Web',
                OrderNumber__c = orderNumber,
                TrackingNumber__c = trackingNumber
            );
            opportunitiesToCreate.add(opportunity);
        }

        if (!opportunitiesToCreate.isEmpty()) {
            insert opportunitiesToCreate;
            System.debug('Successfully created ' + numberOfOpportunities + ' opportunities.');
        }
    }

    private static String generateRandomNumber(Integer length) {
        String number_x = '';
        for (Integer i = 0; i < length; i++) {
            number_x += String.valueOf(Math.mod(Math.abs(Crypto.getRandomInteger()), 10));
        }
        return number_x;
    }
}