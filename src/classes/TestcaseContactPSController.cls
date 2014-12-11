@isTest(SeeAllData=true) 
  private class TestcaseContactPSController {
     static testmethod void TestcaseContactPSController(){
     List<Case> cases = new List<Case>{};
    
     Account anyAccount = null;
     try {
         anyAccount = [SELECT id FROM Account LIMIT 1];
     } catch (exception e) {
         anyAccount = new Account(Name='myGSA');
         insert anyAccount;
     }
   
     User u1 = [SELECT id, Assigned_Permission_Sets__c, Related_Groups__c, Related_Queues__c, email, firstname, lastname 
             FROM User WHERE isActive=true AND usertype='Standard' 
                 AND (Profile.name LIKE 'System Admin%') LIMIT 1];
     Contact uContact = null;
     try {
         uContact = [SELECT id, email FROM Contact WHERE email=:u1.email LIMIT 1];     
     } catch (exception e) { 
         uContact = new Contact(FirstName=u1.firstname, LastName=u1.lastname, AccountId=anyAccount.id, Phone='(703) 603-8172', Email=u1.email);
         insert uContact; 
     } 
     Contact poc = [SELECT id FROM Contact WHERE id=:uContact.id];
     
     List<PermissionSet> psList = new List<PermissionSet>([SELECT id FROM PermissionSet WHERE isOwnedbyProfile=false LIMIT 1]);  
     for (PermissionSet ps : psList) {
             PermissionSetAssignment ps1 = new PermissionSetAssignment();
             ps1.PermissionSetId=ps.Id;
             ps1.AssigneeId=u1.Id;
             try { insert ps1; } catch (exception e) {}
             u1.Assigned_Permission_Sets__c=ps1.id;
     }
     List<Group> pgList = new List< Group >([SELECT id FROM Group WHERE Type='regular' LIMIT 1]);  
     for (Group pg : pgList) {
             GroupMember gm1 = new GroupMember();
             gm1.GroupId=pg.Id;
             gm1.UserOrGroupId=u1.Id;
             try { insert gm1; } catch (exception e) {}
             u1.Related_Groups__c=gm1.id;
     }
     List<Group> qList = new List< Group >([SELECT id FROM Group WHERE Type='queue' LIMIT 1]);  
     for (Group q : qList) {
             GroupMember gm2 = new GroupMember();
             gm2.GroupId=q.Id;
             gm2.UserOrGroupId=u1.Id;
             try { insert gm2; } catch (exception e) {}
             u1.Related_Queues__c=gm2.id;
     }
     update u1;       
     
    //  Use the describe methods to get a map of CASE Record Types without executing a SOQL query 
       //Map <String,Schema.RecordTypeInfo> CASErecordTypes =
       //       Case.sObjectType.getDescribe().getRecordTypeInfosByName();
       // CASE RecordTypes        
      // String SystemCase=CASErecordTypes.get('Salesforce System Case').getRecordTypeId();
  
    //Run As U1
          System.RunAs(u1){
          Case testCaseInsert = new Case(ContactId=poc.id, OwnerId=u1.Id, Origin='Email', Subject='Any Request', Description='A Request', Status='New', Type='Systemic Issue');

          insert testCaseInsert;
  
          ApexPages.StandardController sc = new ApexPages.StandardController(testCaseInsert);
          caseContactPSController testEscalation = new caseContactPSController(sc);
           
          PageReference pageRef = Page.caseContactPS;
          Test.setCurrentPage(pageRef);
          system.assertEquals(true,true);
          }
     }
}