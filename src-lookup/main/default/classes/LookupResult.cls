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
  public Map<String, Object> payload { get; set; }

  public class Subtitle {
    @AuraEnabled
    public String type { get; set; }
    @AuraEnabled
    public String label { get; set; }
    @AuraEnabled
    public Object value { get; set; }
    @AuraEnabled
    public Map<String, Object> typeAttributes { get; set; }
  }

  public interface ILookupResult {
    List<LookupResult> getSelection(List<String> values, Map<String, Object> payload);
    List<LookupResult> getDefaultSearchResults(Map<String, Object> payload);
    List<LookupResult> getSearchResults(
      String searchTerm,
      List<String> selectedIds,
      Map<String, Object> payload
    );
  }
}
