import { LightningElement, api, wire, track } from 'lwc';
import getRecordsByEndorsementRequest from '@salesforce/apex/EndorsementRequestVehicleController.getRecordsByEndorsementRequest';
import createEndorsementRecords from '@salesforce/apex/EndorsementRequestVehicleController.createEndorsementRecords';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class EndorsementRequestVehicles extends LightningElement {
    @api recordId; // Id of the Endorsement_Request__c record

    @track vehicles = [];
    @track trailers = [];
    @track drivers = [];
    @track selectedVehicles = [];
    @track selectedTrailers = [];
    @track selectedDrivers = [];
    @track action = 'Delete'; // Default action value
    actionOptions = [
        { label: 'Delete', value: 'Delete' },
        { label: 'Modify', value: 'Modify' },
        { label: 'Loss Payee', value: 'Loss Payee' }
    ];

    @wire(getRecordsByEndorsementRequest, { endorsementRequestId: '$recordId' })
    wiredRecords({ error, data }) {
        if (data) {
            this.vehicles = data.vehicles.map(record => ({ label: record.Name, value: record.Id }));
            this.trailers = data.trailers.map(record => ({ label: record.Name, value: record.Id }));
            this.drivers = data.drivers.map(record => ({ label: record.Name, value: record.Id }));
        } else if (error) {
            this.showToast('Error', 'Failed to fetch records.', 'error');
        }
    }

    handleVehicleSelection(event) {
        this.selectedVehicles = event.detail.value;
    }

    handleTrailerSelection(event) {
        this.selectedTrailers = event.detail.value;
    }

    handleDriverSelection(event) {
        this.selectedDrivers = event.detail.value;
    }

    handleActionChange(event) {
        this.action = event.target.value;
    }

    handleCreateEndorsementRecords() {
        if (
            this.selectedVehicles.length === 0 &&
            this.selectedTrailers.length === 0 &&
            this.selectedDrivers.length === 0
        ) {
            this.showToast('Error', 'No records selected.', 'error');
            return;
        }

        createEndorsementRecords({
            endorsementRequestId: this.recordId,
            vehicleIds: this.selectedVehicles,
            trailerIds: this.selectedTrailers,
            driverIds: this.selectedDrivers,
            action: this.action
        })
            .then(result => {
                if (result.success) {
                    this.showToast('Success', result.message, 'success');
                    this.selectedVehicles = [];
                    this.selectedTrailers = [];
                    this.selectedDrivers = [];
                } else {
                    this.showToast('Error', result.message, 'error');
                }
            })
            .catch(error => {
                console.error(error);
                this.showToast('Error', 'Failed to create endorsement records.', 'error');
            });
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
}