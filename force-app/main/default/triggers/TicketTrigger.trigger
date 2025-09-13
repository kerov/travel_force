trigger TicketTrigger on Ticket__c (before insert, before update, after insert, after update, before delete, after delete, after undelete) {
    fflib_SObjectDomain.triggerHandler(TicketsDomain.class);
}