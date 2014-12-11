global class fasUserRelatedGroupings implements Database.Batchable<SObject> {

    global final String query;
    global fasUserRelatedGroupings() {
    
        if (! Test.isRunningTest() ) 
           query = 'SELECT id, name, assigned_Permission_Sets__c, Related_Queues__c, Related_Groups__c, userRoleId, UserPermissionsMarketingUser, UserType FROM User WHERE isActive=true';
        else
           query = 'SELECT id, name, assigned_Permission_Sets__c, Related_Queues__c, Related_Groups__c, userRoleId, UserPermissionsMarketingUser, UserType FROM User WHERE isActive=true LIMIT 1';
    }

    global Database.QueryLocator start(Database.BatchableContext bc)  {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<sObject> batch){

        LIST<User> userList = new LIST<User>();
        userList = batch;
        Id MARKETING = '00G300000026LwiEAE';

        SET<Id> assigneeIDs = new Set<Id>();
        for (User usr : userList) {
           assigneeIDs.add(usr.id);
        }

        // Load all PS Assignments
        LIST<PermissionSetAssignment> psaList = [SELECT assigneeId, permissionSetId, permissionSet.label from PermissionSetAssignment
                                                  WHERE assigneeId IN :assigneeIDs AND permissionSet.isOwnedbyProfile=false];
        MAP<Id, String> psaMap = new MAP<Id, String>();
        for (PermissionSetAssignment psa : psaList) {
            if ( psaMap.containsKey(psa.assigneeId) ) {
                if (! psaMap.get(psa.assigneeId).contains(psa.permissionSet.label) ) {
                    psaMap.put(psa.assigneeId, psaMap.get(psa.assigneeId) + ';' + psa.permissionSet.label);
                }
            } else {
                psaMap.put(psa.assigneeId, psa.permissionSet.label);
            }
        }
        // load all group Memberships: Get all the groups, a user or group belongs to.
        MAP<Id,SET<Id>> groupMembershipMAP = new MAP<Id,SET<Id>>();
        LIST<GroupMember> gmList = [SELECT GroupId, UserOrGroupId FROM GroupMember];
        for (GroupMember gm : gmList) {
            SET<Id> mSet = new SET<Id>();
            if (groupMembershipMAP.containsKey(gm.UserOrgroupId)) {
                SET<Id> sSet = groupMembershipMAP.get(gm.UserOrgroupId);
                mSet.addAll(sSet);
            }
            mSet.add(gm.groupId);
            groupMembershipMAP.put(gm.UserOrgroupId,mSet);
        }
        
        MAP<Id,String> groupNameMap  = new MAP<Id,String>();
        MAP<Id,String> groupTypeMap   = new MAP<Id,String>();
        for (Group grp : [SELECT Id, RelatedId, DeveloperName, Name, Type FROM Group]) {
            if ( grp.RelatedId!=null) {  
                SET<Id> mSet = new SET<Id>();
                if (groupMembershipMAP.containsKey(grp.RelatedId)) {
                    SET<Id> sSet = groupMembershipMAP.get(grp.RelatedId);
                    mSet.addAll(sSet);
                }
                mSet.add(grp.Id);
                groupMembershipMAP.put(grp.RelatedId,mSet); 
            }
            groupTypeMap.put(grp.Id, grp.Type);   
            if (grp.Name==null) { grp.Name =  grp.DeveloperName; }                                     
            groupNameMap.put(grp.Id, grp.Name);
        }

        for (UserRole grp : [SELECT Id, ParentRoleId FROM UserRole]) {
            SET<Id> mSet = new SET<Id>();
            if (groupMembershipMAP.containsKey(grp.Id)) {
                SET<Id> sSet = groupMembershipMAP.get(grp.Id);
                mSet.addAll(sSet);
            }
            mSet.add(grp.parentRoleId);
            groupMembershipMAP.put(grp.id,mSet); 
        }          
     
        for (User u: userList) { 
            if (u.UserPermissionsMarketingUser==true) {
                SET<Id> mSet = new SET<Id>();
                if (groupMembershipMAP.containsKey(u.Id)) {
                    SET<Id> sSet = groupMembershipMAP.get(u.Id);
                    mSet.addAll(sSet);
                }
                mSet.add(MARKETING);
                groupMembershipMAP.put(u.Id,mSet);                   
            }
            if ( (u.userroleId!=null) && (groupMembershipMAP.containskey(u.userroleId)) ) {
                SET<Id> mSet = new SET<Id>();
                if (groupMembershipMAP.containsKey(u.Id)) {
                    SET<Id> sSet = groupMembershipMAP.get(u.Id);
                    mSet.addAll(sSet);
                }
                mSet.add(u.userroleId);
                groupMembershipMAP.put(u.Id,mSet);    
            }
        }        

        List<GroupMember> userMembershipList = new LIST<GroupMember>();
        for (User u: userList) {
             system.debug('*user start');
             SET<Id> gIDs = new SET<Id>();
             gIDs.addall(getMembershipSET(u.id,groupMembershipMAP,u.id));
             for (ID gID : gIDs) {
        //       system.debug('$$$$$$$$$$$$$$$$$$$$$$$$'+gID);
                 GroupMember uGM = new GroupMember();
                 uGM.UserOrGroupId = u.id;
                 uGM.GroupId = gID;
                 userMembershipList.add(uGM);
             }  
             system.debug('*user return*************************** size of userMembershipList='+userMembershipList.size());
        }          
        MAP<Id,String> groupMemberMap = new MAP<Id,String>();
        MAP<Id,String> queueMemberMap = new MAP<Id,String>();

        for (GroupMember uM : userMembershipList) {
            String groupName = groupNameMap.get(uM.GroupId);
            if (groupName!=null) {
                if (groupTypeMap.get(uM.GroupId) == 'Regular') {   
                    if ( groupMemberMap.containsKey(uM.UserOrGroupId) ) {
                        if (! groupMemberMap.get(uM.UserOrGroupId).contains(groupName) ) {
                            groupMemberMap.put(uM.UserOrGroupId, groupMemberMap.get(uM.UserOrGroupId) + ';' + groupName);
                        }
                    } else {
                        groupMemberMap.put(uM.UserOrGroupId, groupName);
                    }
                }
                if (groupTypeMap.get(uM.GroupId) == 'Queue') {
                    if ( queueMemberMap.containsKey(uM.UserOrGroupId) ) {
                        if (! queueMemberMap.get(uM.UserOrGroupId).contains(groupName) ) {
                            queueMemberMap.put(uM.UserOrGroupId, queueMemberMap.get(uM.UserOrGroupId) + ';' + groupName);
                        }
                    } else {
                        queueMemberMap.put(uM.UserOrGroupId, groupName);
                    }
                }
            }            
        }     

        Map <Id, String> userAssignedPSMap    = new Map <Id, String>();
        Map <Id, String> userAssignedGroupMap = new Map <Id, String>();
        Map <Id, String> userAssignedQueueMap = new Map <Id, String>();

        Id userRoleId = null;
        for (Id assigneeId : assigneeIDs) {
            // PermissionSets
            if ( psaMap.containsKey(assigneeId) ) {
                userAssignedPSMap.put(assigneeId, psaMap.get(assigneeId));
        //        system.debug('>>>>>>>>>>>>>>>'+userAssignedPSMap.get(assigneeId));
            }
            // Regular Group Type
            if ( groupMemberMap.containsKey(assigneeId) ) {
                userAssignedGroupMap.put(assigneeId, groupMemberMap.get(assigneeId));
               system.debug('>>>>>>>>>>>>>>>'+userAssignedGroupMap.get(assigneeId));
            }
            // Queue Group Type
            if ( queueMemberMap.containsKey(assigneeId) ) {
                userAssignedQueueMap.put(assigneeId, queueMemberMap.get(assigneeId));
                               system.debug('>>>>>>>>>>>>>>>'+userAssignedQueueMap.get(assigneeId));
            }
        }

        LIST<User> usersToUpdate = new LIST<User>();
        for ( User usr : userList ) {
            if ( (usr.assigned_Permission_Sets__c!=null) || (usr.Related_Queues__c != null) || (usr.Related_Groups__c != null)
               || (userAssignedPSMap.containsKey(usr.id)) || (userAssignedGroupMap.containsKey(usr.id)) || (userAssignedQueueMap.containsKey(usr.id)) ) {
                usr.assigned_Permission_Sets__c=null;
                usr.Related_Queues__c = null;
                usr.Related_Groups__c = null;
                if ( userAssignedPSMap.containsKey(usr.id) ) {
                    usr.assigned_Permission_Sets__c=userAssignedPSMap.get(usr.id);
                }
                if ( userAssignedGroupMap.containsKey(usr.id) ) {
                    usr.Related_Groups__c=userAssignedGroupMap.get(usr.id);
                }
                if ( userAssignedQueueMap.containsKey(usr.id) ) {
                    usr.Related_Queues__c=userAssignedQueueMap.get(usr.id);
                }
                usersToUpdate.add(usr);
            }
        }
        update usersToUpdate;
    }

    private SET<Id> getMembershipSET (ID userid, MAP<Id,SET<Id>> groupMembershipMAP, ID pGID) {
    
        SET<Id> membershipSET = new SET<Id>();
        SET<Id> uSet  = new SET<Id>();
        if (groupMembershipMAP.containskey(pGID)) {
            uSet=groupMembershipMAP.get(pGID);
        }
        Integer i=0; 
        for (Id rMBR : uSet) {
            i++;
            String iC = '0000000000'+String.valueOf(i);   
            iC = iC.substring(iC.length()-4,iC.length());
            system.debug('>>>['+iC+']='+rMBR);
            membershipSET.add(rMBR);           
        }
        for (Id rMBR : membershipSET) {
            membershipSET.addall(getmembershipSET(userid,groupMembershipMAP,rMBR));
        } 
        return membershipSET;
    }

    global void finish(Database.BatchableContext bc){
    }
}