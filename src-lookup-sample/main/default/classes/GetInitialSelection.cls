public with sharing class GetInitialSelection {
  @AuraEnabled(cacheable=true)
  public static List<String> getInitialSelection() {
    List<Contact> contacts = [SELECT Id FROM Contact];

    // , opps[0].Id 
    return new List<String>{ contacts[0].Id };
  }
}
