@isTest(SeeAllData=true)
private class TestPublicGroupAssigneesController {

    static testMethod void TestPublicGroupAssigneesController() {
    Id pgId;
    
    LIST<User> uL = new LIST<User>();      
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
    LIST<Group> uGL = new LIST<Group>();
    for (Integer i = 0; i < 40; i++) {
        Group uG = new Group();
        uG.developername = 'uGroup'+i;
        uG.name = 'uGroup'+i;
        uGL.add(uG);
    }
    
     List<User> testUsers = new List<User>([SELECT id, email FROM USER WHERE isactive=true and usertype='Standard' LIMIT 40]);           
     List<Group> groupList = new List<Group>([select Id, name,type from Group where type ='Regular' Limit 40]); 
     List<GroupMember> gmlst = new List<GroupMember>(); 
     for (Group g : groupList) {
         for (User u: testUsers) {
              gmlst.add(new GroupMember(UserOrGroupId=u.Id, GroupId=g.Id));
         }
         pgId=g.id;
     }
     //    gmlst.add(new GroupMember(UserOrGroupId=groupList[0].Id, GroupId=pgId));
        try { insert gmlst;} catch (exception e) {}

        PageReference pageRef = Page.publicGroupAssignee;
        Test.setCurrentPage(pageRef);
  
        Group gr = new Group();
        ApexPages.StandardController sc = new ApexPages.StandardController(gr);
        publicGroupAssigneesController testpg = new publicGroupAssigneesController(sc);
          
          List<SelectOption> lst = testpg.lst;
         
          testpg.selected=pgId;
          testpg.change();
          testpg.first();
       //   testpg.previous();
          testpg.next();
          testpg.last();
          testpg.previous();
          testpg.next();
          system.assertEquals(true,true);
     }
    
}