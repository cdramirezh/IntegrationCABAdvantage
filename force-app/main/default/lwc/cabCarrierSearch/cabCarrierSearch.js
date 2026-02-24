import { LightningElement, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation'; // Necesario para la navegación
import searchCarrier from '@salesforce/apex/CABIntegrationController.searchCarrier';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class CabCarrierSearch extends NavigationMixin(LightningElement) {
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

    handleNavigate({ recordId, objectApiName }) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: recordId,
                objectApiName: objectApiName,
                actionName: 'view'
            }
        });
    }

    handleToast({ title, message }) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: 'success'
            })
        );
    }

    async handleSearch() {
        this.isLoading = true;
        try {
            const result = await searchCarrier({ dot: this.dotNumber });
            const targetId = result.split(':')[1];

            if (result.startsWith('REDIRECT_ACCOUNT:')) {
                this.handleNavigate({ recordId: targetId, objectApiName: 'Account' });
                this.handleToast({
                    title: 'Existing Account',
                    message: `An existing Account with DOT: ${this.dotNumber} was found. Redirecting...`
                });
            } else if (result.startsWith('REDIRECT_LEAD:')) {
                this.handleNavigate({ recordId: targetId, objectApiName: 'Lead' });
                this.handleToast({
                    title: 'Existing Lead',
                    message: `An existing Lead with DOT: ${this.dotNumber} was found. Redirecting...`,
                })
            } else if (result.startsWith('REDIRECT_NEW_LEAD:')) {
                this.handleNavigate({ recordId: targetId, objectApiName: 'Lead' });
                this.handleToast({
                    title: 'New Lead Created',
                    message: `New Lead with DOT: ${this.dotNumber} was created from CAB Advantage. Redirecting...`,
                })
            } else {
                this.handleToast({
                    title: 'Unexpected Result',
                    message: 'The search returned an unexpected result. Please check the console for details.',
                    variant: 'warning'
                });
                console.warn(`Unexpected result from search DOT: ${this.dotNumber}`, result);
            }

        } catch (error) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error in search',
                    message: error.body?.message || 'An error occurred in the search process',
                    variant: 'error'
                })
            );
            console.error('Error in search:', error);
        } finally {
            this.isLoading = false;
        }
    }
}