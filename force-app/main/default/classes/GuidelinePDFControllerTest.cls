@IsTest
public class GuidelinePDFControllerTest {
    @IsTest
    static void testGuidelinePDFController() {
        // Create test data
        Guideline__c guideline = new Guideline__c(
            //Name = 'Test Guideline',
            MGA_Company_T__c = 'Test MGA Company',
            Insurance_Company_T__c = 'Test Insurance Company',
            Business_Tenure__c = '1 year',
            Available_States__c = 'CA;NY',
            Type_of_Units__c = 'Truck',
            Unit_Age__c = 'New',
            Commodities__c = 'Electronics',
            CDL_Experience__c = 'Yes',
            Driver_Age__c = '25',
            Amount_of_units__c = '1',
            Radius__c = '100',
            CAB_Score__c = 'Good',
            IFTAS_required__c = 'Yes',
            International_Drivers__c = 'No',
            Team_Driving__c = 'No',
            Documents_Required__c = 'Yes',
            Online_System__c = 'Yes',
            BOR__c = 'Yes',
            ELD_required__c = 'Yes'
        );
        insert guideline;

        // Instantiate the controller
        GuidelinePDFController controller = new GuidelinePDFController();

        // Verify that the guidelines list is populated
        System.assertEquals(1, controller.guidelines.size());
    }
}