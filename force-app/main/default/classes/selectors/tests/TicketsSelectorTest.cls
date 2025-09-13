@IsTest
private class TicketsSelectorTest {
    
    @TestSetup
    static void makeData() {
        Flight__c flight = new Flight__c(
            Start__c = System.now().addDays(1)
        );
        insert flight;
        
        Contact contact = new Contact(
            FirstName = 'Test',
            LastName = 'Contact'
        );
        insert contact;
        
        List<Ticket__c> tickets = new List<Ticket__c>();
        tickets.add(new Ticket__c(Flight__c = flight.Id));
        tickets.add(new Ticket__c(Flight__c = flight.Id, Contact__c = contact.Id));
        insert tickets;
    }
    
    @IsTest
    static void testSelectAvailable() {
        TicketsSelector selector = new TicketsSelector();
        
        Test.startTest();
        List<Ticket__c> availableTickets = selector.selectAvailable();
        Test.stopTest();
        
        Assert.areEqual(1, availableTickets.size(), 'Should return only available tickets');
        Assert.isNull(availableTickets[0].Contact__c, 'Available ticket should not have contact');
    }
    
    @IsTest
    static void testSelectAvailableByFlightId() {
        Flight__c flight = [SELECT Id FROM Flight__c LIMIT 1];
        TicketsSelector selector = new TicketsSelector();
        
        Test.startTest();
        List<Ticket__c> availableTickets = selector.selectAvailableByFlightId(new Set<Id>{flight.Id});
        Test.stopTest();
        
        Assert.areEqual(1, availableTickets.size(), 'Should return available tickets for flight');
        Assert.isNull(availableTickets[0].Contact__c, 'Available ticket should not have contact');
    }
    
    @IsTest
    static void testSelectByContactId() {
        Contact contact = [SELECT Id FROM Contact LIMIT 1];
        TicketsSelector selector = new TicketsSelector();
        
        Test.startTest();
        List<Ticket__c> bookedTickets = selector.selectByContactId(new Set<Id>{contact.Id});
        Test.stopTest();
        
        Assert.areEqual(1, bookedTickets.size(), 'Should return tickets for contact');
        Assert.areEqual(contact.Id, bookedTickets[0].Contact__c, 'Should return correct contact ticket');
    }
    
    @IsTest
    static void testCountAvailableTicketsByFlight() {
        Flight__c flight = [SELECT Id FROM Flight__c LIMIT 1];
        TicketsSelector selector = new TicketsSelector();
        
        Test.startTest();
        Map<Id, Integer> counts = selector.countAvailableTicketsByFlight(new Set<Id>{flight.Id});
        Test.stopTest();
        
        Assert.areEqual(1, counts.size(), 'Should return count for flight');
        Assert.areEqual(1, counts.get(flight.Id), 'Should count only available tickets');
    }
    
    @IsTest
    static void testSelectByFlightIdWithContact() {
        Flight__c flight = [SELECT Id FROM Flight__c LIMIT 1];
        TicketsSelector selector = new TicketsSelector();
        
        Test.startTest();
        List<Ticket__c> tickets = selector.selectByFlightIdWithContact(new Set<Id>{flight.Id});
        Test.stopTest();
        
        Assert.isTrue(tickets.size() >= 1, 'Should return tickets for flight');
    }
    
    @IsTest
    static void testGetSObjectFieldList() {
        TicketsSelector selector = new TicketsSelector();
        
        Test.startTest();
        List<Schema.SObjectField> fields = selector.getSObjectFieldList();
        Test.stopTest();
        
        Assert.isTrue(fields.size() > 0, 'Should return field list');
        Assert.isTrue(fields.contains(Ticket__c.Id), 'Should include Id field');
        Assert.isTrue(fields.contains(Ticket__c.Flight__c), 'Should include Flight__c field');
        Assert.isTrue(fields.contains(Ticket__c.Contact__c), 'Should include Contact__c field');
    }
    
    @IsTest
    static void testGetSObjectType() {
        TicketsSelector selector = new TicketsSelector();
        
        Test.startTest();
        Schema.SObjectType sObjectType = selector.getSObjectType();
        Test.stopTest();
        
        Assert.areEqual(Ticket__c.SObjectType, sObjectType, 'Should return Ticket__c SObjectType');
    }
}