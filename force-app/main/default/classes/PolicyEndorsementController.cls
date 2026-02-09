public with sharing class PolicyEndorsementController {

    @AuraEnabled(cacheable=true)
    public static List<EndorsementWrapper> getEndorsementHistory(Id policyId) {
        List<EndorsementWrapper> endorsementList = new List<EndorsementWrapper>();

        try {
            // Get Policy Vehicle records
            List<Policy_Vehicle__c> policyVehicles = [
                SELECT Id, CreatedDate, 
                Vehicle__r.Name, Vehicle__r.Make__r.Name, Vehicle__r.Year__c, Vehicle__r.Value__c, Vehicle__r.Weight__c,
                Policy__r.CreatedDate, Policy__r.Effective_Date__c
                FROM Policy_Vehicle__c
                WHERE Policy__c = :policyId AND Status__c = 'Active'
            ];

            // Get Policy Trailer records
            List<Policy_Trailer__c> policyTrailers = [
                SELECT Id, CreatedDate, 
                Trailer__r.Name, Trailer__r.Make__r.Name, Trailer__r.Year__c, Trailer__r.Value__c, Trailer__r.Weight__c,
                Policy__r.CreatedDate, Policy__r.Effective_Date__c
                FROM Policy_Trailer__c
                WHERE Policy__c = :policyId AND Status__c = 'Active'
            ];

            // Get Policy Driver records
            List<Policy_Driver__c> policyDrivers = [
                SELECT Id, CreatedDate, 
                Driver__r.CDL__c, Driver__r.Name,
                Policy__r.CreatedDate, Policy__r.Effective_Date__c
                FROM Policy_Driver__c
                WHERE Policy__c = :policyId AND Status__c = 'Active'
            ];

            for (Policy_Vehicle__c pv : policyVehicles) {
                endorsementList.add(new EndorsementWrapper(
                    pv.Id,
                    'From Policy Sale',
                    pv.Policy__r.Effective_Date__c,
                    'Vehicle',
                    pv.Vehicle__r.Name,
                    pv.Vehicle__r.Make__r.Name,
                    pv.Vehicle__r.Year__c,
                    pv.Vehicle__r.Value__c,
                    pv.Vehicle__r.Weight__c,
                    '',
                    'Add'
                ));
            }

            for (Policy_Trailer__c pt : policyTrailers) {
                endorsementList.add(new EndorsementWrapper(
                    pt.Id,
                    'From Policy Sale',
                    pt.Policy__r.Effective_Date__c,
                    'Trailer',
                    pt.Trailer__r.Name,
                    pt.Trailer__r.Make__r.Name,
                    pt.Trailer__r.Year__c,
                    pt.Trailer__r.Value__c,
                    pt.Trailer__r.Weight__c,
                    '',
                    'Add'
                ));
            }

            for (Policy_Driver__c pd : policyDrivers) {
                endorsementList.add(new EndorsementWrapper(
                    pd.Id,
                    'From Policy Sale',
                    pd.Policy__r.Effective_Date__c,
                    'Driver',
                    pd.Driver__r.CDL__c,
                    '',
                    null,
                    0,
                    0,
                    pd.Driver__r.Name,
                    'Add'
                ));
            }

            // Endorsement records
            List<Endorsement_Request__c> endorsementRequests = [
                SELECT Id, Name, CreatedDate, Effective_Date__c,
                    (SELECT Id, Vehicle__r.Name, New_VIN__c, Vehicle__r.Make__r.Name, Vehicle__r.Year__c, New_Year__c, Vehicle__r.Value__c, New_Value__c, Vehicle__r.Weight__c, New_Weight__c, Action__c 
                     FROM Endorsement_Vehicles__r),
                    (SELECT Id, Trailer__r.Name, New_VIN__c, Trailer__r.Make__r.Name, Trailer__r.Year__c, New_Year__c, Trailer__r.Value__c, New_Value__c, Trailer__r.Weight__c, New_Weight__c, Action__c
                     FROM Endorsement_Trailers__r),
                    (SELECT Id, Driver__r.CDL__c, Driver__r.Name, Action__c 
                     FROM Endorsement_Drivers__r)
                FROM Endorsement_Request__c 
                WHERE Id IN (
                    SELECT Endorsement_Request__c 
                    FROM Endorsement_Policy__c 
                    WHERE Policy__c = :policyId
                )
                AND Status__c = 'Completed'
                ORDER BY Effective_Date__c DESC
            ];

            
            for (Endorsement_Request__c er : endorsementRequests) {
                for (Endorsement_Vehicle__c ev : er.Endorsement_Vehicles__r) {
                    endorsementList.add(new EndorsementWrapper(
                        ev.Id,
                        er.Name,
                        er.Effective_Date__c,
                        'Vehicle',
                        //ev.Vehicle__r.Name,
                        ev.New_VIN__c != null ? ev.New_VIN__c : ev.Vehicle__r.Name, // Use New_VIN if available
                        ev.Vehicle__r.Make__r.Name,
                        ev.New_Year__c != null ? ev.New_Year__c : ev.Vehicle__r.Year__c, // Use New_Year if available
                        ev.New_Value__c != null ? ev.New_Value__c : ev.Vehicle__r.Value__c, // Use New_Value if available
                        ev.New_Weight__c != null ? ev.New_Weight__c : ev.Vehicle__r.Weight__c, // Use New_Weight if available
                        //ev.Vehicle__r.Year__c,
                        //ev.Vehicle__r.Value__c,
                        //ev.Vehicle__r.Weight__c,                        
                        '',
                        ev.Action__c
                    ));
                }

                for (Endorsement_Trailer__c et : er.Endorsement_Trailers__r) {
                    endorsementList.add(new EndorsementWrapper(
                        et.Id,
                        er.Name,
                        er.Effective_Date__c,
                        'Trailer',
                        //et.Trailer__r.Name,
                        et.New_VIN__c != null ? et.New_VIN__c : et.Trailer__r.Name, // Use New_VIN if available
                        et.Trailer__r.Make__r.Name,
                        et.New_Year__c != null ? et.New_Year__c : et.Trailer__r.Year__c, // Use New_Year if available
                        et.New_Value__c != null ? et.New_Value__c : et.Trailer__r.Value__c, // Use New_Value if available
                        et.New_Weight__c != null ? et.New_Weight__c : et.Trailer__r.Weight__c, // Use New_Weight if available
                        //et.Trailer__r.Year__c,
                        '',
                        et.Action__c
                    ));
                }

                for (Endorsement_Driver__c ed : er.Endorsement_Drivers__r) {
                    endorsementList.add(new EndorsementWrapper(
                        ed.Id,
                        er.Name,
                        er.Effective_Date__c,
                        'Driver',
                        ed.Driver__r.CDL__c,
                        '',
                        null,
                        0,
                        0,
                        ed.Driver__r.Name,
                        ed.Action__c
                    ));
                }
            }
            

            /*
            for (Endorsement_Request__c er : endorsementRequests) {
                for (Endorsement_Vehicle__c ev : er.Endorsement_Vehicles__r) {
                    String identifier = (ev.Action__c == 'Modify' && String.isNotBlank(ev.New_VIN__c)) 
                        ? ev.Vehicle__r.Name + ' -> ' + ev.New_VIN__c
                        : ev.Vehicle__r.Name;

                    endorsementList.add(new EndorsementWrapper(
                        ev.Id,
                        er.Name,
                        er.Effective_Date__c,
                        'Vehicle',
                        identifier,
                        ev.Vehicle__r.Make__r.Name,
                        ev.Vehicle__r.Year__c,
                        '',
                        ev.Action__c
                    ));
                }

                for (Endorsement_Trailer__c et : er.Endorsement_Trailers__r) {
                    String identifier = (et.Action__c == 'Modify' && String.isNotBlank(et.New_VIN__c)) 
                        ? et.Trailer__r.Name + ' -> ' + et.New_VIN__c
                        : et.Trailer__r.Name;

                    endorsementList.add(new EndorsementWrapper(
                        et.Id,
                        er.Name,
                        er.Effective_Date__c,
                        'Trailer',
                        identifier,
                        et.Trailer__r.Make__r.Name,
                        et.Trailer__r.Year__c,
                        '',
                        et.Action__c
                    ));
                }

                for (Endorsement_Driver__c ed : er.Endorsement_Drivers__r) {
                    endorsementList.add(new EndorsementWrapper(
                        ed.Id,
                        er.Name,
                        er.Effective_Date__c,
                        'Driver',
                        ed.Driver__r.CDL__c,
                        '',
                        null,
                        ed.Driver__r.Name,
                        ed.Action__c
                    ));
                }
            }
            */



            // Sort by Date before returning
            endorsementList.sort(new EndorsementDateComparator());

        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving endorsement history: ' + e.getMessage());
        }

        return endorsementList;
    }

    @AuraEnabled(cacheable=true)
    public static List<EndorsementWrapper> getLatestEndorsements(Id policyId) {
        List<EndorsementWrapper> latestEndorsements = new List<EndorsementWrapper>();
        Map<String, EndorsementWrapper> uniqueEndorsements = new Map<String, EndorsementWrapper>();

        try {
            List<EndorsementWrapper> allEndorsements = getEndorsementHistory(policyId);

            for (EndorsementWrapper ew : allEndorsements) {
                String uniqueKey = ew.recordType + '_' + ew.identifier;

                if (!uniqueEndorsements.containsKey(uniqueKey) || 
                    ew.rawCreatedDate.getTime() > uniqueEndorsements.get(uniqueKey).rawCreatedDate.getTime()) {
                    uniqueEndorsements.put(uniqueKey, ew);
                }
            }

            latestEndorsements = uniqueEndorsements.values();
            latestEndorsements.sort(new EndorsementDateComparator());

        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving latest endorsements: ' + e.getMessage());
        }

        return latestEndorsements;
    }

    public class EndorsementWrapper {
        @AuraEnabled public String id { get; set; }
        @AuraEnabled public String endorsementRequestName { get; set; }
        @AuraEnabled public String endorsementCreatedDate { get; set; }
        @AuraEnabled public String recordType { get; set; }
        @AuraEnabled public String identifier { get; set; }        
        @AuraEnabled public String Make { get; set; }
        @AuraEnabled public Decimal Year { get; set; }
        @AuraEnabled public Decimal Value { get; set; }
        @AuraEnabled public Decimal Weight { get; set; }
        @AuraEnabled public String DriverName { get; set; }
        @AuraEnabled public String action { get; set; }

        // Helper field used for Apex-side sorting
        public Datetime rawCreatedDate;

        public EndorsementWrapper(String id, 
                                  String endorsementRequestName, 
                                  Date endorsementCreatedDate,
                                  String recordType, 
                                  String identifier, 
                                  String Make, 
                                  Decimal Year, 
                                  Decimal Value,
                                  Decimal Weight,
                                  String DriverName,
                                  String action) {
            this.id = id;
            this.endorsementRequestName = endorsementRequestName;
            this.endorsementCreatedDate = endorsementCreatedDate != null ? endorsementCreatedDate.format() : '';
            this.rawCreatedDate = endorsementCreatedDate;
            this.recordType = recordType;
            this.identifier = identifier != null ? identifier : '';
            this.Make = Make != null ? Make : '';
            this.Year = Year != null ? Year : 0;
            this.Value = Value != null ? Value : 0;
            this.Weight = Weight != null ? Weight : 0;
            this.DriverName = DriverName != null ? DriverName : '';
            this.action = action != null ? action : '';
        }
    }

    public class EndorsementDateComparator implements Comparator<EndorsementWrapper> {
        public Integer compare(EndorsementWrapper a, EndorsementWrapper b) {
            if (a.rawCreatedDate == b.rawCreatedDate) return 0;
            if (a.rawCreatedDate > b.rawCreatedDate) return -1;
            return 1;
        }
    }
}