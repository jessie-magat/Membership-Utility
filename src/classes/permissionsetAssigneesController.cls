public with sharing class permissionsetAssigneesController {

    Public permissionsetAssigneesController(ApexPages.StandardSetController controller){}
    Public Boolean psalst {get;set;}
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
    Public PermissionSet psName {get;set;}

    public permissionsetAssigneesController(ApexPages.StandardController controller) 
    {
        psalst=false;
        lst=new List<Selectoption>();
        lst.add(new Selectoption('','------------ Select PermissionSet ------------'));
        ps=[select id, label from PermissionSet WHERE isOwnedbyProfile=false order by label];
        for (PermissionSet a:ps)
            lst.add(new Selectoption(a.id,a.label));
    }

    Public PageReference change()
    {
        System.debug('---------------------------->'+selected);
        count=0;
        if(selected != '' || selected != null)
            psName= new PermissionSet();
        psName=[Select id, label from PermissionSet where id=:selected];
        psa=[SELECT id, permissionsetid, assigneeid, assignee.lastname, assignee.firstname, assignee.name, assignee.email FROM PermissionSetAssignment 
              WHERE PermissionSetid=:selected ORDER BY assignee.lastname, assignee.firstname];

        lstpsa= new List<PermissionSetAssignment>();
        if(psa.size()>=0)
        {
            psalst=true;
            count=psa.size();
            hasPrevious =false;
            hasNext=true;
            pageno=1;
            Decimal iT=psa.size();
            iT = (iT/10); 
            pageTotal=(Integer) iT.round(roundingMode.Ceiling);
            if (pageTotal==0) { pageTotal=1; }
            max = 10;
            if (psa.size()<max) { max=psa.size();  hasNext=false; }
            for(integer i=0;i<max;i++) { lstpsa.add(psa[i]); }
        }
        return null;
    }

    Public void First()
    {
        hasNext=true;
        lstpsa.clear();
        hasPrevious=false;
        pageno=1;
        max = 10;
        if (psa.size()<max) { max=psa.size(); hasNext=false; }
        for (integer i=0;i<max;i++) { lstpsa.add(psa[i]); }
    }

    Public void Previous()
    {
        hasNext=true;
        lstpsa.clear();
        if(pageno!=1)
        {
            pageno = pageno - 1;
            if (pageno==1 ) { hasPrevious=false; }
            for(integer i=(pageno-1)*10;i<(pageno*10);i++ )  { lstpsa.add(psa[i]); }
        }
        else
        {
            hasPrevious=false;
            for(integer i=(pageno -1)*10;i<(pageno*10);i++ ) { lstpsa.add(psa[i]); }
        }
    }

    Public void Next()
    {
        pageno  = pageno +1;
        integer pgno;
        lstpsa.clear();
        if (math.mod(psa.size(),10)==0)
            pgno=psa.size()/10;
        else
            pgno=(psa.size()/10) +1;
            
        if(pageno==pgno)
        {
            hasNext=false;
            for (integer i=(pageno-1)*10;i<psa.size();i++)  { lstpsa.add(psa[i]); }
        }
        else
            for (integer i=(pageno-1)*10;i<(pageno*10);i++) { lstpsa.add(psa[i]); }
            
        hasPrevious=true;
    }

    Public void Last()
    {
        hasPrevious=true;
        lstpsa.clear();
        hasNext=false;
        
        if( math.mod(psa.size(),10)==0)
            pageno = psa.size()/10;
        else
            pageno =(psa.size()/10)+1;
            
        for(integer i=(pageno-1)*10;i<psa.size();i++) { lstpsa.add(psa[i]); }
    }
}