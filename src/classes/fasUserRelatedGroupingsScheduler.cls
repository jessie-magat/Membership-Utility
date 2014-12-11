global class fasUserRelatedGroupingsScheduler implements Schedulable {

  global void execute(SchedulableContext sc) {

  fasUserRelatedGroupings batchShare= new fasUserRelatedGroupings();
  ID batchprocessid = Database.executeBatch(batchShare,1);
  }
}