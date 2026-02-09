import { LightningElement, api, wire, track } from 'lwc';
import getCommoditiesByEndorsementRequest from '@salesforce/apex/EndorsementRequestCommodityController.getCommoditiesByEndorsementRequest';
import createCommodityEndorsements from '@salesforce/apex/EndorsementRequestCommodityController.createCommodityEndorsements';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class EndorsementRequestCommodities extends LightningElement {
    @api recordId; // Endorsement_Request__c Id

    @track commodityOptions = [];
    @track selectedCommodities = [];
    @track action = 'Delete';
    actionOptions = [
        { label: 'Delete', value: 'Delete' },
        { label: 'Modify', value: 'Modify' }
    ];

    @wire(getCommoditiesByEndorsementRequest, { endorsementRequestId: '$recordId' })
    wiredCommodities({ error, data }) {
        if (data) {
            this.commodityOptions = data.map(item => ({ label: item.Name, value: item.Id }));
        } else if (error) {
            this.showToast('Error', 'Error fetching commodities.', 'error');
        }
    }

    handleSelectionChange(event) {
        this.selectedCommodities = event.detail.value;
    }

    handleActionChange(event) {
        this.action = event.target.value;
    }

    handleSubmit() {
        if (this.selectedCommodities.length === 0) {
            this.showToast('Error', 'No commodities selected.', 'error');
            return;
        }

        createCommodityEndorsements({
            endorsementRequestId: this.recordId,
            commodityIds: this.selectedCommodities,
            action: this.action
        })
        .then(result => {
            this.showToast('Success', result, 'success');
            this.selectedCommodities = [];
        })
        .catch(error => {
            console.error(error);
            this.showToast('Error', 'Failed to create commodity endorsements.', 'error');
        });
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
}