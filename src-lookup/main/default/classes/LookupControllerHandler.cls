public inherited sharing class LookupControllerHandler {

  @TestVisible 
  public static String apexClass;

  @AuraEnabled(cacheable=true)
  public static List<LookupResult> getSelection(
    String uniqueId,
    List<String> values,
    Map<String, Object> payload
  ) {
    try {

      if (values.isEmpty()) {
        return new List<LookupResult>();
      }

      if (apexClass == null) {
        apexClass = Lookup__mdt.getInstance(uniqueId)?.Interface__c;
      }

      if (String.isBlank(apexClass)) {
        throw new AuraHandledException(
          'Lookup configuration is missing or not setup properly'
        );
      }

      LookupResult.ILookupResult lookupFetchClass =
        (LookupResult.ILookupResult) Type.forName(apexClass).newInstance();

      return lookupFetchClass.getSelection(values, payload);
    } catch (Exception e) {
      AuraHandledException auraException = new AuraHandledException(
        e.getMessage()
      );
      auraException.setMessage(e.getMessage());
      throw auraException;
    }
  }

  @AuraEnabled(cacheable=true)
  public static List<LookupResult> getDefaultSearchResults(
    String uniqueId,
    Map<String, Object> payload
  ) {
    try {

      if (apexClass == null) {
        apexClass = Lookup__mdt.getInstance(uniqueId)?.Interface__c;
      }

      if (String.isBlank(apexClass)) {
        throw new AuraHandledException(
          'Lookup configuration is missing or not setup properly'
        );
      }

      LookupResult.ILookupResult lookupFetchClass =
        (LookupResult.ILookupResult) Type.forName(apexClass).newInstance();

      return lookupFetchClass.getDefaultSearchResults(payload);
    } catch (Exception e) {
      AuraHandledException auraException = new AuraHandledException(
        e.getMessage()
      );
      auraException.setMessage(e.getMessage());
      throw auraException;
    }
  }

  @AuraEnabled(cacheable=true)
  public static List<LookupResult> getSearchResults(
    String uniqueId,
    String searchTerm,
    List<String> selectedIds,
    Map<String, Object> payload
  ) {
    try {

      if (apexClass == null) {
        apexClass = Lookup__mdt.getInstance(uniqueId)?.Interface__c;
      }

      if (String.isBlank(apexClass)) {
        throw new AuraHandledException(
          'Lookup configuration is missing or not setup properly'
        );
      }

      LookupResult.ILookupResult lookupFetchClass =
        (LookupResult.ILookupResult) Type.forName(apexClass).newInstance();

      return lookupFetchClass.getSearchResults(
        searchTerm,
        selectedIds,
        payload
      );
    } catch (Exception e) {
      AuraHandledException auraException = new AuraHandledException(
        e.getMessage()
      );
      auraException.setMessage(e.getMessage());
      throw auraException;
    }
  }
}