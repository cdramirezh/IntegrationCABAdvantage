import { LightningElement, api, wire, track } from 'lwc';
import getVehicles from '@salesforce/apex/PolicyAssetBulkAdd.getVehicles';
import getTrailers from '@salesforce/apex/PolicyAssetBulkAdd.getTrailers';
import getDrivers from '@salesforce/apex/PolicyAssetBulkAdd.getDrivers';
import createPolicyAssetRecords from '@salesforce/apex/PolicyAssetBulkAdd.createPolicyAssetRecords';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class PolicyAssetAssignment extends LightningElement {
    @api recordId; // Policy_Draft__c Id
    @track vehicleOptions = [];
    @track trailerOptions = [];
    @track driverOptions = [];
    @track selectedVehicles = [];
    @track selectedTrailers = [];
    @track selectedDrivers = [];

    // Fetch the vehicles related to the policy draft
    @wire(getVehicles, { policyDraftId: '$recordId' })
    wiredVehicles({ error, data }) {
        if (data) {
            this.vehicleOptions = data.map(vehicle => {
                return { label: vehicle.Name, value: vehicle.Id };
            });
        } else if (error) {
            this.showErrorToast(error);
        }
    }

    // Fetch the trailers related to the policy draft
    @wire(getTrailers, { policyDraftId: '$recordId' })
    wiredTrailers({ error, data }) {
        if (data) {
            this.trailerOptions = data.map(trailer => {
                return { label: trailer.Name, value: trailer.Id };
            });
        } else if (error) {
            this.showErrorToast(error);
        }
    }

    // Fetch the drivers related to the policy draft
    @wire(getDrivers, { policyDraftId: '$recordId' })
    wiredDrivers({ error, data }) {
        if (data) {
            this.driverOptions = data.map(driver => {
                return { label: driver.Name, value: driver.Id };
            });
        } else if (error) {
            this.showErrorToast(error);
        }
    }

    // Handle vehicle selection
    handleVehicleChange(event) {
        this.selectedVehicles = event.detail.value;
    }

    // Handle trailer selection
    handleTrailerChange(event) {
        this.selectedTrailers = event.detail.value;
    }

    // Handle driver selection
    handleDriverChange(event) {
        this.selectedDrivers = event.detail.value;
    }

    // Save the selected vehicle, trailer, and driver records to Policy_Draft
    handleSave() {
        if (
            this.selectedVehicles.length === 0 &&
            this.selectedTrailers.length === 0 &&
            this.selectedDrivers.length === 0
        ) {
            this.showToast('Error', 'Please select at least one vehicle, trailer, or driver.', 'error');
            return;
        }

        createPolicyAssetRecords({
            policyDraftId: this.recordId,
            vehicleIds: this.selectedVehicles,
            trailerIds: this.selectedTrailers,
            driverIds: this.selectedDrivers
        })
            .then(() => {
                this.showToast('Success', 'Assets related successfully to the policy draft.', 'success');
                window.location.reload();
            })
            .catch(error => {
                this.showErrorToast(error);
            });
    }

    // Utility to show toast messages
    showToast(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }

    // Utility to handle error toasts
    showErrorToast(error) {
        this.showToast('Error', 'An error occurred: ' + error.body.message, 'error');
    }
}