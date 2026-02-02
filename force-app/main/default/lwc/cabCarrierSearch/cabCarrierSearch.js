import { LightningElement, track } from 'lwc';
import searchCarrier from '@salesforce/apex/CABIntegrationController.searchCarrier';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class CabCarrierSearch extends LightningElement {
    @track dotNumber = '';
    @track isLoading = false;

    handleInputChange(event) {
        this.dotNumber = event.target.value;
    }

    get isButtonDisabled() {
        return this.isLoading || !this.dotNumber;
    }

    async handleSearch() {
        if (!this.dotNumber) return;

        this.isLoading = true;

        try {
            // Llamada al método Apex que conectará con tu Middleware
            const result = await searchCarrier({ dot: this.dotNumber });
            
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Carrier data retrieved successfully',
                    variant: 'success'
                })
            );
            
            console.log('Result:', result);
        } catch (error) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: error.body?.message || 'An error occurred during the search',
                    variant: 'error'
                })
            );
        } finally {
            this.isLoading = false;
        }
    }
}