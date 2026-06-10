import { LightningElement } from 'lwc';
import createFreshdeskTicket from '@salesforce/apex/FreshdeskTicketsController.createTicket';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
export default class FreshdeskTicket extends LightningElement {

    ticketInformation = {
        "Status": '2'
    };

    isLoading = false;

    get sttausoptions() {
        return [
            { label: 'Open', value: '2' }
        ]
    }

    get typeoptions() {
        return [
            { label: 'Incident', value: 'Incident' },
            { label: 'Problem', value: 'Problem' }
        ]
    }
    get sourceoptions() {
        return [
            { label: 'Email', value: '1' },
            { label: 'Portal', value: '2' },
            { label: 'Phone', value: '3' },
            { label: 'Chat', value: '7' },
        ]
    }
    get prioritiesoptions() {
        return [
            { label: 'Low', value: '1' },
            { label: 'Medium', value: '2' },
            { label: 'High', value: '3' },
            { label: 'Urgent', value: '4' },

        ]
    }

    handleClick(event) {
        event.preventDefault();
        const allValid = [...this.template.querySelectorAll('lightning-input, lightning-combobox, lightning-textarea'),].reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);

        if (allValid) {
            this.isLoading = true;

            createFreshdeskTicket({
                inputMap: this.ticketInformation
            })
                .then(result => {
                    console.log('Result \n ', JSON.stringify(result));
                    if (result.isSuccess) {
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Success!',
                                message: result.message,
                                variant: 'success'
                            })
                        );
                    } else {
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Error!',
                                message: result.errorMessage,
                                variant: 'error'
                            })
                        );
                    }

                })
                .catch(error => {
                    console.error('Error:', error);
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error!',
                            message: JSON.stringify(error),
                            variant: 'error'
                        })
                    );
                })
                .finally(() => {
                    this.isLoading = false;
                })
        }
    }

    handleInputChange(event) {
        event.preventDefault();
        let name = event.target.name;
        let value = event.target.value;
        this.ticketInformation[name] = value;
    }
}