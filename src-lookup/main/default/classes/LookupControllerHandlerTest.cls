@IsTest
private class LookupControllerHandlerTest {

    @IsTest
    static void lookupControllerTest() {

    // DATA
    LookupControllerHandler.apexClass = 'LookupControllerHandlerTest.MockLookupController';

    // TEST
    Test.startTest();
        List<LookupResult> LookupResult = LookupControllerHandler.getSelection('', new List<String>{''}, new Map<String, Object>()); 
	Test.stopTest();

    // ASSERT
    Assert.areEqual(LookupResult.size(), 1);
    } 

    @TestVisible
    public class MockLookupController implements LookupResult.ILookupResult {

        public List<LookupResult> getSelection(List<String> values, Map<String, Object> payload) {
            return new List<LookupResult>{new LookupResult()};
        }

        public List<LookupResult> getDefaultSearchResults(Map<String, Object> payload) {
            return new List<LookupResult>{new LookupResult()};
        }

        public List<LookupResult> getSearchResults(String searchTerm, List<String> selectedIds, Map<String, Object> payload) {
            return new List<LookupResult>{new LookupResult()};
        }
    }
}