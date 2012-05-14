trigger StaffingCategoryProcedures on Staffing_Category__c (before insert, before update) {

	for(Staffing_Category__c sc : Trigger.new)
	{
		if(sc.Color__c == null || sc.Color__c.length() != 7)
		{
			sc.Color__c = AjUtil.generateHex(true);
		} 
	}
}