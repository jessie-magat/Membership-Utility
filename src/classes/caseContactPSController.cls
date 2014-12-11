public with sharing class caseContactPSController {

    Public List<String>  lstPSA {get;set;}
    Public List<Integer> posPSA {get;set;}
    Public List<String>  lstQueue {get;set;}
    Public List<Integer> posQueue {get;set;}
    Public List<String>  lstPublicGroup {get;set;}
    Public List<Integer> posPublicGroup {get;set;}
    
    //Public Integer count {get;set;}
    Private final Case sfcase;
    Public String contactProfile {get;set;}

    public caseContactPSController(ApexPages.StandardController controller) {
        this.sfcase = (Case) controller.getRecord();
        system.debug('########################################'+this.sfcase);
    //  count=0;
        lstPSA= new List<String>();
        lstQueue =new List<String>();
        lstPublicGroup =new List<String>(); 
        posPSA= new List<Integer>();
        posQueue =new List<Integer>();
        posPublicGroup =new List<Integer>(); 

        Case sfc = [SELECT id, contactid, contact.email FROM case WHERE id=:this.sfcase.id];
        
        contactProfile = null;
        if ( sfc.contact.email!=null ) {
            User contactUser =[SELECT id, Assigned_Permission_Sets__c, Related_Groups__c, Related_Queues__c, profile.name
                 FROM user WHERE email=:sfc.contact.email LIMIT 1];
            contactProfile = contactUser.profile.name; 
            
            if (contactUser.Assigned_Permission_Sets__c != null && contactUser.Assigned_Permission_Sets__c != '') {
                // system.debug('******************************** ps='+contactUser.Assigned_Permission_Sets__c);
                String ps = contactUser.Assigned_Permission_Sets__c; lstPSA = ps.split(';'); Integer p = 0; for (String psa : lstPSA) { posPSA.add(p); p++; }
            }
            if (contactUser.Related_Groups__c != null && contactUser.Related_Groups__c != '') {
                // system.debug('******************************** pg='+contactUser.Related_Groups__c);
                String pg = contactUser.Related_Groups__c; lstPublicGroup = pg.split(';');  Integer g = 0; for (String grp : lstPublicGroup) { posPublicGroup.add(g); g++; }
            }
            if (contactUser.Related_Queues__c != null && contactUser.Related_Queues__c != '') {
                // system.debug('******************************** qs='+contactUser.Related_Queues__c);
                String qs = contactUser.Related_Queues__c; lstQueue = qs.split(';'); Integer q = 0; for (String que : lstQueue) { posQueue.add(q); q++; }
            }            
        }
    }
}