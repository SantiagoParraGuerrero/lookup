@IsTest
private class ContactLookupTest {

    @IsTest
    static void contactLookupTest() {

        // DATA
        Account account = new Account(
            Name = 'account name test'
        );
        insert account;

        Contact contact = new Contact(
            FirstName = 'FirstName',
            LastName = 'LastName',
            Phone = '123456789',
            Email = 'FirstName.LastName@example.com',
            HasOptedOutOfEmail = false,
            AccountId = account.Id
        );
        insert contact;

        Map<String, Object> payload = new Map<String, Object>();
        payload.put('accountName', account.Name);

        // TEST
        Test.startTest();
            ContactLookup contactLookup = new ContactLookup();
            List<LookupResult> selectionResult = ContactLookup.getSelection(new List<String>{contact.id}, payload);
            List<LookupResult> defaultSearchResultsResult = ContactLookup.getDefaultSearchResults(payload); 
            List<LookupResult> searchResultsResult = ContactLookup.getSearchResults('123', new List<String>(), payload); 
        Test.stopTest();

        // ASSERT
        Assert.areEqual(selectionResult[0].id, contact.id);
        Assert.areEqual(defaultSearchResultsResult[0].id, contact.id);
        Assert.areEqual(searchResultsResult[0].id, contact.id);
    }
}