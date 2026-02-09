import { LightningElement, api, wire, track } from 'lwc';
import getEndorsementRequests from '@salesforce/apex/OpportunityEndorsementsController.getEndorsementRequests';
import { refreshApex } from '@salesforce/apex';

export default class OpportunityEndorsementRequests extends LightningElement {
    @api recordId; // Opportunity Id
    @track endorsementRequests = [];
    @track error;
    @track isLoading = true;
    @track expandedSections = new Set();

    wiredEndorsementResult;

    vehicleColumns = [
        { label: 'Vehicle VIN', fieldName: 'vehicleName' },
        { label: 'Make', fieldName: 'vehicleMake' },
        { label: 'Year', fieldName: 'vehicleYear' },
        { label: 'Weight', fieldName: 'vehicleWeight' }
    ];

    trailerColumns = [
        { label: 'Trailer VIN', fieldName: 'trailerName' },
        { label: 'Make', fieldName: 'trailerMake' },
        { label: 'Year', fieldName: 'trailerYear' },
        { label: 'Weight', fieldName: 'trailerWeight' },
        { label: 'Type', fieldName: 'trailerType' }
    ];

    driverColumns = [
        { label: 'Driver Name', fieldName: 'driverName' },
        { label: 'CDL', fieldName: 'driverCDL' }
    ];

    commodityColumns = [
        { label: 'Commodity Name', fieldName: 'commodityName' },
        { label: 'Percent', fieldName: 'commodityPercent' }
    ];

    @wire(getEndorsementRequests, { opportunityId: '$recordId' })
    wiredEndorsements(result) {
        this.wiredEndorsementResult = result;
        if (result.data) {
            this.endorsementRequests = result.data.map(request => ({
                ...request,
                sectionClass: 'slds-section',
                isExpanded: false,
                formattedEffectiveDate: this.formatDate(request.EffectiveDate), // fixed to use wrapper field
                hasPolicies: request.policies && request.policies.length > 0,
                hasCoverages: request.coverages && request.coverages.length > 0,

                // 🚀 Apply your transform functions here
                addedVehicles: this.transformVehicleData(request.addedVehicles),
                deletedVehicles: this.transformVehicleData(request.deletedVehicles),
                //modifiedVehicles: this.transformVehicleData(request.modifiedVehicles),

                addedTrailers: this.transformTrailerData(request.addedTrailers),
                deletedTrailers: this.transformTrailerData(request.deletedTrailers),
                //modifiedTrailers: this.transformTrailerData(request.modifiedTrailers),

                addedDrivers: this.transformDriverData(request.addedDrivers),
                deletedDrivers: this.transformDriverData(request.deletedDrivers),
                //modifiedDrivers: this.transformDriverData(request.modifiedDrivers),

                addedCommodities: this.transformCommodityData(request.addedCommodities),
                deletedCommodities: this.transformCommodityData(request.deletedCommodities),
                //modifiedCommodities: this.transformCommodityData(request.modifiedCommodities),

                hasAdditions: (request.addedVehicles && request.addedVehicles.length > 0) ||
                            (request.addedTrailers && request.addedTrailers.length > 0) ||
                            (request.addedDrivers && request.addedDrivers.length > 0) ||
                            (request.addedCommodities && request.addedCommodities.length > 0),
                hasDeletions: (request.deletedVehicles && request.deletedVehicles.length > 0) ||
                            (request.deletedTrailers && request.deletedTrailers.length > 0) ||
                            (request.deletedDrivers && request.deletedDrivers.length > 0) ||
                            (request.deletedCommodities && request.deletedCommodities.length > 0),
                hasModifications: (request.modifiedVehicles && request.modifiedVehicles.length > 0) ||
                                (request.modifiedTrailers && request.modifiedTrailers.length > 0) ||
                                (request.modifiedDrivers && request.modifiedDrivers.length > 0) ||
                                (request.modifiedCommodities && request.modifiedCommodities.length > 0),
                hasOtherRequest: request.OtherRequest && request.OtherRequest.trim() !== ''
            }));
            this.error = undefined;
        } else if (result.error) {
            this.error = result.error;
            this.endorsementRequests = [];
        }
        this.isLoading = false;
    }

    formatDate(dateString) {
        if (!dateString) return '';
        const date = new Date(dateString);
        return date.toLocaleDateString('en-US', {
            month: '2-digit',
            day: '2-digit',
            year: 'numeric'
        });
    }

    transformVehicleData(vehicles) {
        if (!vehicles) return [];
        return vehicles.map(vehicle => ({
            Id: vehicle.Id,
            vehicleName: vehicle.Vehicle__r?.Name || '',
            vehicleMake: vehicle.Vehicle__r?.Make__r?.Name || '',
            vehicleYear: vehicle.Vehicle__r?.Year__c || '',
            vehicleWeight: vehicle.Vehicle__r?.Weight__c || ''
        }));
    }

    transformTrailerData(trailers) {
        if (!trailers) return [];
        return trailers.map(trailer => ({
            Id: trailer.Id,
            trailerName: trailer.Trailer__r?.Name || '',
            trailerMake: trailer.Trailer__r?.Make__r?.Name || '',
            trailerYear: trailer.Trailer__r?.Year__c || '',
            trailerWeight: trailer.Trailer__r?.Weight__c || '',
            trailerType: trailer.Trailer__r?.Type__c || ''
        }));
    }

    transformDriverData(drivers) {
        if (!drivers) return [];
        return drivers.map(driver => ({
            Id: driver.Id,
            driverName: driver.Driver__r?.Name || '',
            driverCDL: driver.Driver__r?.CDL__c || ''
        }));
    }

    transformCommodityData(commodities) {
        if (!commodities) return [];
        return commodities.map(commodity => ({
            Id: commodity.Id,
            commodityName: commodity.Commodity__r?.Name || '',
            commodityPercent: commodity.Commodity__r?.Percent__c ? `${commodity.Commodity__r.Percent__c}%` : ''
        }));
    }

    handleSectionToggle(event) {
        const requestId = event.currentTarget.dataset.id;
        const updatedRequests = this.endorsementRequests.map(request => {
            if (request.Id === requestId) {
                return {
                    ...request,
                    isExpanded: !request.isExpanded,
                    sectionClass: !request.isExpanded ? 'slds-section slds-is-open' : 'slds-section'
                };
            }
            return request;
        });
        this.endorsementRequests = updatedRequests;
    }

    get hasEndorsementRequests() {
        return this.endorsementRequests && this.endorsementRequests.length > 0;
    }

    handleRefresh() {
        this.isLoading = true;
        return refreshApex(this.wiredEndorsementResult);
    }
}