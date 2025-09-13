public with sharing class ContactsSelector extends fflib_SObjectSelector {
    
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            Contact.Id,
            Contact.Name,
            Contact.Email,
            Contact.Phone,
            Contact.FirstName,
            Contact.LastName,
            Contact.CreatedDate,
            Contact.LastModifiedDate
        };
    }
    
    public Schema.SObjectType getSObjectType() {
        return Contact.SObjectType;
    }

    public List<Contact> selectById(Set<Id> contactIds) {
        return (List<Contact>) Database.query(
            newQueryFactory()
                .setCondition('Id IN :contactIds')
                .toSOQL()
        );
    }

    public List<Contact> selectByEmail(Set<String> emails) {
        return (List<Contact>) Database.query(
            newQueryFactory()
                .setCondition('Email IN :emails')
                .toSOQL()
        );
    }
    
    public List<Contact> selectByIdWithTrips(Set<Id> contactIds) {
        fflib_QueryFactory query = newQueryFactory();
        
        fflib_QueryFactory tripsSubQuery = query.subselectQuery('Trips__r');
        tripsSubQuery.selectFields(new TripsSelector().getSObjectFieldList());
        
        query.setCondition('Id IN :contactIds');
            
        return Database.query(query.toSOQL());
    }
}