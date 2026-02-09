public class GuidelinePDFController {
    public List<Guideline__c> guidelines { get; set; }
    
    public GuidelinePDFController() {
        guidelines = [
            SELECT Name, Market__c, MGA_Company_T__c, Insurance_Company_T__c, Business_Tenure__c, 
                   Available_States__c, Type_of_Units__c, Unit_Age__c, Commodities__c,
                   CDL_Experience__c, Driver_Age__c, Amount_of_units__c, Radius__c,
                   CAB_Score__c, IFTAS_required__c, International_Drivers__c, 
                   Team_Driving__c, Documents_Required__c, Online_System__c, BOR__c,
                   ELD_required__c
            FROM Guideline__c
            ORDER BY MGA_Company_T__c, Insurance_Company_T__c
        ];
    }
}