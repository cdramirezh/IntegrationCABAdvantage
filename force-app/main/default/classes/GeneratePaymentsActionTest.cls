@isTest
private class GeneratePaymentsActionTest {


@IsTest
    static void testCreatePayments() {
        // Create test data
        Financing__c financing = new Financing__c(
            Down_Payment__c = 5000,
            Installments__c = 24,
            Principal_Amount__c = 10000,
            Start_Date__c = Date.today()
        );
        insert financing;

        // Call the createPayments method
        List<Id> financingIds = new List<Id>{financing.Id};
        GeneratePaymentsAction.createPayments(financingIds);

        // Verify that Payment__c records were created
        List<Payment__c> payments = [SELECT Id, Amount__c, Due_Date__c FROM Payment__c WHERE Financing__c = :financing.Id];
        System.assertEquals(24, payments.size(), 'Incorrect number of Payment__c records created');

        // Verify payment amount and due date
        Decimal expectedAmount = (financing.Principal_Amount__c - financing.Down_Payment__c) / financing.Installments__c;
        Date expectedDueDate = financing.Start_Date__c != null ? financing.Start_Date__c : Date.today();
        for (Payment__c payment : payments) {
            System.assertEquals(expectedAmount, payment.Amount__c, 'Incorrect Payment__c.Amount__c');
            System.assertEquals(expectedDueDate, payment.Due_Date__c, 'Incorrect Payment__c.Due_Date__c');
            expectedDueDate = expectedDueDate.addMonths(1);
        }
    }
}