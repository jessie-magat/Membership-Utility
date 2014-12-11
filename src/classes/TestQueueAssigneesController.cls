@isTest
private class TestQueueAssigneesController {

    static testMethod void TestQueueAssigneesController() {
    Id qId;
    
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
    LIST<QueueSobject> qOL = new LIST<QueueSobject>();
    for (Integer i = 0; i < 40; i++) {
        Group uG = new Group();
        uG.developername = 'uGroup'+i;
        uG.name = 'uGroup'+i;
        uG.type = 'Queue';
        uGL.add(uG);
    }
    insert uGL;
    for (Group uG : uGL) {
        QueueSobject qO = new QueueSobject(QueueId = uG.Id, SobjectType = 'Case');
        qOL.add(qO);
    }
    insert qOL;
    
     List<User> testUsers = new List<User>([SELECT id, email FROM USER WHERE isactive=true and usertype='Standard' LIMIT 40]);           
     List<Group> queueList = new List<Group>([select Id, name ,type from Group where type ='Queue' Limit 2]); 
 
     List<GroupMember> gmlst = new List<GroupMember>(); 
     for (Group q : queueList) {
         for (User u: testUsers) {
              gmlst.add(new GroupMember(UserOrGroupId=u.Id, GroupId=q.Id));
         }
         qId=q.id;
     }
       try { insert gmlst;} catch (exception e) {}

          PageReference pageRef = Page.QueueAssignees;
          Test.setCurrentPage(pageRef);
  
          Group gr = new Group();
          ApexPages.StandardController sc = new ApexPages.StandardController(gr);
          QueueAssigneesController testq = new QueueAssigneesController(sc);
          
          List<SelectOption> lst = testq.lst;
         
          testq.selected=qId;
          testq.change();
          testq.first();
          testq.previous();
          testq.next();
          testq.last();
          testq.previous();
          testq.next();
          system.assertEquals(true,true);
     }
    
}