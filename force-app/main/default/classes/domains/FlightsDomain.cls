public with sharing class FlightsDomain extends fflib_SObjectDomain {
    
    public FlightsDomain(List<Flight__c> records) {
        super(records);
    }
    
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new FlightsDomain(sObjectList);
        }
    }

    public override void onBeforeUpdate(Map<Id, SObject> existingRecords) {
        validateFlightModifications((Map<Id, Flight__c>) existingRecords);
    }
    
    public override void onBeforeDelete() {
        preventDeletionWithBookedTickets();
    }

    private void validateFlightModifications(Map<Id, Flight__c> oldFlightsMap) {
        Set<Id> flightIds = new Set<Id>(oldFlightsMap.keySet());
        
        TicketsSelector ticketsSelector = (TicketsSelector) Application.Selector.newInstance(Ticket__c.SObjectType);
        List<Ticket__c> bookedTickets = ticketsSelector.selectByFlightIdWithContact(flightIds);
        
        Set<Id> flightsWithBookedTickets = new Set<Id>();
        for (Ticket__c ticket : bookedTickets) {
            if (ticket.Contact__c != null) {
                flightsWithBookedTickets.add(ticket.Flight__c);
            }
        }
        
        for (Flight__c flight : getFlights()) {
            Flight__c oldFlight = oldFlightsMap.get(flight.Id);
            
            if (flightsWithBookedTickets.contains(flight.Id)) {
                if (flight.Start__c != oldFlight.Start__c) {
                    flight.Start__c.addError(Label.Flight_Cannot_Modify_Start_Time);
                }
            }
        }
    }

    private void preventDeletionWithBookedTickets() {
        Set<Id> flightIds = new Set<Id>();
        for (Flight__c flight : getFlights()) {
            flightIds.add(flight.Id);
        }
        
        TicketsSelector ticketsSelector = (TicketsSelector) Application.Selector.newInstance(Ticket__c.SObjectType);
        List<Ticket__c> bookedTickets = ticketsSelector.selectByFlightIdWithContact(flightIds);
        
        Set<Id> flightsWithBookedTickets = new Set<Id>();
        for (Ticket__c ticket : bookedTickets) {
            if (ticket.Contact__c != null) {
                flightsWithBookedTickets.add(ticket.Flight__c);
            }
        }
        
        for (Flight__c flight : getFlights()) {
            if (flightsWithBookedTickets.contains(flight.Id)) {
                flight.addError(Label.Flight_Cannot_Delete_With_Booked_Tickets);
            }
        }
    }

    public static void updateAvailableTicketCounts(Set<Id> flightIds) {
        if (flightIds == null || flightIds.isEmpty()) {
            return;
        }
        
        List<Flight__c> flights = [
            SELECT Id, Available_Tickets__c, (SELECT Id, Contact__c FROM Tickets__r)
            FROM Flight__c 
            WHERE Id IN :flightIds
        ];
        
        List<Flight__c> flightsToUpdate = new List<Flight__c>();
        
        for (Flight__c flight : flights) {
            Integer availableTickets = 0;
            
            if (flight.Tickets__r != null) {
                for (Ticket__c ticket : flight.Tickets__r) {
                    if (ticket.Contact__c == null) {
                        availableTickets++;
                    }
                }
            }
            
            if (flight.Available_Tickets__c != availableTickets) {
                Flight__c flightToUpdate = new Flight__c(
                    Id = flight.Id,
                    Available_Tickets__c = availableTickets
                );
                flightsToUpdate.add(flightToUpdate);
            }
        }
        
        if (!flightsToUpdate.isEmpty()) {
            update flightsToUpdate;
        }
    }

    private List<Flight__c> getFlights() {
        return (List<Flight__c>) Records;
    }
}