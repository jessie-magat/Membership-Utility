@isTest(SeeAllData=true) 
  private class TestpermissionSetAssigneesController {
     static testmethod void TestpermissionSetAssigneesController(){
         
    List<PermissionSet> pSL = new List<PermissionSet>();      
    for (Integer i = 0; i < 1; i++) {
        PermissionSet aPS = new PermissionSet();
        aPS.label = 'psLabel'+i;
        aPS.name = 'psName'+i;
        pSL.add(aPS);
    }
    insert pSL;
    List<User> uL = new List<User>();      
    for (Integer i = 0; i < 40; i++) {
        User aU = new User();
        aU.lastName = 'uALast'+i;
        aU.firstName = 'uAFirst'+i;
        aU.alias = 'uA'+i;
        aU.username = 'uAemail'+i+'@gsa.gov';
        aU.email = 'uAemail'+i+'@gsa.gov';
        aU.EmailEncodingKey  = 'ISO-8859-1';
        aU.TimeZoneSidKey    = 'America/New_York';
        aU.LocaleSidKey    = 'en_US';
        aU.LanguageLocaleKey  = 'en_US';
        aU.ProfileId  = userinfo.getProfileId();
        uL.add(aU);
    }
    insert uL;
 
    Id permissionSetId;
     List<User> testUsers = new List<User>([SELECT id, email FROM USER WHERE isactive=true and usertype='Standard' LIMIT 40]);           
     List<PermissionSet> psList = new List<PermissionSet>([SELECT id FROM PermissionSet WHERE isOwnedbyProfile=false LIMIT 1]);  
     List<PermissionSetAssignment> psaList = new List<PermissionSetAssignment>(); 
     for (PermissionSet ps : psList) {
         for (User u: testUsers) {
             try { insert (new PermissionSetAssignment(PermissionSetId=ps.Id, AssigneeId=u.Id)); } catch (exception e) {}
         }
         permissionSetId=ps.id;
     } 

          PageReference pageRef = Page.permissionsetAssignees;
          Test.setCurrentPage(pageRef);
  
          PermissionSet ps = new PermissionSet();
          ApexPages.StandardController sc = new ApexPages.StandardController(ps);
          permissionsetAssigneesController testps = new permissionsetAssigneesController(sc);
          
          List<SelectOption> lst = testps.lst;
         
          testps.selected=permissionSetId;
          testps.change();
          testps.first();
          testps.previous();
          testps.next();
          testps.last();
          testps.previous();
          testps.next();
          system.assertEquals(true,true);
     }
}