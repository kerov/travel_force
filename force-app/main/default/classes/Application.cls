public class Application {
    
    public static final fflib_Application.UnitOfWorkFactory UnitOfWork = 
        new fflib_Application.UnitOfWorkFactory(
            new List<SObjectType> {
                Trip__c.SObjectType,
                Flight__c.SObjectType, 
                Ticket__c.SObjectType
            }
        );
        
    public static final fflib_Application.SelectorFactory Selector = 
        new fflib_Application.SelectorFactory(
            new Map<SObjectType, Type> {
                Trip__c.SObjectType => TripsSelector.class,
                Flight__c.SObjectType => FlightsSelector.class,
                Ticket__c.SObjectType => TicketsSelector.class,
                Contact.SObjectType => ContactsSelector.class
            }
        );
        
    public static final fflib_Application.DomainFactory Domain = 
        new fflib_Application.DomainFactory(
            Application.Selector,
            new Map<SObjectType, Type> {
                Trip__c.SObjectType => TripsDomain.class,
                Flight__c.SObjectType => FlightsDomain.class,
                Ticket__c.SObjectType => TicketsDomain.class
            }
        );

}