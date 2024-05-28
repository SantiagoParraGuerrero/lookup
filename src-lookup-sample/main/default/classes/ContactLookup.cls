public class ContactLookup implements LookupResult.ILookupResult {

  public final static Map<String, Object> ACCOUNT_ICON = new Map<String, Object>{
    'iconName' => 'standard:contact'
  };

  public List<LookupResult> getSelection(
    List<String> values,
    Map<String, Object> payload
  ) {

    List<LookupResult> result = new List<LookupResult>();
    String parentAccountName = (String) payload.get('accountName');

    List<Contact> matchingContact = [
      SELECT Name, Email, HasOptedOutOfEmail
      FROM Contact
      WHERE Id IN :values AND Account.Name = :parentAccountName
      LIMIT 1
    ];

    if (!matchingContact.isEmpty()) {
      LookupResult singleResult = new LookupResult();
      singleResult.id = matchingContact[0].Id;
      singleResult.icon = ACCOUNT_ICON;
      singleResult.title = matchingContact[0].Name;
      result.add(singleResult);
    }

    return result;
  }

  public List<LookupResult> getDefaultSearchResults(
    Map<String, Object> payload
  ) {
    String parentAccountName = (String) payload.get('accountName');
    List<LookupResult> result = new List<LookupResult>();

    Set<Id> recentlyViewedRecords = new Set<Id>();

    for (RecentlyViewed record : [
      SELECT Id
      FROM RecentlyViewed
      WHERE LastViewedDate != NULL AND Type = 'Contact'
      ORDER BY LastViewedDate DESC
    ]) {
        recentlyViewedRecords.add(record.Id);
    }

    if (recentlyViewedRecords.isEmpty()) {
      return result;
    }

    List<Contact> contacts = [
      SELECT Name, Email, HasOptedOutOfEmail
      FROM Contact
      WHERE Id IN :recentlyViewedRecords AND Account.Name = :parentAccountName
      LIMIT 10
    ];

    for (Contact contact : contacts) {
      result.add(buildResult(contact));
    }

    return result;
  }

  public List<LookupResult> getSearchResults(
    String searchTerm,
    List<String> selectedIds,
    Map<String, Object> payload
  ) {

    String parentAccountName = (String) payload.get('accountName');
    List<LookupResult> result = new List<LookupResult>();

    searchTerm = '%' + searchTerm + '%';

    List<Contact> contacts = [
      SELECT Name, Email, HasOptedOutOfEmail
      FROM Contact
      WHERE
        Id NOT IN : selectedIds
        AND (Name LIKE :searchTerm OR Phone LIKE :searchTerm OR Email LIKE :searchTerm)
        AND Account.Name = :parentAccountName
    ];

    for (Contact contact : contacts) {
      result.add(buildResult(contact));
    }

    return result;
  }

  private LookupResult buildResult(Contact contact) {
    LookupResult result = new LookupResult();
    result.id = contact.Id;
    result.icon = ACCOUNT_ICON;
    result.title = contact.Name;
    result.payload = contact.getPopulatedFieldsAsMap();
    List<LookupResult.Subtitle> subtitles = new List<LookupResult.Subtitle>();

    if (String.isNotBlank(contact.Email)) {
        LookupResult.Subtitle email = new LookupResult.Subtitle();
        email.type = 'lightning-formatted-email';
        email.label = 'Email';
        email.value = contact.Email;
        email.props = new Map<String, Object>{ 'hideIcon' => true };
        subtitles.add(email);
    }

    LookupResult.Subtitle optedOut = new LookupResult.Subtitle();
    optedOut.type = 'lightning-icon';
    optedOut.label = 'Opted out of email';
    optedOut.props = new Map<String, Object>{
      'iconName' => contact.HasOptedOutOfEmail ? 'utility:email' : 'utility:end_chat'
    };
    subtitles.add(optedOut);

    result.subtitles = subtitles;

    return result;
  }
}
