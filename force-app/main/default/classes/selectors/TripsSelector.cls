public with sharing class TripsSelector extends fflib_SObjectSelector {
    
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            Trip__c.Id,
            Trip__c.Name,
            Trip__c.Contact__c,
            Trip__c.Preferred_Trip_Start__c,
            Trip__c.Flight__c,
            Trip__c.Status__c,
            Trip__c.Trip_Display_Name__c,
            Trip__c.CreatedDate,
            Trip__c.LastModifiedDate
        };
    }
    
    public Schema.SObjectType getSObjectType() {
        return Trip__c.SObjectType;
    }

    public List<Trip__c> selectByIdWithRelatedData(Set<Id> tripIds) {
        fflib_QueryFactory query = newQueryFactory()
            .selectField('Contact__r.Name')
            .selectField('Contact__r.Email')
            .selectField('Flight__r.Name')
            .selectField('Flight__r.Start__c')
            .setCondition('Id IN :tripIds');
            
        return Database.query(query.toSOQL());
    }

    public List<Trip__c> selectByContactId(Set<Id> contactIds) {
        return (List<Trip__c>) Database.query(
            newQueryFactory()
                .setCondition('Contact__c IN :contactIds')
                .toSOQL()
        );
    }

    public List<Trip__c> selectByFlightId(Set<Id> flightIds) {
        return (List<Trip__c>) Database.query(
            newQueryFactory()
                .setCondition('Flight__c IN :flightIds')
                .toSOQL()
        );
    }

    public List<Trip__c> selectByPreferredDateRange(Date startDate, Date endDate) {
        return (List<Trip__c>) Database.query(
            newQueryFactory()
                .setCondition('Preferred_Trip_Start__c >= :startDate AND Preferred_Trip_Start__c <= :endDate')
                .toSOQL()
        );
    }
}