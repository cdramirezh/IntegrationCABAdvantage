public with sharing class GeneratePaymentsAction {
    @InvocableMethod(label='Generate Payments' description='Creates Payment__c records based on Financing__c')
    public static void createPayments(List<Id> financingIds) {
        List<Payment__c> paymentsToInsert = new List<Payment__c>();
        Date today = Date.today();

        // Fetch the Financing__c records
        List<Financing__c> financingRecords = [
            SELECT Id, Down_Payment__c, Installments__c, Principal_Amount__c, Start_Date__c
            FROM Financing__c 
            WHERE Id IN :financingIds
        ];
        
        // Delete existing Payment__c records related to the Financing__c records
        List<Payment__c> existingPayments = [
            SELECT Id FROM Payment__c WHERE Financing__c IN :financingIds
        ];
        if (!existingPayments.isEmpty()) {
            delete existingPayments;
        }

        for (Financing__c financing : financingRecords) {
            if (financing.Down_Payment__c == null || financing.Installments__c == null || financing.Principal_Amount__c == null) {
                continue; // Skip processing if required fields are missing
            }
            
            // Calculate Monthly Payment
            Decimal monthlyPayment = (financing.Principal_Amount__c - financing.Down_Payment__c) / financing.Installments__c;
            Date dueDate = financing.Start_Date__c != null ? financing.Start_Date__c : today;
            
            for (Integer i = 0; i < financing.Installments__c; i++) {
                Payment__c payment = new Payment__c(
                    Financing__c = financing.Id,
                    Amount__c = monthlyPayment,
                    Status__c = 'Pending',
                    Type__c = 'Monthly Payment',
                    Due_Date__c = dueDate
                );
                paymentsToInsert.add(payment);
                
                // Increment due date by one month
                dueDate = dueDate.addMonths(1);
            }
        }
        
        // Insert payments
        if (!paymentsToInsert.isEmpty()) {
            insert paymentsToInsert;
        }
    }
}