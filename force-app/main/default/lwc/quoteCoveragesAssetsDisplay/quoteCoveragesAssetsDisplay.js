import { LightningElement, api, wire, track } from 'lwc';
import getGroupedVehiclesAndCoverages from '@salesforce/apex/quoteCoveragesAssetsDisplay.getGroupedVehiclesAndCoverages';
import getGroupedTrailersAndCoverages from '@salesforce/apex/quoteCoveragesAssetsDisplay.getGroupedTrailersAndCoverages';
import getGroupedDriversAndCoverages from '@salesforce/apex/quoteCoveragesAssetsDisplay.getGroupedDriversAndCoverages';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class CoverageVehicleDisplay extends LightningElement {
    @api recordId;
    @track vehicleCoverageMap = [];
    @track trailerCoverageMap = [];
    @track driverCoverageMap = [];
    @track error;

    vehicleColumns = [
        { label: 'Vehicle Name', fieldName: 'vehicleName' },
        { label: 'Coverages', fieldName: 'coverageNames' }
    ];

    trailerColumns = [
        { label: 'Trailer Name', fieldName: 'trailerName' },
        { label: 'Coverages', fieldName: 'coverageNames' }
    ];

    driverColumns = [
        { label: 'Driver Name', fieldName: 'driverName' },
        { label: 'Coverages', fieldName: 'coverageNames' }
    ];

    @wire(getGroupedVehiclesAndCoverages, { quoteId: '$recordId' })
    wiredVehicleCoverage({ error, data }) {
        if (data) {
            this.vehicleCoverageMap = data;
            this.error = undefined;
        } else if (error) {
            this.vehicleCoverageMap = [];
            this.error = error;
            this.showErrorToast(error);
        }
    }

    @wire(getGroupedTrailersAndCoverages, { quoteId: '$recordId' })
    wiredTrailerCoverage({ error, data }) {
        if (data) {
            this.trailerCoverageMap = data;
            this.error = undefined;
        } else if (error) {
            this.trailerCoverageMap = [];
            this.error = error;
            this.showErrorToast(error);
        }
    }

    @wire(getGroupedDriversAndCoverages, { quoteId: '$recordId' })
    wiredDriverCoverage({ error, data }) {
        if (data) {
            this.driverCoverageMap = data;
            this.error = undefined;
        } else if (error) {
            this.driverCoverageMap = [];
            this.error = error;
            this.showErrorToast(error);
        }
    }

    showErrorToast(error) {
        const evt = new ShowToastEvent({
            title: 'Error loading data',
            message: 'An error occurred: ' + error.body.message,
            variant: 'error',
        });
        this.dispatchEvent(evt);
    }
}