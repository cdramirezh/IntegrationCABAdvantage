public with sharing class EndorsementApplicationController {

    public Endorsement_Request__c endorsementRequest { get; set; }
    public List<Endorsement_Vehicle__c> endorsementVehiclestoAdd { get; set; }
    //public List<Endorsement_Vehicle__c> endorsementVehiclestoDelete { get; set; }
    //public List<Endorsement_Vehicle__c> endorsementVehiclestoModify { get; set; }

    public EndorsementApplicationController(ApexPages.StandardController standardController) {
        this.endorsementRequest = (Endorsement_Request__c) standardController.getRecord();

        //Fetch Endorsement Vehicles to Add related to Endorsement Request
        endorsementVehiclestoAdd = [SELECT Id, Name, Vehicle__c, Action__c, Endorsement_Request__c, Vehicle__r.Name, Vehicle__r.Year__c, Vehicle__r.Make__r.Name
                                FROM Endorsement_Vehicle__c
                                WHERE Endorsement_Request__c = :endorsementRequest.Id];

                                /*
        //Fetch Endorsement Vehicles to Delete related to Endorsement Request
        endorsementVehiclestoDelete = [SELECT Id, Vehicle__c, Endorsement__c, Vehicle__r.Name, Vehicle__r.Action__c
                                FROM Endorsement_Vehicle__c
                                WHERE Endorsement__c = :endorsementRequest.Id and Vehicle__r.Action__c = 'Delete'];

        //Fetch Endorsement Vehicles to Modify related to Endorsement Request
        endorsementVehiclestoModify = [SELECT Id, Vehicle__c, Endorsement__c, Vehicle__r.Name, Vehicle__r.Action__c
                                FROM Endorsement_Vehicle__c
                                WHERE Endorsement__c = :endorsementRequest.Id and Vehicle__r.Action__c = 'Modify'];
*/
        
        

        

    }


}