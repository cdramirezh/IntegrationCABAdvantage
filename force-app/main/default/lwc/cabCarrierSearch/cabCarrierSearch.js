import { LightningElement, track } from 'lwc';
import searchCarrier from '@salesforce/apex/CABIntegrationController.searchCarrier';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class CabCarrierSearch extends LightningElement {
    @track dotNumber = '';
    @track isLoading = false;

    handleInputChange(event) {
        this.dotNumber = event.target.value;

        // Limpiamos la validación personalizada cada vez que el usuario escribe
        const inputField = event.target;
        inputField.setCustomValidity('');
        inputField.reportValidity();
    }

    handleKeyUp(event) {
        const isEnterKey = event.keyCode === 13;
        const inputField = this.template.querySelector('lightning-input');

        if (isEnterKey && !this.isLoading) {
            // 1. Validar que no esté vacío
            if (!this.dotNumber) {
                inputField.setCustomValidity('Please enter a DOT number.');
                inputField.reportValidity();
                return;
            }

            // 2. Validar que cumpla con el patrón numérico (checkValidity usa el pattern del HTML)
            if (inputField.checkValidity()) {
                this.handleSearch();
            } else {
                inputField.reportValidity();
            }
        }
    }

    async handleSearch() {
        this.isLoading = true;

        try {
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
                    title: 'Error in search',
                    message: error.body?.message || 'An error occurred while connecting to the server',
                    variant: 'error'
                })
            );
        } finally {
            this.isLoading = false;
        }
    }
}