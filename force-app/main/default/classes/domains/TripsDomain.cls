public with sharing class TripsDomain extends fflib_SObjectDomain {
    
    public TripsDomain(List<Trip__c> records) {
        super(records);
    }
    
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new TripsDomain(sObjectList);
        }
    }
 
    public override void onBeforeInsert() {
        generateTripNames();
        updateStatusesBasedOnFlight();
    }
    
    public override void onBeforeUpdate(Map<Id, SObject> existingRecords) {
        generateTripNames();
        updateStatusesBasedOnFlight();
    }
    
    public override void onAfterInsert() {
        processFlightChanges(null);
    }
    
    public override void onAfterUpdate(Map<Id, SObject> existingRecords) {
        processFlightChanges((Map<Id, Trip__c>) existingRecords);
    }
    
    private void generateTripNames() {
        Set<Id> contactIds = new Set<Id>();
        for (Trip__c trip : getTrips()) {
            if (trip.Contact__c != null) {
                contactIds.add(trip.Contact__c);
            }
        }
        
        if (contactIds.isEmpty()) {
            return;
        }
        
        ContactsSelector contactsSelector = (ContactsSelector) Application.Selector.newInstance(Contact.SObjectType);
        List<Contact> contacts = (List<Contact>) Database.query(contactsSelector.newQueryFactory().setCondition('Id IN :contactIds').toSOQL());
        Map<Id, Contact> contactMap = new Map<Id, Contact>(contacts);
        
        for (Trip__c trip : getTrips()) {
            if (trip.Contact__c != null && contactMap.containsKey(trip.Contact__c)) {
                Contact contact = contactMap.get(trip.Contact__c);
                String tripName = generateTripName(contact.Name, trip.Preferred_Trip_Start__c);
                trip.Trip_Display_Name__c = tripName;
            }
        }
    }

    private void updateStatusesBasedOnFlight() {
        Map<Id, Trip__c> oldTripsMap = (Map<Id, Trip__c>) Trigger.oldMap;
        
        for (Trip__c trip : getTrips()) {
            Trip__c oldTrip = oldTripsMap?.get(trip.Id);
            
            if (oldTrip == null || oldTrip.Flight__c != trip.Flight__c) {
                trip.Status__c = trip.Flight__c != null ? TravelForceConstants.TRIP_STATUS_FLIGHT_BOOKED : TravelForceConstants.TRIP_STATUS_FLIGHT_SEARCH;
            }
        }
    }
    
    private void processFlightChanges(Map<Id, Trip__c> oldTripsMap) {
        List<Trip__c> tripsWithNewFlights = new List<Trip__c>();
        List<Trip__c> tripsWithClearedFlights = new List<Trip__c>();
        
        for (Trip__c trip : getTrips()) {
            Trip__c oldTrip = oldTripsMap?.get(trip.Id);
            
            if (trip.Flight__c != null && (oldTrip == null || oldTrip.Flight__c != trip.Flight__c)) {
                tripsWithNewFlights.add(trip);
            }
            
            if (trip.Flight__c == null && oldTrip?.Flight__c != null) {
                Trip__c tripForRelease = trip.clone(true);
                tripForRelease.Flight__c = oldTrip.Flight__c;
                tripsWithClearedFlights.add(tripForRelease);
            }
        }
        
        if (!tripsWithNewFlights.isEmpty()) {
            TicketServiceImpl ticketService = new TicketServiceImpl();
            ticketService.bookTicketsForTrips(tripsWithNewFlights);
        }
        
        if (!tripsWithClearedFlights.isEmpty()) {
            TicketServiceImpl ticketService = new TicketServiceImpl();
            ticketService.releaseTicketsForTrips(tripsWithClearedFlights);
        }
    }

    private String generateTripName(String contactName, Date preferredDate) {
        if (contactName == null || preferredDate == null) {
            return null;
        }
        
        String formattedDate = preferredDate.format();
        return contactName + TravelForceConstants.DISPLAY_NAME_SEPARATOR + formattedDate;
    }

    private List<Trip__c> getTrips() {
        return (List<Trip__c>) Records;
    }
}