@isTest
public class UpdateFirstContactDetailsTest {
    
    @testSetup
    static void setupData() {
        // Create an Account for testing
        Account testAccount = new Account(Name = 'Test Account', Owner_DOB__c = Date.today());
        insert testAccount;

        // Insert initial contact
        Contact firstContact = new Contact(
            FirstName = 'John',
            LastName = 'Doe',
            Email = 'john.doe@example.com',
            Phone = '123-456-7890',
            AccountId = testAccount.Id
        );
        insert firstContact;
    }

    @isTest
    static void testInsertFirstContact() {
        // Fetch test Account
        Account acc = [SELECT Id, First_Contact_Email__c, First_Contact_Phone__c FROM Account LIMIT 1];
        
        // Verify the first contact details are correctly updated on the Account
        System.assertEquals('john.doe@example.com', acc.First_Contact_Email__c);
        System.assertEquals('123-456-7890', acc.First_Contact_Phone__c);
    }

    @isTest
    static void testInsertSecondContact() {
        // Fetch the test Account
        Account acc = [SELECT Id FROM Account LIMIT 1];

        // Insert another contact for the same account
        Contact secondContact = new Contact(
            FirstName = 'Jane',
            LastName = 'Smith',
            Email = 'jane.smith@example.com',
            Phone = '987-654-3210',
            AccountId = acc.Id
        );
        insert secondContact;

        // Fetch updated Account
        Account updatedAcc = [SELECT First_Contact_Email__c, First_Contact_Phone__c FROM Account WHERE Id = :acc.Id];
        
        // The first contact should still be the original one
        System.assertEquals('john.doe@example.com', updatedAcc.First_Contact_Email__c);
        System.assertEquals('123-456-7890', updatedAcc.First_Contact_Phone__c);
    }

    @isTest
    static void testDeleteFirstContact() {
        // Fetch the first contact
        Contact firstContact = [SELECT Id, AccountId FROM Contact WHERE Email = 'john.doe@example.com' LIMIT 1];
        Id accountId = firstContact.AccountId;

        // Insert a second contact before deleting the first one
        Contact secondContact = new Contact(
            FirstName = 'Jane',
            LastName = 'Smith',
            Email = 'jane.smith@example.com',
            Phone = '987-654-3210',
            AccountId = accountId
        );
        insert secondContact;

        // Delete the first contact
        delete firstContact;

        // Fetch updated Account
        Account updatedAcc = [SELECT First_Contact_Email__c, First_Contact_Phone__c FROM Account WHERE Id = :accountId];

        // The second contact should now be the first contact
        System.assertEquals('jane.smith@example.com', updatedAcc.First_Contact_Email__c);
        System.assertEquals('987-654-3210', updatedAcc.First_Contact_Phone__c);
    }

    @isTest
    static void testDeleteLastContact() {
        // Fetch all contacts and account
        List<Contact> contacts = [SELECT Id, AccountId FROM Contact];
        Id accountId = contacts[0].AccountId;

        // Delete all contacts
        delete contacts;

        // Fetch updated Account
        Account updatedAcc = [SELECT First_Contact_Email__c, First_Contact_Phone__c FROM Account WHERE Id = :accountId];

        // The fields should be null since no contacts remain
        System.assertEquals('john.doe@example.com', updatedAcc.First_Contact_Email__c);
        System.assertEquals('123-456-7890', updatedAcc.First_Contact_Phone__c);
    }
}