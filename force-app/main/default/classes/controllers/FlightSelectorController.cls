public with sharing class FlightSelectorController {
    
    @AuraEnabled(cacheable=true)
    public static List<FlightInfo> getAvailableFlights(Date preferredDate) {
        if (preferredDate == null) {
            return new List<FlightInfo>();
        }
        
        try {
            FlightsSelector flightsSelector = (FlightsSelector) Application.Selector.newInstance(Flight__c.SObjectType);
            List<Flight__c> flights = flightsSelector.selectByDateWithTicketCounts(preferredDate);
            
            List<FlightInfo> result = new List<FlightInfo>();
            
            for (Flight__c flight : flights) {
                Integer availableTickets = 0;
                if (flight.Tickets__r != null) {
                    for (Ticket__c ticket : flight.Tickets__r) {
                        if (ticket.Contact__c == null) {
                            availableTickets++;
                        }
                    }
                }
                
                if (availableTickets > 0) {
                    FlightInfo flightInfo = new FlightInfo();
                    flightInfo.Id = flight.Id;
                    flightInfo.Name = flight.Name;
                    flightInfo.StartDateTime = flight.Start__c;
                    flightInfo.availableTickets = availableTickets;
                    
                    result.add(flightInfo);
                }
            }
            
            result.sort(new FlightInfoComparator());
            
            return result;
            
        } catch (Exception e) {
            throw new AuraHandledException(TravelForceConstants.ERROR_RETRIEVING_FLIGHTS + e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static TicketInfo getCurrentTicket(Id flightId, Id contactId) {
        if (flightId == null || contactId == null) {
            return null;
        }
        
        try {
            TicketsSelector ticketsSelector = (TicketsSelector) Application.Selector.newInstance(Ticket__c.SObjectType);
            List<Ticket__c> tickets = [
                SELECT Id, Name, Flight__c, Contact__c 
                FROM Ticket__c 
                WHERE Flight__c = :flightId AND Contact__c = :contactId 
                LIMIT 1
            ];
            
            if (!tickets.isEmpty()) {
                Ticket__c ticket = tickets[0];
                TicketInfo ticketInfo = new TicketInfo();
                ticketInfo.Id = ticket.Id;
                ticketInfo.Name = ticket.Name;
                
                return ticketInfo;
            }
            
            return null;
            
        } catch (Exception e) {
            throw new AuraHandledException(TravelForceConstants.ERROR_RETRIEVING_CURRENT_TICKET + e.getMessage());
        }
    }
    
    public class FlightInfo {
        @AuraEnabled public Id Id { get; set; }
        @AuraEnabled public String Name { get; set; }
        @AuraEnabled public DateTime StartDateTime { get; set; }
        @AuraEnabled public Integer availableTickets { get; set; }
    }
    
    public class TicketInfo {
        @AuraEnabled public Id Id { get; set; }
        @AuraEnabled public String Name { get; set; }
    }
    
    public class FlightInfoComparator implements Comparator<FlightInfo> {
        public Integer compare(FlightInfo flight1, FlightInfo flight2) {
            if (flight1.StartDateTime == null && flight2.StartDateTime == null) return 0;
            if (flight1.StartDateTime == null) return 1;
            if (flight2.StartDateTime == null) return -1;
            
            return flight1.StartDateTime < flight2.StartDateTime ? -1 : 
                   flight1.StartDateTime > flight2.StartDateTime ? 1 : 0;
        }
    }
}