import { LightningElement, api, wire, track } from 'lwc';
import getRelatedMGAQuoteInsuranceCompanies from '@salesforce/apex/FinanceRequestMGAQuotesInsController.getRelatedMGAQuoteInsuranceCompanies';
import getExistingFinanceRequestInsuranceCompanies from '@salesforce/apex/FinanceRequestMGAQuotesInsController.getExistingFinanceRequestInsuranceCompanies';
import createFinanceRequestInsuranceCompanies from '@salesforce/apex/FinanceRequestMGAQuotesInsController.createFinanceRequestInsuranceCompanies';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';

export default class FinanceRequestMGAQuotes extends LightningElement {
    @api recordId; // Finance_Request__c Id
    @track insuranceOptions = [];
    @track selectedInsuranceCompanies = [];
    existingInsuranceCompanyIds = new Set();

    // Obtener registros de MGA_Quote_Insurance_Company__c
    @wire(getRelatedMGAQuoteInsuranceCompanies, { financeRequestId: '$recordId' })
    wiredMGAQuotes({ error, data }) {
        if (data) {
            this.insuranceOptions = data.map(record => ({
                label: record.Name,
                value: record.Id
            }));
        } else if (error) {
            this.showToast('Error', 'Failed to fetch insurance companies', 'error');
        }
    }

    // Obtener registros existentes en Finance_Request_Insurance_Company__c
    @wire(getExistingFinanceRequestInsuranceCompanies, { financeRequestId: '$recordId' })
    wiredExistingInsuranceCompanies({ error, data }) {
        if (data) {
            this.existingInsuranceCompanyIds = new Set(data);
        } else if (error) {
            this.showToast('Error', 'Failed to fetch existing insurance companies', 'error');
        }
    }

    handleSelectionChange(event) {
        this.selectedInsuranceCompanies = event.detail.value;
    }

    

    handleCreateRecords() {
        const newSelections = this.selectedInsuranceCompanies.filter(id => !this.existingInsuranceCompanyIds.has(id));

        if (newSelections.length === 0) {
            this.showToast('Info', 'No new companies to add.', 'info');
            return;
        }

        createFinanceRequestInsuranceCompanies({ financeRequestId: this.recordId, insuranceCompanyIds: newSelections })
            .then(() => {
                this.showToast('Success', 'Finance Request Insurance Companies created.', 'success');
                this.selectedInsuranceCompanies = [];

                // Ensure refreshApex doesn't throw an error
                if (this.wiredExistingInsuranceCompanies) {
                    return refreshApex(this.wiredExistingInsuranceCompanies);
                }
            })
            .catch(error => {
                console.error('Error creating records:', error);

                // Ensure only actual errors trigger the error toast
                if (error?.body?.message) {
                    this.showToast('Error', error.body.message, 'error');
                } else {
                    this.showToast('Error', 'Failed to create records', 'error');
                }
            });
    }

    

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
}