import { LightningElement, api, wire } from 'lwc';
import getPolicyAssets from '@salesforce/apex/PolicyAssetController.getPolicyAssets';
import updatePolicyAssets from '@salesforce/apex/PolicyAssetController.updatePolicyAssets';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class PolicyAssetSelector extends LightningElement {
    @api recordId; // Policy__c record ID
    vehicles = [];
    trailers = [];
    drivers = [];

    selectedVehicles = [];
    selectedTrailers = [];
    selectedDrivers = [];

    connectedCallback() {
        this.fetchPolicyAssets();
    }

    fetchPolicyAssets() {
        getPolicyAssets({ policyId: this.recordId })
            .then((data) => {
                this.vehicles = data.vehicles.map((vehicle) => ({
                    label: vehicle.Vehicle__r.Name,
                    value: vehicle.Id
                }));
                this.trailers = data.trailers.map((trailer) => ({
                    label: trailer.Trailer__r.Name,
                    value: trailer.Id
                }));
                this.drivers = data.drivers.map((driver) => ({
                    label: driver.Driver__r.Name,
                    value: driver.Id
                }));

                this.selectedVehicles = data.vehicles
                    .filter((vehicle) => vehicle.Policy__c === this.recordId)
                    .map((vehicle) => vehicle.Id);

                this.selectedTrailers = data.trailers
                    .filter((trailer) => trailer.Policy__c === this.recordId)
                    .map((trailer) => trailer.Id);

                this.selectedDrivers = data.drivers
                    .filter((driver) => driver.Policy__c === this.recordId)
                    .map((driver) => driver.Id);
            })
            .catch((error) => {
                this.showToast('Error', error.body.message, 'error');
            });
    }

    handleSave() {
        updatePolicyAssets({
            policyId: this.recordId,
            vehicleIds: this.selectedVehicles,
            trailerIds: this.selectedTrailers,
            driverIds: this.selectedDrivers
        })
            .then(() => {
                this.showToast('Success', 'Policy assets updated successfully', 'success');
            })
            .catch((error) => {
                this.showToast('Error', error.body.message, 'error');
            });
    }

    handleVehicleChange(event) {
        this.selectedVehicles = event.detail.value;
    }

    handleTrailerChange(event) {
        this.selectedTrailers = event.detail.value;
    }

    handleDriverChange(event) {
        this.selectedDrivers = event.detail.value;
    }

    showToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title,
                message,
                variant
            })
        );
    }
}