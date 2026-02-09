import { LightningElement, api, track, wire } from 'lwc';
import getDocumentsPackages from '@salesforce/apex/DocumentsCreationToolController.getDocumentsPackages';
import getDocumentTypePicklistValues from '@salesforce/apex/DocumentsCreationToolController.getDocumentTypePicklistValues';
import createDocument from '@salesforce/apex/DocumentsCreationToolController.createDocument';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';

export default class DocumentUploader extends NavigationMixin(LightningElement) {
    @api recordId; // Lead Id
    @track documentPackages = [];
    @track documentTypes = []; // Stores Document__c.Type__c picklist values
    selectedPackageId;
    documentName = '';
    selectedType = ''; // Holds the selected Type__c value
    documentId;
    error;

    // Wire to get related Documents_Package__c records
    @wire(getDocumentsPackages, { leadId: '$recordId' })
    wiredPackages({ error, data }) {
        if (data) {
            this.documentPackages = data.map(pkg => ({
                label: pkg.Type__c,
                value: pkg.Id
            }));
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.documentPackages = [];
        }
    }

    // Wire to get Document__c.Type__c picklist values
    @wire(getDocumentTypePicklistValues)
    wiredDocumentTypes({ error, data }) {
        if (data) {
            this.documentTypes = data.map(type => ({
                label: type,
                value: type
            }));
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.documentTypes = [];
        }
    }

    handleNameChange(event) {
        this.documentName = event.target.value;
    }

    handlePackageChange(event) {
        this.selectedPackageId = event.detail.value;
    }

    handleTypeChange(event) {
        this.selectedType = event.detail.value;
    }

    handleCreateDocument() {
        if (this.documentName && this.selectedPackageId && this.selectedType) {
            createDocument({
                docName: this.documentName,
                packageId: this.selectedPackageId,
                type: this.selectedType
            })
            .then(result => {
                this.documentId = result;
                this.showToast('Success', 'Document created successfully', 'success');
            })
            .catch(error => {
                this.showToast('Error creating document', error.body.message, 'error');
            });
        } else {
            this.showToast('Error', 'Please fill out all fields', 'error');
        }
    }

    handleUploadFinished(event) {
        const uploadedFiles = event.detail.files;
        if (uploadedFiles.length > 0) {
            this.showToast('Success', 'File uploaded successfully', 'success');
            // Optional: Navigate to the created document
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: this.documentId,
                    objectApiName: 'Document__c',
                    actionName: 'view'
                }
            });
        }
    }

    showToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant
            })
        );
    }
}