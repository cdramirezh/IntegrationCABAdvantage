@isTest
public class CalculateBusinessDateTest {
    @isTest
    static void testAddBusinessDays() {
        // Test Case 1: Adding 5 business days from a Monday
        Date baseDate = Date.newInstance(2024, 12, 23); // Monday
        Integer businessDays = 5;
        Date expectedDate = Date.newInstance(2024, 12, 30); // Next Monday (skips the weekend)
        Date actualDate = calculateBusinessDate.addBusinessDays(baseDate, businessDays);
        System.assertEquals(expectedDate, actualDate, 'Adding 5 business days from Monday should skip the weekend.');

        // Test Case 2: Adding 1 business day from a Friday
        baseDate = Date.newInstance(2024, 12, 27); // Friday
        businessDays = 1;
        expectedDate = Date.newInstance(2024, 12, 30); // Next Monday
        actualDate = calculateBusinessDate.addBusinessDays(baseDate, businessDays);
        System.assertEquals(expectedDate, actualDate, 'Adding 1 business day from Friday should land on Monday.');

        // Test Case 3: Adding 10 business days from a Wednesday
        baseDate = Date.newInstance(2024, 12, 18); // Wednesday
        businessDays = 10;
        expectedDate = Date.newInstance(2025, 1, 1); // Skips two weekends
        actualDate = calculateBusinessDate.addBusinessDays(baseDate, businessDays);
        System.assertEquals(expectedDate, actualDate, 'Adding 10 business days from Wednesday should skip two weekends.');

        // Test Case 4: Adding 0 business days
        baseDate = Date.newInstance(2024, 12, 21); // Saturday
        businessDays = 0;
        expectedDate = baseDate; // No change
        actualDate = calculateBusinessDate.addBusinessDays(baseDate, businessDays);
        System.assertEquals(expectedDate, actualDate, 'Adding 0 business days should return the same date.');

        // Test Case 5: Null base date (fallback to System.today)
        Test.startTest();
        Date systemToday = System.today(); // Capture today's date
        businessDays = 3;
        actualDate = calculateBusinessDate.addBusinessDays(null, businessDays);
        Date expectedSystemDate = systemToday.addDays(3);
        System.assertNotEquals(systemToday, actualDate, 'Adding 3 business days from today should result in a different date.');
        Test.stopTest();
    }
}