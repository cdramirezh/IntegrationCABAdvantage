trigger Contact_Task_DueDate_Calc on Contact_Task__c (before insert, before update) {
    for (Contact_Task__c task : Trigger.new) {
        if (task.Type__c != null) {
            Integer businessDaysToAdd;

            // Determine the number of business days to add based on Type__c
            switch on task.Type__c {
                when 'Call' {
                    businessDaysToAdd = 2;
                }
                when 'Requesting information' {
                    businessDaysToAdd = 3;
                }
                when 'Prospect New Venture' {
                    businessDaysToAdd = 6;
                }
                when 'Positive' {
                    businessDaysToAdd = 6;
                }
                when 'Follow up' {
                    businessDaysToAdd = 6;
                }
                when 'Prospect Renewal' {
                    businessDaysToAdd = 6;
                }
                when 'Follow up Renewal' {
                    businessDaysToAdd = 6;
                }
                when else {
                    businessDaysToAdd = 0; // Default to 0 if no match
                }
            }

            // Use System.today() for BeforeInsert and extract Date portion from CreatedDate otherwise
            Date baseDate = (Trigger.isInsert && Trigger.isBefore) 
                            ? System.today() 
                            : task.CreatedDate.date(); // Convert Datetime to Date

            task.Due_Date__c = calculateBusinessDate.addBusinessDays(baseDate, businessDaysToAdd);
        
        
        }
    }
}