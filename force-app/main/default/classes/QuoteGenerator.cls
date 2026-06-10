public without sharing class QuoteGenerator {

    public static void generateQuote(List<Opportunity> closedWonOpportunities) {
        List<Quote> quotesToInsert = new List<Quote>();
        List<OpportunityLineItem> opportunityLineItems = new List<OpportunityLineItem>();
        List<QuoteLineItem> quoteLineItemsToInsert = new List<QuoteLineItem>();
        Set<Id> opportunityIds = new Set<Id>();

        for (Opportunity opp : closedWonOpportunities) {
            quotesToInsert.add(new Quote(
                Name = 'Quote for ' + opp.Name,
                OpportunityId = opp.Id,
                Pricebook2Id = opp.Pricebook2Id
            ));
            opportunityIds.add(opp.Id);
        }

        // Insert quotes in user mode
        insert as user quotesToInsert;

        // Retrieve inserted quotes as a map with OpportunityId as key
        Map<Id, Quote> opportunityToQuoteMap = new Map<Id, Quote>();
        for (Quote q : quotesToInsert) {
            opportunityToQuoteMap.put(q.OpportunityId, q);
        }

        // Retrieve Opportunity Line Items for the given Opportunities in user mode
        opportunityLineItems = [SELECT Id, OpportunityId, PricebookEntryId, Quantity, UnitPrice, Description
                                FROM OpportunityLineItem
                                WHERE OpportunityId IN :opportunityIds
                                WITH USER_MODE];

        // Create Quote Line Items
        for (OpportunityLineItem oli : opportunityLineItems) {
            QuoteLineItem qli = new QuoteLineItem(
                QuoteId = opportunityToQuoteMap.get(oli.OpportunityId).Id,
                PricebookEntryId = oli.PricebookEntryId,
                Quantity = oli.Quantity,
                UnitPrice = oli.UnitPrice,
                Description = oli.Description
            );
            quoteLineItemsToInsert.add(qli);
        }

        // Insert Quote Line Items in user mode
        if (!quoteLineItemsToInsert.isEmpty()) {
            insert as user quoteLineItemsToInsert;
        }

        // Set the primary quote on the Opportunity
        List<Opportunity> opportunitiesToUpdate = new List<Opportunity>();
        for (Quote q : quotesToInsert) {
            opportunitiesToUpdate.add(new Opportunity(
                Id = q.OpportunityId,
                Quote__c = q.Id
            ));
        }

        // Update Opportunities in user mode
        if (!opportunitiesToUpdate.isEmpty()) {
            update as user opportunitiesToUpdate;
        }
    }
}
