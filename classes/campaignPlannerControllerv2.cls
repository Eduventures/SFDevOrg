public with sharing class campaignPlannerControllerv2 {
    
    public Scenario__c theScenario { get; set; }
    public Integer jumpto { get; set; }
    public Contact theUser { get; set; }
    public Integer stepCount { get; set; }
    public String editCategoryId { get; set; }
    public String deleteCategoryId { get; set; }
    public Staffing_Category__c editCategory { get; set; }
    public List<Staffing_Category__c> categories;
    public Map<Id,Staffing_Category__c> categoriesMap { get; set; }
    
    public String levelCategoryId { get; set; }
    public String editLevelId { get; set; }
    public String deleteLevelId { get; set; }
    public Staffing_Level__c addLevel { get; set; }

    public String editPositionId { get; set; }
    public String deletePositionId { get; set; }
    public Staffing_Position__c addPosition { get; set; }
    public List<Staffing_Position__c> positions;

    
    public campaignPlannerControllerv2 (ApexPages.StandardController stdController) {
        String theid = stdController.getId();
        theScenario = [SELECT Total_Prospects_Required__c, Campaign_Length__c, Scenario__c.Lower_Gift_Limit__c, 
                        Prospect_To_Donor_Ratio__c, Total_Number_of_Visits_Needed__c, Total_Gifts_Equaling__c, Total_Donors_Required__c, 
                        Name, LastModifiedDate, LastModifiedById, Id, CreatedDate, CreatedBy.Name, Category_Count__c, Account__c,
                        Campaign_Name__c From Scenario__c  WHERE Id = :theid];
        
        String tempUserId = '';
        editCategoryId = '';
        deleteCategoryId = '';
        levelCategoryId = '';
        editLevelId = '';
        deleteLevelId = '';
        deletePositionId = '';
        jumpto = 1;
        editCategory = new Staffing_Category__c();
        editCategory.Scenario__c = theScenario.Id;
        editCategory.Account__c = theScenario.Account__c;

        categories = new List<Staffing_Category__c>();

        addLevel = new Staffing_Level__c();
        addLevel.Scenario__c = theScenario.Id;
        addLevel.Account__c = theScenario.Account__c;
        
        addPosition = new Staffing_Position__c();
        addPosition.Scenario__c = theScenario.Id;
              
        if(ApexPages.currentPage().getParameters().containsKey('cid'))
        {
            tempUserId = ApexPages.currentPage().getParameters().get('cid');
            if(tempUserId.length() == 15 || tempUserId.length() == 18)
            {
                if( [ SELECT count() from Contact WHERE id = :tempUserId] == 0)
                {
                    ApexPages.Message noMatch = new ApexPages.Message(ApexPages.Severity.ERROR, 'We could not match that UserId to an existing Contact!');
                    ApexPages.addMessage(noMatch);                        
                } else {
                    theUser = [ SELECT Id, FirstName, LastName, Name, Account.Name, Email, Phone, AccountId FROM Contact WHERE Id = :tempUserId ];   
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
        stepCount = 1;
    }
    
    public PageReference saveName(){
    	if(theScenario.Campaign_Name__c == null || theScenario.Campaign_Name__c.length() == 0  )
    	{
             theScenario.Campaign_Name__c.addError('Please provide a name for the campaign');
    	} else 
    	{
	        update theScenario;
	        stepCount = 2;
    	}
        return null;
    }
    
    public pageReference jumpto() { 
        stepCount = jumpto; 
        return null;
    }
    
    public PageReference saveLevelCateogries(){
        update positions;
        stepCount = stepCount + 1;
        return null;
    }   
           
    public PageReference next(){
    	Boolean passok = true;
    	if(stepCount == 2 && categories.isEmpty())
    	{
    		ApexPages.Message notiers = new ApexPages.Message(ApexPages.Severity.ERROR, 'Please enter at least one Gift Tier before moving on.');
            ApexPages.addMessage(notiers);
            passok = false;
    	} else if (stepCount == 3)
    	{
    		for(Staffing_Category__c sc : categories)
    		{
    			if(sc.Staffing_Positions__r.size() == 0)
    			{
    				passok = false;
					ApexPages.Message notiers = new ApexPages.Message(ApexPages.Severity.ERROR, 'Please enter at least one position, per Gift Tier before moving on.');
    		        ApexPages.addMessage(notiers);
    			}
    		}
    	} else if( stepCount == 4)
    	{
    		for(Staffing_Category__c sc : categories)
    		{
    			if(sc.Staffing_Levels__r.size() == 0)
    			{
    				passok = false;
					ApexPages.Message notiers = new ApexPages.Message(ApexPages.Severity.ERROR, 'Please enter at least one Level, per Gift Tier before moving on.');
    		        ApexPages.addMessage(notiers);
    			}
    		}
    	}
    	
    	if(passok) 
    	{
	        stepCount = stepCount + 1;	
    	}
        return null;
    }
    
    public PageReference back(){
        stepCount = stepCount - 1;
        return null;
    }
    /*Category Creation Code here*/
    public PageReference saveCedit() {

    	String tempName = '';
    	if(editCategory.Threshold_Lower__c == null)
    	{
    		ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'You must supply a lower limit for each tier.'));
            return null;
    	} else 
    	{
    		tempName = '$' + editCategory.Threshold_Lower__c.format();
    	}  	
    	if(editCategory.Threshold_Upper__c == null)
    	{
    		tempName = tempName + ' + ';
    	} else 
    	{
    		tempName = tempName + ' - $' + editCategory.Threshold_Upper__c.format();
    	}
    	editCategory.Name = tempName;

        if(editCategory.Id != null)
        {
            update editCategory ;
            editCategoryId = '';
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.INFO, 'The gift pyramid tier has been updated.'));
        } else 
        {
            if(editCategory.Scenario__c == null)
            {
                ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'There is no Scenario chosen'));
                return null;
            } else
            {            
                insert editCategory;
                ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.INFO, 'The gift pyramid tier has been saved.'));
            }
        } 
        editCategory = new Staffing_Category__c();
        editCategory.Scenario__c = theScenario.Id;
        editCategory.Account__c = theScenario.Account__c;
        return null;
    }

    public PageReference cancelCedit(){
        editCategory = new Staffing_Category__c();
        editCategory.Scenario__c = theScenario.Id;
        editCategory.Account__c = theScenario.Account__c;         
        editCategoryId = '';
        return null;
    }
    
    public PageReference editCategory(){
        for(Staffing_Category__c sc : categories)
        {
            if(editCategoryId == sc.id)
            {
                editCategory = sc;
                return null;
            }
        }
        return null;
    }
        
    public PageReference deleteCategory(){
        for(Staffing_Category__c sc : categories)
        {
            if(deleteCategoryId == sc.id)
            {
                delete sc;
                return null;
            }
        }
        return null;
    } 

    /*Staff Level handling code here*/
    public PageReference editLevel(){
        return null;
    }
        
    public PageReference saveLedit() {      
        if(editLevelId != '')
        {
	        for(Staffing_Level__c sl : categoriesMap.get(levelCategoryId).Staffing_Levels__r)
	        {
			    if(sl.Id == editLevelId )
			    {
			    	String tempName = '';
			    	if(sl.Minimum_Gift_Value__c == null)
			    	{
			    		sl.Minimum_Gift_Value__c.addError('You must supply a lower limit for each level.');
			            return null;
			    	} else 
			    	{
			    		tempName = '$' + sl.Minimum_Gift_Value__c.format();
			    	}  	
			    	if(sl.Maximum_Gift_Value__c == null)
			    	{
			    		tempName = tempName + ' + ';
			    	} else 
			    	{
			    		tempName = tempName + ' - $' + sl.Maximum_Gift_Value__c.format();
			    	}
			    	sl.Name = tempName;
		            update sl;
		            editLevelId = '';
		            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.INFO, 'The gift level has been updated.'));
			    }
	        }
		} else 
        {
            if(addLevel.Scenario__c == null || levelCategoryId == null )
            {
                ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'There is no Scenario/Category chosen'));
                return null;
            } else
            {           
                addLevel.Staffing_Category__c = levelCategoryId;
		    	String tempName = '';
		    	if(addLevel.Minimum_Gift_Value__c == null)
		    	{
		    		addLevel.Minimum_Gift_Value__c.addError('You must supply a lower limit for each level.');
		            return null;
		    	} else 
		    	{
		    		tempName = '$' + addLevel.Minimum_Gift_Value__c.format();
		    	}  	
		    	if(addLevel.Maximum_Gift_Value__c == null)
		    	{
		    		tempName = tempName + ' + ';
		    	} else 
		    	{
		    		tempName = tempName + ' - $' + addLevel.Maximum_Gift_Value__c.format();
		    	}
		    	addLevel.Name = tempName;                
                insert addLevel;
                ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.INFO, 'The gift level has been saved.'));
            }
        } 
        levelCategoryId = '';
        addLevel = new Staffing_Level__c();
        addLevel.Scenario__c = theScenario.Id;
        addLevel.Account__c = theScenario.Account__c;
        return null; 
    }

    public PageReference setNewLevelCatId(){
        addLevel.Staffing_Category__c = levelCategoryId;
        //ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.INFO, levelCategoryId));
        return null; 
    } 

    public PageReference savecatedit(){
        String catid = ApexPages.currentPage().getParameters().get('categoryid');
        //update
        Staffing_Category__c temp = categoriesMap.get(catid); 
        update temp;
        return null;
    }
     
    public PageReference cancelLedit(){
        addLevel = new Staffing_Level__c();
        addLevel.Scenario__c = theScenario.Id;
        addLevel.Account__c = theScenario.Account__c;         
        editLevelId = '';
        levelCategoryId = '';
        return null;
    } 
            
    public PageReference deleteLevel(){
        for(Staffing_Level__c sl : categoriesMap.get(levelCategoryId).Staffing_Levels__r)
        {
		    if(sl.Id == deleteLevelId )
		    {
		        delete sl;
		        levelCategoryId = '';
		        deleteLevelId = '';
		        return null;
		    }
        }
        return null;
    } 
    
    /*Staff Position Code next */
    
    public PageReference addPosition(){
        if(levelCategoryId != '')
        {
            addPosition.Staffing_Category__c = levelCategoryId;
        } else 
        {
        	ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'The position\'s Cateogry was not detected.'));
        }
        return null;
    }
        
    public PageReference savePedit() {
        if(editPositionId != null && editPositionId != '')
        {
        	for(Staffing_Position__c sp : categoriesMap.get(levelCategoryId).Staffing_Positions__r)
        	{
            	if(editPositionId == sp.id)
            	{
            	    update sp;
   	                editPositionId = '';
		            levelCategoryId = '';
                    ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.INFO, 'The position has been updated.'));
            	    return null;
            	}
        	}
        } else 
        {
            if(addPosition.Scenario__c == null)
            {
                ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'There is no Scenario chosen'));
                return null;
            } else
            {            
                insert addPosition;
                ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.INFO, 'The position has been saved.'));
            }
        } 
        addPosition = new Staffing_Position__c();
        addPosition.Scenario__c = theScenario.Id;
        levelCategoryId = '';
        return null;
    }

    public PageReference cancelPedit(){
        addPosition = new Staffing_Position__c();
        addPosition.Scenario__c = theScenario.Id; 
        editPositionId = '';
        levelCategoryId = '';
        return null;
    }
    
    public PageReference editPosition(){
        return null;
    }

    public PageReference deletePosition(){
        for(Staffing_Position__c sp : categoriesMap.get(levelCategoryId).Staffing_Positions__r)
        {
            if(deletePositionId == sp.id)
            {
                delete sp;
                levelCategoryId = '';
                return null;
            }
        }
        return null;
    }
    
    public PageReference saveposedit(){
        String catid = ApexPages.currentPage().getParameters().get('categoryid');
        //update
        Staffing_Category__c temp = categoriesMap.get(catid); 
        String pid = ApexPages.currentPage().getParameters().get('positionid');
        for(Staffing_Position__c sp : temp.Staffing_Positions__r)
        {
            if(sp.Id == pid)
            {
                update sp;
            }
        }
        return null;
    }

    public PageReference saveedit(){      
        update theScenario;
        return null;
    } 
    
    public Boolean getminimumLevelsMet() {
    
        Boolean returnVal = true;
        if(categories.size() >0)
        {
                for(Staffing_Category__c sc: categories)
                {
                        if(sc.Staffing_Levels__r.size() < 1)
                        {
                                returnVal = false;
                        }
                }
        } else {
                returnVal = false;
        }
        return returnVal;       
    }
    
    public List<Staffing_Category__c> getcategories(){
        categories.clear();
        categoriesMap = new Map<Id,Staffing_Category__c>();
        if( [ SELECT count() FROM Staffing_Category__c WHERE Scenario__c = :theScenario.Id] != 0)
        {
            for (Staffing_Category__c sc: [SELECT Id, Name, CreatedDate, CreatedBy.Name, Total_Donors_Required__c, Total_Gifts_Equaling__c,
                        Total_Number_of_Visits_Needed__c, Total_Prospects_Required__c, Scenario__c, Threshold_Lower__c, Threshold_Upper__c, 
                        Projected_Visits_per_Year__c , Total_Visits_per_Campaign__c, Visit_Potential__c, Color__c,
                        Visit_Potential_per_Year__c, Visit_Gap__c, Visit_Gap_per_Year__c, Visits_per_Donor__c,
                        Lower_Gift_Limit__c, Number_of_FTE__c,Total_Expected_Visits_per_Year__c, Total_Actual_Visits_per_Year__c, Visit_Actual__c,
                        Visit_Actual_per_Year__c, Visit_Gap_Actual__c, Visit_Gap_Actual_per_Year__c,      
                            (Select Total_Number_of_Visits_Needed__c, Total_Gifts_Equalling__c, 
                                Staffing_Category__c, Number_of_Visits_Per_Prospect__c, 
                                Number_Of_Prospects__c, Number_Of_Donors__c, Name, Maximum_Gift_Value__c,
                                Id, Minimum_Gift_Value__c FROM Staffing_Levels__r Order by Minimum_Gift_Value__c DESC),
                            (Select Name, Percent_of_Time__c, Staffing_Category__r.Name, Number_of_FTE__c, Expected_Visits_per_Year__c,
                                Additional_FTE_Needed__c, Additional_FTE_Needed_Actual__c, Actual_Visits_per_Year__c 
                                From Staffing_Positions__r)  
                         FROM Staffing_Category__c WHERE Scenario__c = :theScenario.Id 
                         ORDER BY Threshold_Lower__c DESC])
            {
                categories.add(sc);
                categoriesMap.put(sc.Id,sc);
            }
        } else {
            categories = new List<Staffing_Category__c>();
        }
        return categories; 
    } 
           
    public List<Staffing_Position__c> getpositions(){
        if( [ SELECT count() FROM Staffing_Position__c WHERE Scenario__c = :theScenario.Id] != 0)
        {
            positions = [ SELECT Id, Name, Expected_Visits_per_Year__c, Number_of_FTE__c, Percent_of_Time__c, Staffing_Category__c
                              FROM Staffing_Position__c WHERE Scenario__c = :theScenario.Id ORDER BY Name];
        } else {
            positions = new List<Staffing_Position__c>();
        }
        return positions; 
    } 
}