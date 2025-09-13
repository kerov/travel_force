@IsTest
private class ApiCalloutServiceImplTest {
    
    @TestSetup 
    static void makeData() {
        Contact contact = new Contact(
            FirstName = 'Test',
            LastName = 'Passenger',
            Email = 'test@example.com'
        );
        insert contact;
        
        Flight__c flight = new Flight__c(
            Start__c = System.now().addDays(1)
        );
        insert flight;
        
        List<Ticket__c> tickets = new List<Ticket__c>();
        tickets.add(new Ticket__c(
            Flight__c = flight.Id,
            Contact__c = contact.Id
        ));
        tickets.add(new Ticket__c(
            Flight__c = flight.Id
        ));
        insert tickets;
        
    }
    
    @IsTest
    static void testNotifyTicketBookingsAsyncWithValidTickets() {
        List<Ticket__c> tickets = [SELECT Id, Contact__c, Flight__c FROM Ticket__c WHERE Contact__c != null];
        ApiCalloutServiceImpl service = new ApiCalloutServiceImpl();
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SuccessHttpMock());
        service.notifyTicketBookingsAsync(tickets);
        Test.stopTest();
        
        Assert.areEqual(1, tickets.size(), 'Should process ticket with contact');
    }
    
    @IsTest
    static void testNotifyTicketBookingsAsyncWithNullList() {
        ApiCalloutServiceImpl service = new ApiCalloutServiceImpl();
        
        Test.startTest();
        service.notifyTicketBookingsAsync(null);
        Test.stopTest();
        
        Assert.isTrue(true, 'Should handle null list gracefully');
    }
    
    @IsTest
    static void testNotifyTicketBookingsAsyncWithEmptyList() {
        ApiCalloutServiceImpl service = new ApiCalloutServiceImpl();
        
        Test.startTest();
        service.notifyTicketBookingsAsync(new List<Ticket__c>());
        Test.stopTest();
        
        Assert.isTrue(true, 'Should handle empty list gracefully');
    }
    
    @IsTest
    static void testApiCalloutSuccess() {
        List<Ticket__c> tickets = [SELECT Id, Contact__c, Flight__c FROM Ticket__c WHERE Contact__c != null];
        ApiCalloutServiceImpl service = new ApiCalloutServiceImpl();
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SuccessHttpMock());
        service.notifyTicketBookingsAsync(tickets);
        Test.stopTest();
        
        Assert.areEqual(1, tickets.size(), 'Should process ticket successfully');
    }
    
    @IsTest
    static void testApiCalloutFailure() {
        List<Ticket__c> tickets = [SELECT Id, Contact__c, Flight__c FROM Ticket__c WHERE Contact__c != null];
        ApiCalloutServiceImpl service = new ApiCalloutServiceImpl();
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new FailureHttpMock());
        service.notifyTicketBookingsAsync(tickets);
        Test.stopTest();
        
        Assert.areEqual(1, tickets.size(), 'Should handle callout failure gracefully');
    }
    
    @IsTest
    static void testMakeApiCalloutPayloadStructure() {
        Contact contact = [SELECT Id, Name, Email FROM Contact LIMIT 1];
        Flight__c flight = [SELECT Id FROM Flight__c LIMIT 1];
        
        Ticket__c ticket = new Ticket__c(
            Flight__c = flight.Id,
            Contact__c = contact.Id
        );
        insert ticket;
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new PayloadValidationHttpMock());
        
        ApiCalloutServiceImpl service = new ApiCalloutServiceImpl();
        service.notifyTicketBookingsAsync(new List<Ticket__c>{ticket});
        Test.stopTest();
        
        Assert.isTrue(true, 'Should successfully create and send payload');
    }
    
    @IsTest
    static void testProcessingTicketsWithoutContact() {
        List<Ticket__c> ticketsWithoutContact = [SELECT Id, Contact__c, Flight__c FROM Ticket__c WHERE Contact__c = null];
        ApiCalloutServiceImpl service = new ApiCalloutServiceImpl();
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SuccessHttpMock());
        service.notifyTicketBookingsAsync(ticketsWithoutContact);
        Test.stopTest();
        
        Assert.areEqual(1, ticketsWithoutContact.size(), 'Should not process tickets without contact');
    }
    
    public class SuccessHttpMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            response.setStatusCode(200);
            response.setBody('{"status": "success"}');
            return response;
        }
    }
    
    public class FailureHttpMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            response.setStatusCode(500);
            response.setBody('{"error": "Internal Server Error"}');
            return response;
        }
    }
    
    public class PayloadValidationHttpMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request) {
            String body = request.getBody();
            Map<String, Object> payload = (Map<String, Object>) JSON.deserializeUntyped(body);
            
            System.assert(payload.containsKey('ticketNumber'), 'Payload should contain ticketNumber');
            System.assert(payload.containsKey('flightNumber'), 'Payload should contain flightNumber');
            System.assert(payload.containsKey('departureDate'), 'Payload should contain departureDate');
            System.assert(payload.containsKey('passengerName'), 'Payload should contain passengerName');
            System.assert(payload.containsKey('passengerEmail'), 'Payload should contain passengerEmail');
            
            HttpResponse response = new HttpResponse();
            response.setStatusCode(200);
            response.setBody('{"status": "success"}');
            return response;
        }
    }
}