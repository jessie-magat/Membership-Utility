public with sharing class QueueAssigneesController {

    Public QueueAssigneesController (ApexPages.StandardSetController controller){}
    Public Boolean psalst {get;set;}
    Public String  selected {get;set;}
    Public List<selectoption> lst {get;set;}
    Public Boolean hasPrevious {get;set;}
    Public Boolean hasNext {get;set;}
    Public Integer pageno {get;set;}
    Public Integer pageTotal {get;set;}
    Public List<Group > g {get;set;}
    Public List<User> userList{get;set;}
    Public List<User> lstpsa {get;set;}
    Public Integer count {get;set;}
    Public Integer max {get;set;}
    Public Group psName {get;set;}
    // Public Set<Id> allUserIds {get;set;}

    public QueueAssigneesController(ApexPages.StandardController controller) 
    {
        psalst=false;
        lst=new List<Selectoption>();
        lst.add(new Selectoption('','------------ Select Queue ------------'));
        g=[select Id, name from Group where type='Queue' order by name];
        
        for (Group gs:g){
           lst.add(new Selectoption(gs.id,gs.Name));
        } 
    }

    Public PageReference change()
    {
        psalst=false;
        hasPrevious =false;
        hasNext=false;
        System.debug('---------------------------->'+selected);
        count=0;
        if(selected != '' || selected != null)
        {
            psName= new Group();
            
            psName=[select Id, name from Group where id=:selected];
            
            Set<Id> groupIds = new Set<Id>();
            groupIds.add(psName.Id);

           // userList = new List<User>([Select Id, firstname,LastName,email From User Where Id In :allUserIds ORDER BY LastName,firstname ]);    
            Set<Id> allUsers = GetUserIdsFromGroup(groupIds);
            userList = new List<User>([Select Id, firstname,LastName,email From User Where Id In :allUsers ORDER BY LastName,firstname ]);  
        }
        
        lstpsa= new List<User>();
        if(userList.size()>0)
        {
            psalst=true;
            count=userList.size();
            hasPrevious =false;
            hasNext=true;
            pageno=1;
            Decimal iT=userList.size();
            iT = (iT/10); 
            pageTotal=(Integer) iT.round(roundingMode.Ceiling);
            if (pageTotal==0) { pageTotal=1; }
            max = 10;
            if (userList.size()<max) { max=userList.size();  hasNext=false; }
            for(integer i=0;i<max;i++) { lstpsa.add(userList[i]); }
        }
        return null;
    }
    
    public static Set<id> GetUserIdsFromGroup(Set<Id> groupIds)
    {
        Set<Id> result = new Set<Id>();
        Set<String> allgroupMembers = new Set<String>();
        
        String userType = Schema.SObjectType.User.getKeyPrefix();
        String groupType = Schema.SObjectType.Group.getKeyPrefix();
        String roleType = Schema.SObjectType.UserRole.getKeyPrefix();
        Set<Id> groupIdProxys = new Set<Id>();
        Set<Id> groupIdProxys1 = new Set<Id>();
        Set<Id> roleIdProxys = new Set<Id>();
        Map<Id, GroupMember> gm = new Map<ID, GroupMember>([Select Id, UserOrGroupId From GroupMember Where GroupId in :groupIds]);
        Map<Id,User> roleUsers = new Map<Id, User>([Select Id, Name From User where UserRoleId IN :gm.keyset()]);
        system.debug(' All Role Users are  <<<<<<<>>>>>>>>>>>>> '+ roleUsers);
        system.debug(' All Role Users are  ....<<<<<<<>>>>>>>>>>>>> '+ roleUsers.size());
        
        // Loop through all group members in a group
        for(GroupMember m : [Select Id, UserOrGroupId From GroupMember Where GroupId in :groupIds ])
        {
            allgroupMembers.add(m.UserOrGroupId);
            // If the user or group id is a user
            if(((String)m.UserOrGroupId).startsWith(userType)) {
                result.add(m.UserOrGroupId);
            }
            // If the user or group id is a group
            // Note: there may be a problem with governor limits if this is called too many times
            else if (((String)m.UserOrGroupId).startsWith(groupType)) { groupIdProxys.add(m.UserOrGroupId); }
            system.debug('The GroupMember is %%%%%%%%%%^^^^^^^^^^>>>>>> '+ m.UserOrGroupId);
        }
        
        for(Group g : [Select Type, RelatedId, Name, Id From Group  where Id in : groupIdProxys AND (Type = 'Role' OR Type = 'RoleAndSubordinates' OR Type = 'RoleAndSubordinatesInternal' )])
        {
            if(g.RelatedId != null ) { roleIdProxys.add(g.RelatedId); } else if (g.RelatedId == null ) { groupIdProxys1.add(g.Id); }
            system.debug('ALL Role Id Proxys ****** : '+ roleIdProxys);
            system.debug('ALL group Id Proxys ****** : '+ groupIdProxys1);
        
        }
        
        system.debug(' allgroupMembers is  >>>>>>>>>>>>> '+ allgroupMembers);
        system.debug(' allgroupMembers size is  >>>>>>>>>>>>> '+ allgroupMembers.size());
        
        if (roleIdProxys.size() > 0) {
            List<User> allRoleUsers = new List<User>();
            for(User usr : [Select u.UserRoleId, u.Id From User u where u.UserRoleId in : roleIdProxys]) { result.add(usr.Id); }
            system.debug('Size of Users in All Roles ###### : '+result.size());
        }
        
        if(groupIdProxys.size() > 0) { result.addAll(GetUSerIdsFromGroup(groupIdProxys)); }
     
        system.debug('The result size is%%%%%%%%%%^^^^^^^^^^>>>>>> '+ result.size());
        return result;  
    }

    Public void First()
    {
        hasNext=true;
        lstpsa.clear();
        hasPrevious=false;
        pageno=1;
        max = 10;
        if (userList.size()<max) { max=userList.size(); hasNext=false; }
        for (integer i=0;i<max;i++) { lstpsa.add(userList[i]); }
    }

    Public void Previous()
    {
        hasNext=true;
        lstpsa.clear();
        if(pageno!=1)
        {
            pageno = pageno - 1;
            if (pageno==1 ) { hasPrevious=false; }
            for(integer i=(pageno-1)*10;i<(pageno*10);i++ )  { lstpsa.add(userList[i]); }
        }
        else
        {
            hasPrevious=false;
            for(integer i=(pageno -1)*10;i<(pageno*10);i++ ) { lstpsa.add(userList[i]); }
        }
    }

    Public void Next()
    {
        pageno  = pageno +1;
        integer pgno;
        lstpsa.clear();
        if (math.mod(userList.size(),10)==0) { pgno=userList.size()/10; } else { pgno=(userList.size()/10) +1; }
            
        if(pageno==pgno)
        {
            hasNext=false;
            for (integer i=(pageno-1)*10;i<userList.size();i++)  { lstpsa.add(userList[i]); }
        }
        else
            for (integer i=(pageno-1)*10;i<(pageno*10);i++) { lstpsa.add(userList[i]); }
            
        hasPrevious=true;
    }

    Public void Last()
    {
        hasPrevious=true;
        lstpsa.clear();
        hasNext=false;
        
        if( math.mod(userList.size(),10)==0) { pageno = userList.size()/10; } else { pageno =(userList.size()/10)+1; }
            
        for(integer i=(pageno-1)*10;i<userList.size();i++) { lstpsa.add(userList[i]); }
    }
}