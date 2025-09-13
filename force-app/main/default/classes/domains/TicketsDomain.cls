public with sharing class TicketsDomain extends fflib_SObjectDomain {
    
    public TicketsDomain(List<Ticket__c> records) {
        super(records);
    }
    
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new TicketsDomain(sObjectList);
        }
    }

    public override void onAfterInsert() {
        processNewTicketBookings();
        updateFlightAvailableTicketCounts();
    }
    
    public override void onAfterUpdate(Map<Id, SObject> existingRecords) {
        processTicketBookingChanges((Map<Id, Ticket__c>) existingRecords);
        updateFlightAvailableTicketCountsAfterUpdate((Map<Id, Ticket__c>) existingRecords);
    }
    
    public override void onAfterDelete() {
        updateFlightAvailableTicketCountsForDeleted();
    }
    
    public override void onBeforeUpdate(Map<Id, SObject> existingRecords) {
        validateTicketBookings((Map<Id, Ticket__c>) existingRecords);
    }

    private void processNewTicketBookings() {
        List<Ticket__c> newlyBookedTickets = new List<Ticket__c>();
        
        for (Ticket__c ticket : getTickets()) {
            if (ticket.Contact__c != null) {
                newlyBookedTickets.add(ticket);
            }
        }
        
        if (!newlyBookedTickets.isEmpty()) {
            ApiCalloutServiceImpl apiService = new ApiCalloutServiceImpl();
            apiService.notifyTicketBookingsAsync(newlyBookedTickets);
        }
    }

    private void processTicketBookingChanges(Map<Id, Ticket__c> oldTicketsMap) {
        List<Ticket__c> newlyBookedTickets = new List<Ticket__c>();
        
        for (Ticket__c ticket : getTickets()) {
            Ticket__c oldTicket = oldTicketsMap.get(ticket.Id);
            
            if (ticket.Contact__c != null && oldTicket.Contact__c == null) {
                newlyBookedTickets.add(ticket);
            }
        }
        
        if (!newlyBookedTickets.isEmpty()) {
            ApiCalloutServiceImpl apiService = new ApiCalloutServiceImpl();
            apiService.notifyTicketBookingsAsync(newlyBookedTickets);
        }
    }
    
    private void validateTicketBookings(Map<Id, Ticket__c> oldTicketsMap) {
        for (Ticket__c ticket : getTickets()) {
            Ticket__c oldTicket = oldTicketsMap.get(ticket.Id);
            
            if (ticket.Contact__c != null && oldTicket.Contact__c != null) {
                if (ticket.Flight__c != oldTicket.Flight__c) {
                    ticket.Flight__c.addError(Label.Ticket_Cannot_Change_Flight_When_Booked);
                }
            }
            
            if (ticket.Contact__c != null && oldTicket.Contact__c != null) {
                if (ticket.Contact__c != oldTicket.Contact__c) {
                    ticket.Contact__c.addError(Label.Ticket_Already_Booked_For_Another_Contact);
                }
            }
        }
    }
    
    private void updateFlightAvailableTicketCounts() {
        Set<Id> flightIds = new Set<Id>();
        
        for (Ticket__c ticket : getTickets()) {
            if (ticket.Flight__c != null) {
                flightIds.add(ticket.Flight__c);
            }
        }
        
        if (!flightIds.isEmpty()) {
            FlightsDomain.updateAvailableTicketCounts(flightIds);
        }
    }
    
    private void updateFlightAvailableTicketCountsAfterUpdate(Map<Id, Ticket__c> oldTicketsMap) {
        Set<Id> flightIds = new Set<Id>();
        
        for (Ticket__c ticket : getTickets()) {
            Ticket__c oldTicket = oldTicketsMap.get(ticket.Id);
            
            if (ticket.Flight__c != null) {
                flightIds.add(ticket.Flight__c);
            }
            
            if (oldTicket.Flight__c != null && oldTicket.Flight__c != ticket.Flight__c) {
                flightIds.add(oldTicket.Flight__c);
            }
        }
        
        if (!flightIds.isEmpty()) {
            FlightsDomain.updateAvailableTicketCounts(flightIds);
        }
    }
    
    private void updateFlightAvailableTicketCountsForDeleted() {
        Set<Id> flightIds = new Set<Id>();
        
        for (Ticket__c ticket : getTickets()) {
            if (ticket.Flight__c != null) {
                flightIds.add(ticket.Flight__c);
            }
        }
        
        if (!flightIds.isEmpty()) {
            FlightsDomain.updateAvailableTicketCounts(flightIds);
        }
    }
    
    private List<Ticket__c> getTickets() {
        return (List<Ticket__c>) Records;
    }
}