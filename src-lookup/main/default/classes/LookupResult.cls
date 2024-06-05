public class LookupResult {
  @AuraEnabled
  public String id { get; set; }
  @AuraEnabled
  public Map<String, object> icon { get; set; }
  @AuraEnabled
  public String title { get; set; }
  @AuraEnabled
  public List<Subtitle> subtitles { get; set; }
  @AuraEnabled
  public Map<String, Object> recordPayload { get; set; }

  public class Subtitle {
    @AuraEnabled
    public String type { get; set; }
    @AuraEnabled
    public String label { get; set; }
    @AuraEnabled
    public Object value { get; set; }
    @AuraEnabled
    public Boolean highlightSearchTerm { get; set; }
    @AuraEnabled
    public Map<String, Object> props { get; set; }
  }

  public interface ILookupResult {
    List<LookupResult> getSelection(
      List<String> selectedIds,
      Map<String, Object> payload
    );
    List<LookupResult> getDefaultSearchResults(Map<String, Object> payload);
    List<LookupResult> getSearchResults(
      String searchTerm,
      List<String> selectedIds,
      Map<String, Object> payload
    );
  }
}
