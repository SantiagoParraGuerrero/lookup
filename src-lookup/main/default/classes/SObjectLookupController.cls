public with sharing class SObjectLookupController {

  @AuraEnabled(cacheable=true)
  public static String getFieldInformation(
    String datasets
  ) {
    try {
      Map<String, Map<String, Object>> result = new Map<String, Map<String, Object>>();
      System.debug(datasets);
      List<DataSet> datasetList = (List<DataSet>) JSON.deserialize(
        datasets,
        List<DataSet>.class
      );

      for (DataSet dataset : datasetList) {
        String objectApiName = Schema.getGlobalDescribe()
          .get(dataset.sobjectApiName)
          .getDescribe()
          .getName();
        result.put(
          dataset.name,
          FieldUtil.getDescribeByField(objectApiName, new Set<String>(dataset.getFields()), true)
        );
      }
    

      return JSON.serialize(result);
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  @AuraEnabled(cacheable=true)
  public static List<List<SObject>> getDatasetRecords(
    String searchTerm,
    List<String> selectedIds,
    String datasets
  ) {
    try {
      List<List<SObject>> result = new List<List<SObject>>();
      Set<Id> resultIds = new Set<Id>();

      if (datasets == null) {
        return result;
      }

      List<DataSet> datasetList = (List<DataSet>) JSON.deserialize(
        datasets,
        List<DataSet>.class
      );

      for (DataSet dataset : datasetList) {
        Schema.SObjectType objectType = Schema.getGlobalDescribe().get(dataset.sobjectApiName);
        fflib_QueryFactory queryFactory = new fflib_QueryFactory(objectType);

        queryFactory.setLimit(50).selectFields(dataset.getFields());

        applySearchClause(queryFactory, searchTerm, dataset);
        applyWhereClause(queryFactory, dataset.whereClause);
        applySelectedIds(queryFactory, selectedIds);

        List<SObject> singleResult = new List<SObject>();

        for (SObject record : Database.query(queryFactory.toSOQL())) {
          if (!resultIds.contains(record.Id)) {
            singleResult.add(record);
            resultIds.add(record.Id);
          }
        }

        result.add(singleResult);
      }

      return result;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  @AuraEnabled(cacheable=true)
  public static List<List<SObject>> getInitialSelection(
    List<String> initialSelection,
    String datasets
  ) {
    fflib_QueryFactory queryFactory;

    try {
      List<List<SObject>> result = new List<List<SObject>>();
      if (datasets == null) {
        return result;
      }
      Set<Id> resultIds = new Set<Id>();

      List<DataSet> datasetList = (List<DataSet>) JSON.deserialize(
        datasets,
        List<DataSet>.class
      );

      for (DataSet dataset : datasetList) {
        queryFactory = new fflib_QueryFactory(
          Schema.getGlobalDescribe().get(dataset.sobjectApiName)
        );

        queryFactory
          .setCondition('Id IN :initialSelection')
          .selectFields(dataset.getFields());

        applyWhereClause(queryFactory, dataset.whereClause);

        List<SObject> singleResult = new List<SObject>();

        for (SObject record : Database.query(queryFactory.toSOQL())) {
          if (!resultIds.contains(record.Id)) {
            singleResult.add(record);
            resultIds.add(record.Id);
          }
        }

        result.add(singleResult);
      }

      return result;
    } catch (Exception e) {
      throw new AuraHandledException(
        e.getMessage() + ' Query: ' + queryFactory.toSOQL()
      );
    }
  }

  @AuraEnabled(cacheable=true)
  public static List<List<SObject>> getRecentlyViewed(String datasets) {

    
    fflib_QueryFactory queryFactory;

    try {
      List<List<SObject>> result = new List<List<SObject>>();

      if (datasets == null) {
        return result;
      }

      Set<Id> resultIds = new Set<Id>();

      List<DataSet> dataset = (List<DataSet>) JSON.deserialize(
        datasets,
        List<DataSet>.class
      );
      List<Id> recentIds = getRecentlyViewedRecords(dataset);

      for (DataSet param : dataset) {
        queryFactory = new fflib_QueryFactory(
          Schema.getGlobalDescribe().get(param.sobjectApiName)
        );

        queryFactory
          .setLimit(50)
          .selectFields(param.getFields())
          .setCondition('Id IN (\'' + String.join(recentIds, '\',\'') + '\')');

        applyWhereClause(queryFactory, param.whereClause);

        List<SObject> singleResult = new List<SObject>();

        for (SObject record : Database.query(queryFactory.toSOQL())) {
          if (!resultIds.contains(record.Id)) {
            singleResult.add(record);
            resultIds.add(record.Id);
          }
        }

        result.add(singleResult);
      }

      return result;
    } catch (Exception e) {
      throw new AuraHandledException(
        e.getMessage() + ' Query: ' + queryFactory.toSOQL()
      );
    }
  }

  private static void applyWhereClause(
    fflib_QueryFactory queryFactory,
    String whereClause
  ) {
    if (String.isNotBlank(whereClause)) {
      String condition = queryFactory.getCondition() != null
        ? '(' + queryFactory.getCondition() + ') AND (' + whereClause + ')'
        : whereClause;
      queryFactory.setCondition(condition);
    }
  }

  private static void applySelectedIds(
    fflib_QueryFactory queryFactory,
    List<String> selectedIds
  ) {
    if (!selectedIds.isEmpty()) {
      String selectedIdsCondition = 'Id NOT IN :selectedIds';
      String condition = queryFactory.getCondition() != null
        ? '(' +
          queryFactory.getCondition() +
          ') AND (' +
          selectedIdsCondition +
          ')'
        : selectedIdsCondition;
      queryFactory.setCondition(condition);
    }
  }

  private static void applySearchClause(
    fflib_QueryFactory queryFactory,
    String searchTerm,
    Dataset dataset
  ) {
    String searchTermInput = String.escapeSingleQuotes(searchTerm);
    if (String.isNotBlank(searchTerm) && String.isNotBlank(dataset.searchClause)) {
      System.debug(dataset.searchClause);
      
      String searchClause = dataset.searchClause.replaceAll('\\{searchTerm\\}', searchTermInput);
      queryFactory.setCondition(searchClause);
    }
  }

  private static List<Id> getRecentlyViewedRecords(
    List<DataSet> dataset
  ) {
    Set<String> objectApiNames = new Set<String>();

    for (DataSet param : dataset) {
      objectApiNames.add(param.sobjectApiName);
    }

    List<Id> result = new List<Id>();

    for (RecentlyViewed record : [
      SELECT Id
      FROM RecentlyViewed
      WHERE LastViewedDate != NULL AND Type IN :objectApiNames
      ORDER BY LastViewedDate DESC
    ]) {
      result.add(record.Id);
    }

    return new List<Id>(result);
  }

  private class DataSet {
    public String name;
    public List<Field> fields = new List<Field>();
    public String sobjectApiName;
    public String whereClause;
    public String searchClause;

    private Set<String> getFields() {
      Set<String> result = new Set<String>();

      for (Field field : this.fields) {
        result.add(field.name);
      }

      return result;
    }
  }

  private class Field {
    public String name;
  }

  private class LookupControllerException extends Exception {
  }
}
