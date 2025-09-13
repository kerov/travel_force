public with sharing class FlightsSelector extends fflib_SObjectSelector {
    
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            Flight__c.Id,
            Flight__c.Name,
            Flight__c.Start__c,
            Flight__c.CreatedDate,
            Flight__c.LastModifiedDate
        };
    }
    
    public Schema.SObjectType getSObjectType() {
        return Flight__c.SObjectType;
    }
    
    public List<Flight__c> selectByDate(Date flightDate) {
        Date startOfDay = flightDate;
        Date endOfDay = flightDate.addDays(1);
        
        return (List<Flight__c>) Database.query(
            newQueryFactory()
                .setCondition('Start__c >= :startOfDay AND Start__c < :endOfDay')
                .setOrdering('Start__c', fflib_QueryFactory.SortOrder.ASCENDING)
                .toSOQL()
        );
    }
    
    public List<Flight__c> selectByDateRange(Date startDate, Date endDate) {
        Date startOfRange = startDate;
        Date endOfRange = endDate.addDays(1);
        
        return (List<Flight__c>) Database.query(
            newQueryFactory()
                .setCondition('Start__c >= :startOfRange AND Start__c < :endOfRange')
                .setOrdering('Start__c', fflib_QueryFactory.SortOrder.ASCENDING)
                .toSOQL()
        );
    }

    public List<Flight__c> selectWithAvailableTickets() {
        fflib_QueryFactory query = newQueryFactory();
        
        fflib_QueryFactory ticketsSubquery = new TicketsSelector().addQueryFactorySubselect(query, 'Tickets__r')
            .setCondition('Contact__c = null');
            
        return Database.query(query.toSOQL());
    }

    public List<Flight__c> selectByDateWithTicketCounts(Date flightDate) {
        Date startOfDay = flightDate;
        Date endOfDay = flightDate.addDays(1);
        
        fflib_QueryFactory query = newQueryFactory()
            .setCondition('Start__c >= :startOfDay AND Start__c < :endOfDay')
            .setOrdering('Start__c', fflib_QueryFactory.SortOrder.ASCENDING);
        
        new TicketsSelector().addQueryFactorySubselect(query, 'Tickets__r');
            
        return Database.query(query.toSOQL());
    }
}