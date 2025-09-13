public with sharing class TicketServiceImpl {

    public void bookTicketsForTrips(List<Trip__c> trips) {
        if (trips == null || trips.isEmpty()) {
            return;
        }
        
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        
        try {
            for (Trip__c trip : trips) {
                if (trip.Flight__c != null && trip.Contact__c != null) {
                    bookTicketForTrip(trip, uow);
                }
            }
            
            uow.commitWork();
            
        } catch (Exception e) {
            throw new TravelForceExceptions.ServiceException(TravelForceConstants.ERROR_FAILED_BOOK_TICKETS + e.getMessage(), e);
        }
    }

    public void releaseTicketsForTrips(List<Trip__c> trips) {
        if (trips == null || trips.isEmpty()) {
            return;
        }
        
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        
        try {
            Set<Id> flightIds = new Set<Id>();
            Set<Id> contactIds = new Set<Id>();
            
            for (Trip__c trip : trips) {
                if (trip.Flight__c != null && trip.Contact__c != null) {
                    flightIds.add(trip.Flight__c);
                    contactIds.add(trip.Contact__c);
                }
            }
            
            TicketsSelector ticketsSelector = (TicketsSelector) Application.Selector.newInstance(Ticket__c.SObjectType);
            List<Ticket__c> bookedTickets = ticketsSelector.selectByFlightIdWithContact(flightIds);
            
            for (Ticket__c ticket : bookedTickets) {
                if (ticket.Contact__c != null && contactIds.contains(ticket.Contact__c)) {
                    for (Trip__c trip : trips) {
                        if (trip.Flight__c == ticket.Flight__c && trip.Contact__c == ticket.Contact__c) {
                            releaseTicketInternal(ticket, uow);
                            break;
                        }
                    }
                }
            }
            
            uow.commitWork();
            
        } catch (Exception e) {
            throw new TravelForceExceptions.ServiceException(TravelForceConstants.ERROR_FAILED_RELEASE_TICKETS + e.getMessage(), e);
        }
    }

    public List<Ticket__c> getAvailableTicketsByFlight(Id flightId) {
        if (flightId == null) {
            return new List<Ticket__c>();
        }
        
        TicketsSelector ticketsSelector = (TicketsSelector) Application.Selector.newInstance(Ticket__c.SObjectType);
        return ticketsSelector.selectAvailableByFlightId(new Set<Id>{flightId});
    }

    private void bookTicketForTrip(Trip__c trip, fflib_ISObjectUnitOfWork uow) {
        List<Ticket__c> availableTickets = getAvailableTicketsByFlight(trip.Flight__c);
        
        if (availableTickets.isEmpty()) {
            throw new TravelForceExceptions.BusinessException(TravelForceConstants.ERROR_NO_AVAILABLE_TICKETS_FLIGHT + trip.Flight__c);
        }
        
        Ticket__c ticketToBook = availableTickets[0];
        ticketToBook.Contact__c = trip.Contact__c;
        
        uow.registerDirty(ticketToBook);
    }

    private void releaseTicketInternal(Ticket__c ticket, fflib_ISObjectUnitOfWork uow) {
        ticket.Contact__c = null;
        uow.registerDirty(ticket);
    }
    
}