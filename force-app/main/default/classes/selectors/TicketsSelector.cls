public with sharing class TicketsSelector extends fflib_SObjectSelector {
    
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            Ticket__c.Id,
            Ticket__c.Name,
            Ticket__c.Flight__c,
            Ticket__c.Contact__c,
            Ticket__c.CreatedDate,
            Ticket__c.LastModifiedDate
        };
    }
    
    public Schema.SObjectType getSObjectType() {
        return Ticket__c.SObjectType;
    }

    public List<Ticket__c> selectAvailable() {
        return (List<Ticket__c>) Database.query(
            newQueryFactory()
                .setCondition('Contact__c = null')
                .toSOQL()
        );
    }

    public List<Ticket__c> selectAvailableByFlightId(Set<Id> flightIds) {
        return (List<Ticket__c>) Database.query(
            newQueryFactory()
                .setCondition('Flight__c IN :flightIds AND Contact__c = null')
                .toSOQL()
        );
    }
    
    public List<Ticket__c> selectByContactId(Set<Id> contactIds) {
        return (List<Ticket__c>) Database.query(
            newQueryFactory()
                .setCondition('Contact__c IN :contactIds')
                .toSOQL()
        );
    }

    public List<Ticket__c> selectByFlightIdWithContact(Set<Id> flightIds) {
        return (List<Ticket__c>) Database.query(
            newQueryFactory()
                .selectField('Contact__r.Name')
                .selectField('Contact__r.Email')
                .selectField('Flight__r.Name')
                .selectField('Flight__r.Start__c')
                .setCondition('Flight__c IN :flightIds')
                .toSOQL()
        );
    }

    public Map<Id, Integer> countAvailableTicketsByFlight(Set<Id> flightIds) {
        Map<Id, Integer> flightTicketCounts = new Map<Id, Integer>();
        
        for (AggregateResult ar : [
            SELECT Flight__c, COUNT(Id) ticketCount
            FROM Ticket__c 
            WHERE Flight__c IN :flightIds 
            AND Contact__c = null
            GROUP BY Flight__c
        ]) {
            flightTicketCounts.put((Id)ar.get('Flight__c'), (Integer)ar.get('ticketCount'));
        }
        
        for (Id flightId : flightIds) {
            if (!flightTicketCounts.containsKey(flightId)) {
                flightTicketCounts.put(flightId, 0);
            }
        }
        
        return flightTicketCounts;
    }
}