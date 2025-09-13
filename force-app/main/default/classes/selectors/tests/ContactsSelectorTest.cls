@IsTest
private class ContactsSelectorTest {
    
    @TestSetup
    static void makeData() {
        List<Contact> contacts = new List<Contact>();
        contacts.add(new Contact(
            FirstName = 'Test',
            LastName = 'User',
            Email = 'test.user@test.com'
        ));
        contacts.add(new Contact(
            FirstName = 'Jane',
            LastName = 'Smith',
            Email = 'jane.smith@test.com'
        ));
        insert contacts;
    }
    
    @IsTest
    static void testSelectById() {
        Contact contact = [SELECT Id FROM Contact WHERE FirstName = 'Test' LIMIT 1];
        ContactsSelector selector = new ContactsSelector();
        
        Test.startTest();
        List<Contact> contacts = selector.selectById(new Set<Id>{contact.Id});
        Test.stopTest();
        
        Assert.areEqual(1, contacts.size(), 'Should return one contact');
        Assert.areEqual(contact.Id, contacts[0].Id, 'Should return correct contact');
        Assert.areEqual('Test', contacts[0].FirstName, 'Should have correct first name');
        Assert.areEqual('User', contacts[0].LastName, 'Should have correct last name');
    }
    
    @IsTest
    static void testSelectByMultipleIds() {
        List<Contact> allContacts = [SELECT Id FROM Contact];
        ContactsSelector selector = new ContactsSelector();
        Set<Id> contactIds = new Set<Id>();
        for (Contact c : allContacts) {
            contactIds.add(c.Id);
        }
        
        Test.startTest();
        List<Contact> contacts = selector.selectById(contactIds);
        Test.stopTest();
        
        Assert.areEqual(2, contacts.size(), 'Should return all contacts');
    }
    
    @IsTest
    static void testSelectByEmptySet() {
        ContactsSelector selector = new ContactsSelector();
        
        Test.startTest();
        List<Contact> contacts = selector.selectById(new Set<Id>());
        Test.stopTest();
        
        Assert.areEqual(0, contacts.size(), 'Should return empty list for empty set');
    }
    
    @IsTest
    static void testGetSObjectFieldList() {
        ContactsSelector selector = new ContactsSelector();
        
        Test.startTest();
        List<Schema.SObjectField> fields = selector.getSObjectFieldList();
        Test.stopTest();
        
        Assert.isTrue(fields.size() > 0, 'Should return field list');
        Assert.isTrue(fields.contains(Contact.Id), 'Should include Id field');
        Assert.isTrue(fields.contains(Contact.Name), 'Should include Name field');
    }
    
    @IsTest
    static void testGetSObjectType() {
        ContactsSelector selector = new ContactsSelector();
        
        Test.startTest();
        Schema.SObjectType sObjectType = selector.getSObjectType();
        Test.stopTest();
        
        Assert.areEqual(Contact.SObjectType, sObjectType, 'Should return Contact SObjectType');
    }
}