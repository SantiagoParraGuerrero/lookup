public with sharing class SobjectLookupSampleController {
  @AuraEnabled(cacheable=true)
  public static List<String> getInitialSelection() {
    List<Opportunity> opps = [SELECT Id FROM Opportunity];

    List<Contact> contacts = [SELECT Id FROM Contact WHERE Account.Name = 'Edge Communications'];

    // , opps[0].Id 
    return new List<String>{ contacts[0].Id };
  }
}
