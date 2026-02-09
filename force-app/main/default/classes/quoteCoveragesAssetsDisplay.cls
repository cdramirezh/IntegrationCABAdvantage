public with sharing class quoteCoveragesAssetsDisplay {

    @AuraEnabled(cacheable=true)
    public static List<VehicleWithCoverages> getGroupedVehiclesAndCoverages(Id quoteId) {
        List<Coverage__c> coverages = [SELECT Id, Name, Coverage_Product__r.Name,
                                              (SELECT Vehicle__r.Name FROM Coverage_Vehicles__r) 
                                       FROM Coverage__c 
                                       WHERE Policy_Draft__c = :quoteId];
        
        Map<String, Set<String>> vehicleCoverageMap = new Map<String, Set<String>>();

        for (Coverage__c coverage : coverages) {
            for (Coverage_Vehicle__c cv : coverage.Coverage_Vehicles__r) {
                String vehicleName = cv.Vehicle__r.Name;

                if (!vehicleCoverageMap.containsKey(vehicleName)) {
                    vehicleCoverageMap.put(vehicleName, new Set<String>());
                }
                vehicleCoverageMap.get(vehicleName).add(coverage.Coverage_Product__r.Name);
            }
        }

        List<VehicleWithCoverages> vehicleCoveragesList = new List<VehicleWithCoverages>();
        for (String vehicleName : vehicleCoverageMap.keySet()) {
            // Manually join the Set<String> into a comma-separated string
            String coverageNames = buildCommaSeparatedString(new List<String>(vehicleCoverageMap.get(vehicleName)));
            vehicleCoveragesList.add(new VehicleWithCoverages(vehicleName, coverageNames));
        }

        return vehicleCoveragesList;
    }

    @AuraEnabled(cacheable=true)
    public static List<TrailerWithCoverages> getGroupedTrailersAndCoverages(Id quoteId) {
        List<Coverage__c> coverages = [SELECT Id, Name, Coverage_Product__r.Name,
                                              (SELECT Trailer__r.Name FROM Coverage_Trailers__r) 
                                       FROM Coverage__c 
                                       WHERE Policy_Draft__c = :quoteId];
        
        Map<String, Set<String>> trailerCoverageMap = new Map<String, Set<String>>();

        for (Coverage__c coverage : coverages) {
            for (Coverage_Trailer__c ct : coverage.Coverage_Trailers__r) {
                String trailerName = ct.Trailer__r.Name;

                if (!trailerCoverageMap.containsKey(trailerName)) {
                    trailerCoverageMap.put(trailerName, new Set<String>());
                }
                trailerCoverageMap.get(trailerName).add(coverage.Coverage_Product__r.Name);
            }
        }

        List<TrailerWithCoverages> trailerCoveragesList = new List<TrailerWithCoverages>();
        for (String trailerName : trailerCoverageMap.keySet()) {
            // Manually join the Set<String> into a comma-separated string
            String coverageNames = buildCommaSeparatedString(new List<String>(trailerCoverageMap.get(trailerName)));
            trailerCoveragesList.add(new TrailerWithCoverages(trailerName, coverageNames));
        }

        return trailerCoveragesList;
    }

    @AuraEnabled(cacheable=true)
    public static List<DriverWithCoverages> getGroupedDriversAndCoverages(Id quoteId) {
        List<Coverage__c> coverages = [SELECT Id, Name, Coverage_Product__r.Name,
                                              (SELECT Driver__r.Name FROM Coverage_Drivers__r) 
                                       FROM Coverage__c 
                                       WHERE Policy_Draft__c = :quoteId];
        
        Map<String, Set<String>> driverCoverageMap = new Map<String, Set<String>>();

        for (Coverage__c coverage : coverages) {
            for (Coverage_Driver__c cd : coverage.Coverage_Drivers__r) {
                String driverName = cd.Driver__r.Name;

                if (!driverCoverageMap.containsKey(driverName)) {
                    driverCoverageMap.put(driverName, new Set<String>());
                }
                driverCoverageMap.get(driverName).add(coverage.Coverage_Product__r.Name);
            }
        }

        List<DriverWithCoverages> driverCoveragesList = new List<DriverWithCoverages>();
        for (String driverName : driverCoverageMap.keySet()) {
            // Manually join the Set<String> into a comma-separated string
            String coverageNames = buildCommaSeparatedString(new List<String>(driverCoverageMap.get(driverName)));
            driverCoveragesList.add(new DriverWithCoverages(driverName, coverageNames));
        }

        return driverCoveragesList;
    }

    // Utility method to manually join a List<String> into a comma-separated string
    public static String buildCommaSeparatedString(List<String> items) {
        String result = '';
        for (Integer i = 0; i < items.size(); i++) {
            result += (i == 0 ? '' : ', ') + items[i];
        }
        return result;
    }

    public class VehicleWithCoverages {
        @AuraEnabled public String vehicleName { get; set; }
        @AuraEnabled public String coverageNames { get; set; }

        public VehicleWithCoverages(String vehicleName, String coverageNames) {
            this.vehicleName = vehicleName;
            this.coverageNames = coverageNames;
        }
    }

    public class TrailerWithCoverages {
        @AuraEnabled public String trailerName { get; set; }
        @AuraEnabled public String coverageNames { get; set; }

        public TrailerWithCoverages(String trailerName, String coverageNames) {
            this.trailerName = trailerName;
            this.coverageNames = coverageNames;
        }
    }

    public class DriverWithCoverages {
        @AuraEnabled public String driverName { get; set; }
        @AuraEnabled public String coverageNames { get; set; }

        public DriverWithCoverages(String driverName, String coverageNames) {
            this.driverName = driverName;
            this.coverageNames = coverageNames;
        }
    }
}