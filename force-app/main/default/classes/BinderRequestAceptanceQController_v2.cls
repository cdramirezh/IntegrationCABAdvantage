public with sharing class BinderRequestAceptanceQController_v2 {
    private final Binder_Request__c binderRequest;
    public Binder_Request__c bindrecord { get; private set; }
    public RelatedRecordDataWrapper relatedRecordData { get; private set; }
    //public Policy__c firstpolicy { get; private set; }
    public Date Today { get { return Date.today(); }}
    //public List<Coverage__c> pdcoverages { get; private set; }
    public List<AR_Coverage__c> pdcoverages { get; private set; }
    public String coverageAbbreviationsString { get; private set; }
    public String bindname { get; private set; }
    public Integer pdcoveragessize { get; private set; }
    public Integer abbreviationListsize { get; private set; }


    public BinderRequestAceptanceQController_v2(ApexPages.StandardController controller) {
        this.binderRequest = (Binder_Request__c) controller.getRecord();

        Binder_Request__c bindrecord = [SELECT Id, Name, Policy_Draft__c FROM Binder_Request__c WHERE Id = :binderRequest.Id LIMIT 1];

        Policy_Draft__c pd = [SELECT Id, Lead__c, Power_Units__c, Opportunity__c, 
                                    Financing__c, Financing__r.Down_Payment__c, Financing__r.Monthly_Payment__c, 
                                    Lead__r.USDOT__c, Lead__r.Company, Lead__r.DBA__c, Lead__r.Company_Rep__c, Lead__r.Owner_DOB__c,
                                    Lead__r.Years_in_Business__c, Lead__r.Power_Units__c, Lead__r.Phone, Lead__r.Email, 
                                    Lead__r.Radius__c, Lead__r.Parking_Street__c, Lead__r.Parking_City__c, Lead__r.Parking_State__c, 
                                    Lead__r.Parking_ZIP__c, Lead__r.Mailing_Street__c, Lead__r.Mailing_City__c, 
                                    Lead__r.Mailing_State__c, Lead__r.Mailing_ZIP__c,
                                    Lead__r.Federal_Filing__c, Lead__r.State_Filing__c, Lead__r.UIIA__c, Lead__r.SCAD_Code__c,
                                    Opportunity__r.USDOT__c, Opportunity__r.AccountId, Opportunity__r.Account.Name, Opportunity__r.Account.DBA__c, Opportunity__r.Account.Company_Rep__c, Opportunity__r.Account.Owner_DOB__c,
                                    Opportunity__r.Years_in_Business__c, 
                                    Opportunity__r.Radius__c, Opportunity__r.Account.Parking_Street__c, Opportunity__r.Account.Parking_City__c, Opportunity__r.Account.Parking_State__c, 
                                    Opportunity__r.Account.Parking_ZIP__c, Opportunity__r.Account.Mailing_Street__c, Opportunity__r.Account.Mailing_City__c, 
                                    Opportunity__r.Account.Mailing_State__c, Opportunity__r.Account.Mailing_ZIP__c, 
                                    Opportunity__r.Account.Federal_Filing_MC__c, Opportunity__r.Account.State_Filing__c, Opportunity__r.Account.UIIA__c, Opportunity__r.Account.SCAD_Code__c
                                FROM Policy_Draft__c
                                WHERE Id = :bindrecord.Policy_Draft__c];

        if (pd != null) {
            relatedRecordData = fetchRelatedRecordData(pd);
        }       

        bindname = bindrecord.Name;      
        /*  
        pdcoverages = new List<Coverage__c>();
        pdcoverages = [SELECT Id, Name, Policy_Draft__c, Coverage_Product__r.Name,  Coverage_Product__r.Abbreviation__c
            FROM Coverage__c
            WHERE Policy_Draft__c = :pd.Id
            ORDER BY Coverage_Product__r.Name ASC];

        pdcoveragessize = pdcoverages.size();
        */

        pdcoverages = new List<AR_Coverage__c>();

        pdcoverages = [SELECT Id, Name, Coverage_Product__r.Name,  Coverage_Product__r.Abbreviation__c
            FROM AR_Coverage__c
            WHERE Binder_Request__c = :bindrecord.Id
            ORDER BY Coverage_Product__r.Name ASC];
        
        Set<String> uniqueAbbreviations = new Set<String>();

        //for (Coverage__c cov : pdcoverages) {
        for (AR_Coverage__c cov : pdcoverages) {
            if (cov.Coverage_Product__r != null && cov.Coverage_Product__r.Abbreviation__c != null) {
                uniqueAbbreviations.add(cov.Coverage_Product__r.Abbreviation__c);
            }           
        }

        // Convert the Set to a List
        List<String> abbreviationList = new List<String>(uniqueAbbreviations);
        abbreviationListsize = abbreviationList.size();

        // Manually join the abbreviations with '+'
        coverageAbbreviationsString = String.join(new List<String>(abbreviationList), '+');

    }
    

    public class RelatedRecordDataWrapper {
        public String USDOT { get; set; }
        public String Company { get; set; }
        public String DBA { get; set; }
        public String CompanyRep { get; set; }
        public Date OwnerDOB { get; set; }
        public Decimal YearsInBusiness { get; set; }
        public Decimal PowerUnits { get; set; }
        public String Phone { get; set; }
        public String Email { get; set; }
        public String Radius { get; set; }
        public String ParkingStreet { get; set; }
        public String ParkingCity { get; set; }
        public String ParkingState { get; set; }
        public String ParkingZIP { get; set; }
        public String MailingStreet { get; set; }
        public String MailingCity { get; set; }
        public String MailingState { get; set; }
        public String MailingZIP { get; set; }
        public String FederalFiling { get; set; }
        public String StateFiling { get; set; }
        public Boolean UIIA { get; set; }
        public String SCADcode { get; set; }

        public RelatedRecordDataWrapper(String USDOT, String Company, String DBA, String CompanyRep, Date OwnerDOB, Decimal YearsInBusiness, Decimal PowerUnits, String Phone, String Email, String Radius, String ParkingStreet, String ParkingCity, String ParkingState, String ParkingZIP, String MailingStreet, String MailingCity, String MailingState, String MailingZIP, String FederalFiling, String StateFiling, Boolean UIIA, String SCADcode) {
            this.USDOT = USDOT;
            this.Company = Company;
            this.DBA = DBA;
            this.CompanyRep = CompanyRep;
            this.OwnerDOB = OwnerDOB;
            this.YearsInBusiness = YearsInBusiness;
            this.PowerUnits = PowerUnits;
            this.Phone = Phone;
            this.Email = Email;
            this.Radius = Radius;
            this.ParkingStreet = ParkingStreet;
            this.ParkingCity = ParkingCity;
            this.ParkingState = ParkingState;
            this.ParkingZIP = ParkingZIP;
            this.MailingStreet = MailingStreet;
            this.MailingCity = MailingCity;
            this.MailingState = MailingState;
            this.MailingZIP = MailingZIP;
            this.FederalFiling = FederalFiling;
            this.StateFiling = StateFiling;
            this.UIIA = UIIA;
            this.SCADcode = SCADcode;
        }
    }


    private relatedRecordDataWrapper fetchRelatedRecordData(Policy_Draft__c pd) {
        Contact firstOppContact = null;
        if (pd.Opportunity__c != null) {
            firstOppContact = [
                SELECT Id, Name, Phone, Email
                FROM Contact
                WHERE AccountId = :pd.Opportunity__r.AccountId
                LIMIT 1
            ];
        }
    
        if (pd.Opportunity__r != null && pd.Opportunity__r.Account != null) {
            return new RelatedRecordDataWrapper(
                pd.Opportunity__r.USDOT__c,
                pd.Opportunity__r.Account.Name,
                pd.Opportunity__r.Account.DBA__c,
                pd.Opportunity__r.Account.Company_Rep__c,
                pd.Opportunity__r.Account.Owner_DOB__c,
                pd.Opportunity__r.Years_in_Business__c,
                pd.Power_Units__c,
                firstOppContact != null ? firstOppContact.Phone : null,
                firstOppContact != null ? firstOppContact.Email : null,
                pd.Opportunity__r.Radius__c,
                pd.Opportunity__r.Account.Parking_Street__c,
                pd.Opportunity__r.Account.Parking_City__c,
                pd.Opportunity__r.Account.Parking_State__c,
                pd.Opportunity__r.Account.Parking_ZIP__c,
                pd.Opportunity__r.Account.Mailing_Street__c,
                pd.Opportunity__r.Account.Mailing_City__c,
                pd.Opportunity__r.Account.Mailing_State__c,
                pd.Opportunity__r.Account.Mailing_ZIP__c,
                pd.Opportunity__r.Account.Federal_Filing_MC__c,
                pd.Opportunity__r.Account.State_Filing__c,
                pd.Opportunity__r.Account.UIIA__c,
                pd.Opportunity__r.Account.SCAD_Code__c
            );
        } else if (pd.Lead__r != null) {
            return new RelatedRecordDataWrapper(
                pd.Lead__r.USDOT__c,
                pd.Lead__r.Company,
                pd.Lead__r.DBA__c,
                pd.Lead__r.Company_Rep__c,
                pd.Lead__r.Owner_DOB__c,
                pd.Lead__r.Years_in_Business__c,
                pd.Lead__r.Power_Units__c,
                pd.Lead__r.Phone,
                pd.Lead__r.Email,
                pd.Lead__r.Radius__c,
                pd.Lead__r.Parking_Street__c,
                pd.Lead__r.Parking_City__c,
                pd.Lead__r.Parking_State__c,
                pd.Lead__r.Parking_ZIP__c,
                pd.Lead__r.Mailing_Street__c,
                pd.Lead__r.Mailing_City__c,
                pd.Lead__r.Mailing_State__c,
                pd.Lead__r.Mailing_ZIP__c,
                pd.Lead__r.Federal_Filing__c,
                pd.Lead__r.State_Filing__c,
                pd.Lead__r.UIIA__c,
                pd.Lead__r.SCAD_Code__c
            );
        } else {
            return new RelatedRecordDataWrapper(null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null);
        }
    }

}