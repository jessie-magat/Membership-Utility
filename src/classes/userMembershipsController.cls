public with sharing class userMembershipsController {

    Public userMembershipsController(ApexPages.StandardSetController controller){}

    Public Boolean psalst {get;set;}
    Public Boolean psassignee {get;set;}
    Public String  selected {get;set;}
    Public List<selectoption> lst {get;set;}
    Public Boolean hasPrevious {get;set;}
    Public Boolean hasNext {get;set;}
    Public Integer pageno {get;set;}
    Public Integer pageTotal {get;set;}
    Public List<PermissionSet> ps {get;set;}
    Public List<PermissionSetAssignment> psa {get;set;}
    Public List<PermissionSetAssignment> lstpsa {get;set;}
    Public Integer count {get;set;}
    Public Integer max {get;set;}
    Public User usr {get;set;}
    Public PermissionSetAssignment userPSA {get;set;}
    
    Public List<Group> grp {get;set;}
  Public Boolean gassignee {get;set;}
  Public Integer gcount {get;set;}
  
  Public List<Group> que {get;set;}
  Public Boolean qassignee {get;set;}
  Public Integer qcount {get;set;}
   
    public userMembershipsController(ApexPages.StandardController controller) {

    psassignee=false;
    gassignee = false;
    qassignee = false;
    userPSA = new PermissionSetAssignment();    
    }

    Public PageReference change(){
        System.debug('---------------------------->'+selected);
        count=0;
        gcount = 0;
        qcount = 0;
        system.debug('%%%%%%%%%%%%%%%%%%%%%%%%%%%'+userPSA);
        usr=[Select id, name from User WHERE id=:userPSA.assigneeid LIMIT 1 ];
        psa=[SELECT id, permissionsetid, permissionset.label, permissionset.name, assigneeid, assignee.lastname, assignee.firstname, assignee.name, assignee.email FROM PermissionSetAssignment 
              WHERE assigneeid=:userPSA.assigneeid AND permissionset.isOwnedbyProfile=false ORDER BY permissionset.label];

        lstpsa= new List<PermissionSetAssignment>();
        if(psa.size()>=0)
        {
            psassignee=true;
            count=psa.size();
            hasPrevious =false;
            hasNext=true;
            pageno=1;
            Decimal iT=psa.size();
            iT = (iT/10); 
            pageTotal=(Integer) iT.round(roundingMode.Ceiling);
            if (pageTotal==0) pageTotal=1;
            max = 10;
            if (psa.size()<max) { max=psa.size();  hasNext=false; }
            for(integer i=0;i<max;i++)
               lstpsa.add(psa[i]);
        }
        
        SET<Id> allGroupIds = getGroupsForIds(new Set<Id>{usr.Id});
        
        grp = [Select Type, Name, Id From Group Where Id IN : allGroupIds And Type =: 'Regular'];
        
        system.debug('The GROUP NAME IS >>>>>>>  ' + grp.size());
        if (grp.size()>=0) {
          gassignee = true;
          gcount = grp.size();
        }
        
        SET<Id> allQueueIds = getGroupsForIds(new Set<Id>{usr.Id});
        
        que = [Select Type, Name, Id From Group Where Id IN : allQueueIds And Type =: 'Queue']; 
    
        system.debug('The GROUP NAME IS >>>>>>>  ' + que.size());
        if (que.size()>=0) {
          qassignee = true;
          qcount = que.size();
        }
        return null;
    }
    
    public Set<Id> getGroupsForIds(Set<Id> userOrGroupIds) {

      Set<Id> output = new Set<Id>();
      Set<Id> nestedGroupIds = new Set<Id>();
      // only query actual groups and not roles and queues
      list<GroupMember> records = [select id, GroupId, UserOrGroupId from GroupMember where UserOrGroupId =: userOrGroupIds and UserOrGroupId != null];
  
      for (GroupMember record:records)
      {
          // found a group, remember for traversal
          if (!(record.UserOrGroupId + '').startsWith('005'))
          {
              nestedGroupIds.add(record.UserOrGroupId);   
          }
          else
          {
              output.add(record.GroupId);
          }
      }
  
      // call self to get nested groups we found
      if (nestedGroupIds.size() > 0)
      {
          output.addAll(getGroupsForIds(nestedGroupIds));
      }
  
      return output;
  }

    Public void First()
    {
        hasNext=true;
        lstpsa.clear();
        hasPrevious=false;
        pageno=1;
        max = 10;
        if (psa.size()<max) { max=psa.size(); hasNext=false; }
        for(integer i=0;i<max;i++)
        {
            lstpsa.add(psa[i]);
        }
    }

    Public void Previous()
    {
        hasNext=true;
        lstpsa.clear();
        if(pageno!=1)
        {
            pageno = pageno - 1;
            if (pageno==1 )
                hasPrevious=false;
            for(integer i=(pageno-1)*10;i<(pageno*10);i++ )
            {
                lstpsa.add(psa[i]);
                System.debug('--------------------SIZE OF PAGINATION LIST---------------------'+lstpsa .size()+' RECORDS '+psa[i]);
            }
        }
        else
        {
            hasPrevious=false;
            for(integer i=(pageno -1)*10;i<(pageno*10);i++ )
            {
                lstpsa.add(psa[i]);
                System.debug('--------------------SIZE OF PAGINATION LIST---------------------'+lstpsa .size()+' RECORDS '+psa[i]);
            }
        }
    }

    Public void Next()
    {
        pageno  = pageno +1;
        integer pgno;
        lstpsa.clear();
        if(math.mod(psa.size(),10)==0)
        {
            pgno=psa.size()/10;
        }
        else
            pgno=(psa.size()/10) +1;
        if(pageno==pgno)
        {
            hasNext=false;
            for (integer i=(pageno-1)*10;i<psa.size();i++)
            {
                lstpsa.add(psa[i]);
                System.debug('--------------------SIZE OF PAGINATION LIST---------------------'+lstpsa.size()+' RECORDS '+psa[i]);
            }
        }
        else
            for(integer i=(pageno-1)*10;i<(pageno*10);i++ )
            {
                lstpsa.add(psa[i]);
                System.debug('--------------------SIZE OF PAGINATION LIST---------------------'+lstpsa .size()+' RECORDS '+psa[i]);
            }
        hasPrevious=true;
        System.debug('---------------------------- LIST SIZE OF TEMPLIST ---------------------'+psa.size());
    }

    Public void Last()
    {
        System.debug('---------------------------------------------- LAST METHOD IS CALLING ----------------------');
        hasPrevious=true;
        lstpsa.clear();
        hasNext=false;
        if( math.mod(psa.size(),10)==0)
            pageno =psa.size()/10;
        else
            pageno =(psa.size()/10)+1;
        for(integer i=(pageno-1)*10;i<psa.size();i++)
        {
            lstpsa.add(psa[i]);
        }
    }
}