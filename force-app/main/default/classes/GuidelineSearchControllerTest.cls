@isTest
private class GuidelineSearchControllerTest {


@IsTest
    static void testGuidelineSearchController() {
        // Instantiate the controller
        GuidelineSearchController controller = new GuidelineSearchController();

        // Set the properties
        controller.selectedMarket = 'GL';
        controller.selectedState = 'FL';
        // ... set other properties as needed
        
        // Call the searchGuidelines method
        Test.startTest();
        controller.searchGuidelines();
        Test.stopTest();

        // Verify that the options are populated
        System.assertNotEquals(null, controller.mgaOptions, 'MGA Options should not be null');
        System.assertNotEquals(null, controller.insuranceOptions, 'Insurance Options should not be null');
        System.assertNotEquals(null, controller.marketOptions, 'Market Options should not be null');
        System.assertNotEquals(null, controller.stateOptions, 'State Options should not be null');
        System.assertNotEquals(null, controller.unitOptions, 'Unit Options should not be null');
        System.assertNotEquals(null, controller.ageOptions, 'Age Options should not be null');
        System.assertNotEquals(null, controller.commoditiesOptions, 'Commodities Options should not be null');
        System.assertNotEquals(null, controller.cdlOptions, 'CDL Options should not be null');
        System.assertNotEquals(null, controller.InternationalDriverOptions, 'International Driver Options should not be null');
        System.assertNotEquals(null, controller.businessOptions, 'Business Options should not be null');
    }
}