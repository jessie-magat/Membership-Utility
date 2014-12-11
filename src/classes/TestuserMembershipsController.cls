@isTest(SeeAllData=true) 
  private class TestuserMembershipsController {
    static testmethod void TestuserMembershipsController(){
         
    user testUser = [SELECT id, email FROM USER WHERE isactive=true and usertype='Standard' LIMIT 1];

    List<PermissionSet> pSL = new List<PermissionSet>();      
    for (Integer i = 0; i < 50; i++) {
        PermissionSet aPS = new PermissionSet();
        aPS.label = 'psLabel'+i;
        aPS.name = 'psName'+i;
        pSL.add(aPS);
    }
    insert pSL;
               
     List<PermissionSet> psList = new List<PermissionSet>([SELECT id FROM PermissionSet WHERE isOwnedbyProfile=false LIMIT 50]); 
     List<PermissionSetAssignment> psaList = new List<PermissionSetAssignment>();  
     for (PermissionSet ps : psList) {
         try { insert (new PermissionSetAssignment(PermissionSetId=ps.Id, AssigneeId=testUser.Id)); } catch (exception e) {}
     } 
  
    //Run As U1
          System.RunAs(testUser){

          PageReference pageRef = Page.userMemberships;
          Test.setCurrentPage(pageRef);
                    
          PermissionSetAssignment psa = new PermissionSetAssignment();
  
          ApexPages.StandardController sc = new ApexPages.StandardController(psa);
          userMembershipsController testpsa = new userMembershipsController(sc);
          
          testpsa.userPSA =  [SELECT id, assigneeid FROM PermissionSetAssignment WHERE assigneeid=:testUser.id LIMIT 1];
         
          testpsa.change();
          testpsa.first();
          testpsa.previous();
          testpsa.next();
          testpsa.next();
          testpsa.previous();
          testpsa.last();
          testpsa.previous();
          testpsa.next();
          }
     }
}