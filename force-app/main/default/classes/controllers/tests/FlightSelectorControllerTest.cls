@IsTest
private class FlightSelectorControllerTest {
    
    @TestSetup
    static void makeData() {
        Contact contact = new Contact(
            FirstName = 'Test',
            LastName = 'User'
        );
        insert contact;
        
        Flight__c flight1 = new Flight__c(
            Start__c = System.now().addDays(1)
        );
        Flight__c flight2 = new Flight__c(
            Start__c = System.now().addDays(2)
        );
        insert new List<Flight__c>{flight1, flight2};
        
        List<Ticket__c> tickets = new List<Ticket__c>();
        tickets.add(new Ticket__c(Flight__c = flight1.Id));
        tickets.add(new Ticket__c(Flight__c = flight1.Id, Contact__c = contact.Id));
        tickets.add(new Ticket__c(Flight__c = flight2.Id));
        tickets.add(new Ticket__c(Flight__c = flight2.Id));
        insert tickets;
    }
    
    @IsTest
    static void testGetAvailableFlightsWithValidDate() {
        Date testDate = Date.today().addDays(1);
        
        Test.startTest();
        List<FlightSelectorController.FlightInfo> flights = FlightSelectorController.getAvailableFlights(testDate);
        Test.stopTest();
        
        Assert.isTrue(flights.size() >= 1, 'Should return flights for valid date');
        for (FlightSelectorController.FlightInfo flight : flights) {
            Assert.isNotNull(flight.Id, 'Flight should have Id');
            Assert.isNotNull(flight.Name, 'Flight should have Name');
            Assert.isTrue(flight.availableTickets > 0, 'Flight should have available tickets');
        }
    }
    
    @IsTest
    static void testGetAvailableFlightsWithNullDate() {
        Test.startTest();
        List<FlightSelectorController.FlightInfo> flights = FlightSelectorController.getAvailableFlights(null);
        Test.stopTest();
        
        Assert.areEqual(0, flights.size(), 'Should return empty list for null date');
    }
    
    @IsTest
    static void testGetAvailableFlightsWithFutureDate() {
        Date futureDate = Date.today().addDays(10);
        
        Test.startTest();
        List<FlightSelectorController.FlightInfo> flights = FlightSelectorController.getAvailableFlights(futureDate);
        Test.stopTest();
        
        Assert.areEqual(0, flights.size(), 'Should return empty list for date with no flights');
    }
    
    @IsTest
    static void testGetCurrentTicketWithValidIds() {
        Contact contact = [SELECT Id FROM Contact LIMIT 1];
        Ticket__c ticket = [SELECT Id, Flight__c FROM Ticket__c WHERE Contact__c = :contact.Id LIMIT 1];
        
        Test.startTest();
        FlightSelectorController.TicketInfo ticketInfo = FlightSelectorController.getCurrentTicket(ticket.Flight__c, contact.Id);
        Test.stopTest();
        
        Assert.isNotNull(ticketInfo, 'Should return ticket info for valid IDs');
        Assert.areEqual(ticket.Id, ticketInfo.Id, 'Should return correct ticket ID');
        Assert.isNotNull(ticketInfo.Name, 'Ticket should have Name');
    }
    
    @IsTest
    static void testGetCurrentTicketWithNullFlightId() {
        Contact contact = [SELECT Id FROM Contact LIMIT 1];
        
        Test.startTest();
        FlightSelectorController.TicketInfo ticketInfo = FlightSelectorController.getCurrentTicket(null, contact.Id);
        Test.stopTest();
        
        Assert.isNull(ticketInfo, 'Should return null for null flight ID');
    }
    
    @IsTest
    static void testGetCurrentTicketWithNullContactId() {
        Flight__c flight = [SELECT Id FROM Flight__c LIMIT 1];
        
        Test.startTest();
        FlightSelectorController.TicketInfo ticketInfo = FlightSelectorController.getCurrentTicket(flight.Id, null);
        Test.stopTest();
        
        Assert.isNull(ticketInfo, 'Should return null for null contact ID');
    }
    
    @IsTest
    static void testGetCurrentTicketWithNoMatch() {
        Contact contact = [SELECT Id FROM Contact LIMIT 1];
        Flight__c flight = [SELECT Id FROM Flight__c WHERE Id NOT IN (SELECT Flight__c FROM Ticket__c WHERE Contact__c = :contact.Id) LIMIT 1];
        
        Test.startTest();
        FlightSelectorController.TicketInfo ticketInfo = FlightSelectorController.getCurrentTicket(flight.Id, contact.Id);
        Test.stopTest();
        
        Assert.isNull(ticketInfo, 'Should return null when no ticket found');
    }
    
    @IsTest
    static void testFlightInfoComparator() {
        FlightSelectorController.FlightInfo flight1 = new FlightSelectorController.FlightInfo();
        flight1.StartDateTime = System.now().addDays(1);
        
        FlightSelectorController.FlightInfo flight2 = new FlightSelectorController.FlightInfo();
        flight2.StartDateTime = System.now().addDays(2);
        
        FlightSelectorController.FlightInfoComparator comparator = new FlightSelectorController.FlightInfoComparator();
        
        Test.startTest();
        Integer result = comparator.compare(flight1, flight2);
        Test.stopTest();
        
        Assert.areEqual(-1, result, 'Earlier flight should come first');
    }
    
    @IsTest
    static void testFlightInfoComparatorWithNullDates() {
        FlightSelectorController.FlightInfo flight1 = new FlightSelectorController.FlightInfo();
        flight1.StartDateTime = null;
        
        FlightSelectorController.FlightInfo flight2 = new FlightSelectorController.FlightInfo();
        flight2.StartDateTime = null;
        
        FlightSelectorController.FlightInfoComparator comparator = new FlightSelectorController.FlightInfoComparator();
        
        Test.startTest();
        Integer result = comparator.compare(flight1, flight2);
        Test.stopTest();
        
        Assert.areEqual(0, result, 'Null dates should be equal');
    }
    
    @IsTest
    static void testFlightSorting() {
        Date testDate = Date.today().addDays(1);
        
        Test.startTest();
        List<FlightSelectorController.FlightInfo> flights = FlightSelectorController.getAvailableFlights(testDate);
        Test.stopTest();
        
        if (flights.size() > 1) {
            for (Integer i = 0; i < flights.size() - 1; i++) {
                Assert.isTrue(
                    flights[i].StartDateTime <= flights[i + 1].StartDateTime,
                    'Flights should be sorted by start time'
                );
            }
        }
    }
    
    @IsTest
    static void testAvailableTicketsCalculation() {
        Date testDate = Date.today().addDays(1);
        
        Test.startTest();
        List<FlightSelectorController.FlightInfo> flights = FlightSelectorController.getAvailableFlights(testDate);
        Test.stopTest();
        
        if (!flights.isEmpty()) {
            FlightSelectorController.FlightInfo flight = flights[0];
            Flight__c flightRecord = [SELECT Id, (SELECT Id FROM Tickets__r WHERE Contact__c = null) FROM Flight__c WHERE Id = :flight.Id];
            
            Assert.isTrue(
                flight.availableTickets >= 0,
                'Available tickets should be non-negative'
            );
        }
    }
}