import { LightningElement, api, wire, track } from 'lwc';
import getRelatedFiles from '@salesforce/apex/FinanceRequestFilesController.getRelatedFiles';
import downloadSelectedFiles from '@salesforce/apex/FinanceRequestFilesController.downloadSelectedFiles';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class FinanceRequestFiles extends LightningElement {
    @api recordId; // Finance_Request__c record ID
    @track files = [];
    @track selectedFileIds = new Set();
    isLoading = false;

    // Fetch related files
    @wire(getRelatedFiles, { financeRequestId: '$recordId' })
    wiredFiles({ error, data }) {
        if (data) {
            this.files = data.map(file => ({
                id: file.id,
                name: file.name
            }));
        } else if (error) {
            this.showToast('Error', 'Failed to load files', 'error');
        }
    }

    // Handle checkbox selection
    handleCheckboxChange(event) {
        const fileId = event.target.dataset.id;
        if (event.target.checked) {
            this.selectedFileIds.add(fileId);
        } else {
            this.selectedFileIds.delete(fileId);
        }
    }

    // Call Apex to zip and download
    async handleDownload() {
        if (this.selectedFileIds.size === 0) {
            this.showToast('Warning', 'Please select at least one file.', 'warning');
            return;
        }

        this.isLoading = true;
        try {
            const zipContentDocumentId = await downloadSelectedFiles({ selectedDocumentIds: Array.from(this.selectedFileIds) , financeRequestId: this.recordId });
            this.triggerDownload(zipContentDocumentId);
        } catch (error) {
            this.showToast('Error', 'Failed to download files', 'error');
        }
        this.isLoading = false;
    }

    // Trigger file download
    triggerDownload(contentDocumentId) {
        const downloadUrl = `/sfc/servlet.shepherd/document/download/${contentDocumentId}`;
        window.open(downloadUrl, '_blank');
        this.showToast('Success', 'Download started.', 'success');
    }

    // Show toast messages
    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
}