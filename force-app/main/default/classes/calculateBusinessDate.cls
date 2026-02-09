public class calculateBusinessDate {
    public static Date addBusinessDays(Date baseDate, Integer businessDays) {
        if (baseDate == null) {
            baseDate = System.today(); // Use today's date as a fallback
        }
        
        Date currentDate = baseDate;
        Integer addedDays = 0;

        while (addedDays < businessDays) {
            currentDate = currentDate.addDays(1);
            // Skip weekends: check if the day is Saturday (6) or Sunday (0)
            if (currentDate.toStartOfWeek().addDays(6) != currentDate && currentDate.toStartOfWeek() != currentDate) {
                addedDays++;
            }
        }
        return currentDate;
    }
}