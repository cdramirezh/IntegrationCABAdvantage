public class PolicyDraftPDFController_v5 {
    public Policy_Draft__c policyDraft { get; private set; }
    //public Map<String, Object> relatedRecordData { get; private set; }
    public RelatedRecordDataWrapper relatedRecordData { get; private set; }
    public List<Vehicle__c> vehicles { get; private set; }
    public List<Trailer__c> trailers { get; private set; }
    public List<Driver__c> drivers { get; private set; }
    public List<Commodity__c> commodities { get; private set; }
    public List<Policy_Commodity__c> policycommodities { get; private set; }
    public List<Coverage__c> coverages { get; private set; }
    public List<Policy_Vehicle__c> policyVehicles { get; private set; }
    public List<Policy_Trailer__c> policyTrailers { get; private set; }
    public List<Policy_Driver__c> policyDrivers { get; private set; }
    public Map<String, Object> recordData { get; private set; }
    public String relatedRecordName { get; private set; }
    public Contact firstOppContact { get; private set; }    
    public Decimal TotalPremium { get; set; }

    public PolicyDraftPDFController_v5(ApexPages.StandardController standardController) {
        this.policyDraft = (Policy_Draft__c) standardController.getRecord();

        Policy_Draft__c pd = [
            SELECT Id, Lead__c, Power_Units__c, Opportunity__c, DOT_Owner_Driver__c, DOT_Owner_Driver__r.Name, DOT_Owner_Driver__r.NON_CDL__c, DOT_Owner_Driver__r.CDL__c,
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
            WHERE Id = :policyDraft.Id
            LIMIT 1
        ];

        

        if (policyDraft != null) {
            // Fetch related records for the Lead linked to the Policy_Draft__c record
            relatedRecordData = fetchRelatedRecordData(pd);
            fetchPolicyDrivers();
            fetchPolicyVehicles();
            fetchPolicyTrailers();
            commodities = fetchCommodities(pd);
            policycommodities = fetchPolicyCommodities(pd);
            //fetchCoverages();
            coverages = fetchCoverages();
            TotalPremium = getTotalPremium(coverages);
        }       

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

    /*
    private relatedRecordDataWrapper fetchRelatedRecordData(Policy_Draft__c pd) {
       
        if (pd.Opportunity__c != null) {
        Contact firstOppContact = [
            SELECT Id, Name, Phone, Email
            FROM Contact
            WHERE AccountId = :pd.Opportunity__r.AccountId
            LIMIT 1
        ];  
        }      

        if (pd.Opportunity__c != null) {
        return new RelatedRecordDataWrapper(
            pd.Opportunity__r.USDOT__c, pd.Opportunity__r.Account.Name, pd.Opportunity__r.Account.DBA__c, pd.Opportunity__r.Account.Company_Rep__c, pd.Opportunity__r.Account.Owner_DOB__c, pd.Opportunity__r.Years_in_Business__c,
            pd.Power_Units__c, firstOppContact.Phone, firstOppContact.Email, pd.Opportunity__r.Radius__c, 
            pd.Opportunity__r.Account.Parking_Street__c, pd.Opportunity__r.Account.Parking_City__c, pd.Opportunity__r.Account.Parking_State__c, pd.Opportunity__r.Account.Parking_ZIP__c, 
            pd.Opportunity__r.Account.Mailing_Street__c, pd.Opportunity__r.Account.Mailing_City__c, pd.Opportunity__r.Account.Mailing_State__c, 
            pd.Opportunity__r.Account.Mailing_ZIP__c, pd.Opportunity__r.Account.Federal_Filing_MC__c, pd.Opportunity__r.Account.State_Filing__c, pd.Opportunity__r.Account.UIIA__c, pd.Opportunity__r.Account.SCAD_Code__c);
        } else if (pd.Lead__c != null) {
            return new RelatedRecordDataWrapper(
            pd.Lead__r.USDOT__c, pd.Lead__r.Company, pd.Lead__r.DBA__c, pd.Lead__r.Company_Rep__c, pd.Lead__r.Owner_DOB__c, pd.Lead__r.Years_in_Business__c,
            pd.Lead__r.Power_Units__c, pd.Lead__r.Phone, pd.Lead__r.Email, pd.Lead__r.Radius__c, 
            pd.Lead__r.Parking_Street__c, pd.Lead__r.Parking_City__c, pd.Lead__r.Parking_State__c, pd.Lead__r.Parking_ZIP__c, 
            pd.Lead__r.Mailing_Street__c, pd.Lead__r.Mailing_City__c, pd.Lead__r.Mailing_State__c, 
            pd.Lead__r.Mailing_ZIP__c, pd.Lead__r.Federal_Filing__c, pd.Lead__r.State_Filing__c, pd.Lead__r.UIIA__c, pd.Lead__r.SCAD_Code__c);
        } else {
            return new RelatedRecordDataWrapper(
            null, null, null, null, null, null, null, null,null, null, null, null, null, null, null, null, null, null, null, null, null, null);
        }
    }
        */

        private relatedRecordDataWrapper fetchRelatedRecordData(Policy_Draft__c pd) {
            Contact firstOppContact = null;
            /*
            if (pd.Opportunity__c != null) {
                firstOppContact = [
                    SELECT Id, Name, Phone, Email
                    FROM Contact
                    WHERE AccountId = :pd.Opportunity__r.AccountId
                    LIMIT 1
                ];
            }
                */

            List<Contact> contactList = [
                SELECT Id, Name, Phone, Email
                FROM Contact
                WHERE AccountId = :pd.Opportunity__r.AccountId
                LIMIT 1
            ];
            if (!contactList.isEmpty()) {
                firstOppContact = contactList[0];
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
        
    

    //private void fetchCoverages() {
    public List<Coverage__c> fetchCoverages() {
        coverages = [
            SELECT Id, Name, Policy_Draft__c, Limit__c, Deductible__c, 	Premium__c, Coverage_Product__c, Coverage_Product__r.Name
            FROM Coverage__c
            WHERE Policy_Draft__c = :policyDraft.Id
        ];
        return coverages;
    }

    // Method to sum up all Premium__c values
    public Decimal getTotalPremium(List<Coverage__c> coverages) {
        Decimal totalPremium = 0;
        if (coverages != null && !coverages.isEmpty()) {
            for (Coverage__c coverage : coverages) {
                if (coverage.Premium__c != null) {
                    totalPremium += coverage.Premium__c;
                }
            }
        }
        return totalPremium;
    }

    private void fetchPolicyDrivers() {
        // Query policy drivers
        policyDrivers = [
            SELECT Id, Driver__c, Status__c, Driver__r.Id, Driver__r.Name, Driver__r.CDL__c, Driver__r.NON_CDL__c, Driver__r.DOB__c, Driver__r.State__c, Driver__r.Hiring_Date__c, Driver__r.Experience__c
            FROM Policy_Driver__c
            WHERE Policy_Draft__c = :policyDraft.Id
        ];
    }

    //private void fetchPolicyVehicles() {
    public void fetchPolicyVehicles() {
        // Query policy vehicles
        policyVehicles = [
            SELECT Id, Vehicle__c, Status__c, Vehicle__r.Id, Vehicle__r.Name, Vehicle__r.Make__c, Vehicle__r.Make__r.Name, Vehicle__r.Type__c, Vehicle__r.Year__c, Vehicle__r.Value__c, Vehicle__r.Weight__c
            FROM Policy_Vehicle__c
            WHERE Policy_Draft__c = :policyDraft.Id
        ];
    }

    private void fetchPolicyTrailers() {
        // Query policy trailers
        policyTrailers = [
            SELECT Id, Trailer__c, Status__c, Trailer__r.Id, Trailer__r.Name, Trailer__r.Make__c, Trailer__r.Make__r.Name, Trailer__r.Type__c, Trailer__r.Year__c, Trailer__r.Value__c, Trailer__r.Weight__c
            FROM Policy_Trailer__c
            WHERE Policy_Draft__c = :policyDraft.Id
        ];
    }  
    
    private List<Commodity__c> fetchCommodities(Policy_Draft__c pd) {
        if (pd.Opportunity__c != null) {
            return [
                SELECT Id, Name, Percent__c
                FROM Commodity__c
                WHERE Account__c = :pd.Opportunity__r.Account.Id
            ];
        } else if (pd.Lead__c != null) {
            return [
                SELECT Id, Name, Percent__c
                FROM Commodity__c
                WHERE Lead__c = :pd.Lead__r.Id
            ];
        }
        return new List<Commodity__c>();
    }

    private List<Policy_Commodity__c> fetchPolicyCommodities(Policy_Draft__c pd) {
        /*
        if (pd.Opportunity__c != null) {
            return [
                SELECT Id, Name, Percent__c
                FROM Commodity__c
                WHERE Account__c = :pd.Opportunity__r.Account.Id
            ];
        } else if (pd.Lead__c != null) {
            return [
                SELECT Id, Name, Percent__c
                FROM Commodity__c
                WHERE Lead__c = :pd.Lead__r.Id
            ];
        }
        return new List<Commodity__c>();
    }*/
    if (pd != null && pd.Id != null) {
        return [
            SELECT Id, Name, Percent__c
            FROM Policy_Commodity__c
            WHERE Policy_Draft__c = :pd.Id
        ];
        } 
        else {
        return new List<Policy_Commodity__c>();
    }
    }



}