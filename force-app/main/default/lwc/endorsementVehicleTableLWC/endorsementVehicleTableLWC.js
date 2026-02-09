import { LightningElement, api, wire, track } from 'lwc';
import getVehicles from '@salesforce/apex/EndorsementCovVehicleTableLWCController.getVehicles';
import updateVehicles from '@salesforce/apex/EndorsementCovVehicleTableLWCController.updateVehicles';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';

export default class EndorsementVehicleTable extends LightningElement {
    @api recordId;
    @track additionsDeletions = [];
    @track modifications = [];
    @track draftValues = [];

    wiredResult;

    columnsaddordel = [
        //{ label: 'VIN', fieldName: 'vehicleName', type: 'text' },
        {
            label: 'VIN',
            fieldName: 'vehicleUrl', // this is the field with the full URL
            type: 'url',
            typeAttributes: {
                label: { fieldName: 'vehicleName' }, // text to show
                target: '_blank' // open in new tab
            }
        },
        { label: 'Action', fieldName: 'Action__c', type: 'text' },
        { label: 'Year', fieldName: 'vehicleYear', type: 'text' },
        { label: 'Make', fieldName: 'vehicleMake', type: 'text' },
        { label: 'Current Value', fieldName: 'vehicleValue', type: 'currency' }
    ];

    columnmod = [
        //{ label: 'VIN', fieldName: 'vehicleName', type: 'text' },
        {
            label: 'VIN',
            fieldName: 'vehicleUrl', // this is the field with the full URL
            type: 'url',
            typeAttributes: {
                label: { fieldName: 'vehicleName' }, // text to show
                target: '_blank' // open in new tab
            }
        },
        { label: 'Action', fieldName: 'Action__c', type: 'text' },
        { label: 'Make', fieldName: 'vehicleMake', type: 'text' },        
        { label: 'Year', fieldName: 'vehicleYear', type: 'text' },
        { label: 'New Year', fieldName: 'New_Year__c', type: 'number', editable: true },
        { label: 'Value', fieldName: 'vehicleValue', type: 'currency' },
        { label: 'New Value', fieldName: 'New_Value__c', type: 'currency', editable: true },
        { label: 'Weight', fieldName: 'vehicleWeight', type: 'number' },
        { label: 'New Weight', fieldName: 'New_Weight__c', type: 'number', editable: true }
    ];

    @wire(getVehicles, { endorsementRequestId: '$recordId' })
    wiredVehicles(result) {
        this.wiredResult = result;
        const { data, error } = result;

        if (data) {

            const flattened = data.map(record => ({
                ...record,
                vehicleName: record.Vehicle__r?.Name || '',
                vehicleUrl: '/' + record.Id,
                vehicleYear: record.Vehicle__r?.Year__c || '',
                vehicleMake: record.Vehicle__r?.Make__r?.Name || '',
                vehicleValue: record.Vehicle__r?.Value__c || null,
                vehicleWeight: record.Vehicle__r?.Weight__c || null,
            }));

            this.additionsDeletions = flattened.filter(
                record => record.Action__c === 'Add' || record.Action__c === 'Delete'
            );
            this.modifications = flattened.filter(record => record.Action__c === 'Modify');
        } else if (error) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error loading vehicles',
                    message: error.body.message,
                    variant: 'error'
                })
            );
        }
    }

    handleSave(event) {
        const updatedFields = event.detail.draftValues;

        updateVehicles({ vehiclesToUpdate: updatedFields })
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Records updated',
                        variant: 'success'
                    })
                );
                this.draftValues = [];
                return refreshApex(this.wiredResult);
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error updating records',
                        message: error.body.message,
                        variant: 'error'
                    })
                );
            });
    }
}