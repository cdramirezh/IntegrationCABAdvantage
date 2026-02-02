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

    async handleSearch() {
        this.isLoading = true;

        try {
            const result = await searchCarrier({ dot: this.dotNumber });

            let targetId;
            let toastTitle;
            let toastMessage;

            // Lógica para determinar si es un redireccionamiento o creación nueva
            if (result.startsWith('REDIRECT:')) {
                targetId = result.replace('REDIRECT:', '');
                toastTitle = 'Lead Existente';
                toastMessage = 'Se encontró un Lead con ese DOT. Redirigiendo...';
            } else {
                targetId = result;
                toastTitle = 'Éxito';
                toastMessage = 'Nuevo Lead creado a partir de CAB Advantage.';
            }

            // 1. Mostrar confirmación
            this.dispatchEvent(
                new ShowToastEvent({
                    title: toastTitle,
                    message: toastMessage,
                    variant: 'success'
                })
            );

            // 2. Ejecutar la navegación al registro
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: targetId,
                    objectApiName: 'Lead',
                    actionName: 'view'
                }
            });

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