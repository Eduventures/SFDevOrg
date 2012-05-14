public  without sharing class DevToolController {
    public Contact user { get; set; }
    public Account mainAccount { get; set; }
    public List<Scenario__c> scenarios;
    
    public DevToolController() {
        user = new Contact();
        mainAccount = new Account();
        scenarios = new List<Scenario__c>();
        String tempId = '';
        Boolean validUserId = false;
        
        if(ApexPages.currentPage().getParameters().containsKey('cid'))
        {
            tempId = ApexPages.currentPage().getParameters().get('cid');
            if(tempId.length() == 15 || tempId.length() == 18)
            {
                if( [ SELECT count() from Contact WHERE id = :tempId] == 0)
                {
                    ApexPages.Message noMatch = new ApexPages.Message(ApexPages.Severity.ERROR, 'We could not match that UserId to an existing Contact!');
                    ApexPages.addMessage(noMatch);                        
                } else {
                    validUserId = true;
                }
            } else 
            {
                ApexPages.Message invalidId = new ApexPages.Message(ApexPages.Severity.ERROR, 'The UserId Provided is not valid (wrong length)');
                ApexPages.addMessage(invalidId);
            }
        } else 
        {
            ApexPages.Message missingId = new ApexPages.Message(ApexPages.Severity.ERROR, 'The UserId is missing');
            ApexPages.addMessage(missingId);
        }
        if(validUserId == true)
        {
            user = [ SELECT Id, FirstName, LastName, Name, Email, Phone, AccountId, Account.Name FROM Contact WHERE Id = :tempId ];                                           
        }  
    }

    public void setscenarios(List<Scenario__c> thelist){
        scenarios = thelist;
    }
    
    public List<Scenario__c> getscenarios(){
        return [SELECT Id, Name, CreatedDate, CreatedBy.Name, Campaign_Name__c, LastModifiedDate, Total_Donors_Required__c, 
        				Total_Gifts_Equaling__c, Total_Number_of_Visits_Needed__c, Total_Prospects_Required__c, 
        				Category_Count__c FROM Scenario__c WHERE Account__c = :user.AccountId ];
    }   
     
    public PageReference createScenario(){
        Scenario__c newScenario = new Scenario__c(
            Name = user.Name + '-' + System.now().format(),
            Account__c = user.AccountId
        );
        insert newScenario; 
        PageReference createRef = Page.campaign_plannerv4;
        createRef.getParameters().put('id',newScenario.id);
        createRef.getParameters().put('cid',user.Id);
        return createRef;
    }
    
    public PageReference editScenario(){ 
        String editid = ApexPages.currentPage().getParameters().get('editid');
        PageReference createRef = Page.campaign_plannerv4;
        createRef.getParameters().put('id',editid);
        createRef.getParameters().put('cid',user.Id);
        return createRef;
    } 
    
    public PageReference cloneScenario(){
        String cloneid = ApexPages.currentPage().getParameters().get('cloneid');
        Scenario__c selectedScenario = [SELECT Id, Name, Account__c, CreatedDate, CreatedBy.Name, LastModifiedDate, Total_Donors_Required__c, Total_Gifts_Equaling__c,
                            Total_Number_of_Visits_Needed__c, Total_Prospects_Required__c, Category_Count__c FROM Scenario__c WHERE Id = :cloneid ];
                            
        List<Staffing_Category__c> categories = [ SELECT Id, Name, CreatedDate, CreatedBy.Name, Total_Donors_Required__c, Total_Gifts_Equaling__c,
                            Total_Number_of_Visits_Needed__c, Total_Prospects_Required__c, Scenario__c,
                                (Select Total_Number_of_Visits_Needed__c, Total_Gifts_Equalling__c,
                                    Staffing_Category__c, Number_of_Visits_Per_Prospect__c, 
                                    Number_Of_Prospects__c, Number_Of_Donors__c, Name, 
                                    Id  FROM Staffing_Levels__r)
                             FROM Staffing_Category__c WHERE Scenario__c = :selectedScenario.Id];
                                                   
        Scenario__c newScenario = new Scenario__c(
            Name = 'copy_of_' + selectedScenario.Name,
            Account__c = selectedScenario.Account__c
        );
        insert newScenario; 
        for(Staffing_Category__c sc:categories)
        {
            Staffing_Category__c tempsc = new Staffing_Category__c(
                Scenario__c = newScenario.Id,
                Name = sc.Name,
                Account__c = sc.Account__c
            );
            insert tempsc;
            for(Staffing_Level__c sl : sc.Staffing_Levels__r)
            {
                Staffing_Level__c tempsl = new Staffing_Level__c( 
                    Name = sl.Name,
                    Staffing_Category__c = tempsc.Id,
                    Account__c = sl.Account__c
                    );
                insert tempsl;
            }
        }
        PageReference createRef = Page.campaign_planner;
        createRef.getParameters().put('id',newScenario.id);
        createRef.getParameters().put('cid',user.Id);
        return createRef;
    }
    
    public PageReference deleteScenario(){
        String cloneid = ApexPages.currentPage().getParameters().get('deleteid');
        Scenario__c deleteRecord = [ SELECT Id FROM Scenario__c WHERE Id = :cloneid];
        delete deleteRecord;
        ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.INFO, 'The Scenario has been deleted.'));
        return null;
    }
}