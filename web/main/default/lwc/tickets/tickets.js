import { LightningElement, track } from 'lwc';
import process from '@salesforce/apex/RSVPService.process';
export default class BookTickets extends LightningElement {
    quantity = 1;
    totalPrice = 999;
    pricePerTicket = 999;
    @track registrationForms = [ { id : 1, Name: '', Email: '', Phone: '', Organization: '', Size: ''} ];
    isLoading = false;

    get options(){
        return [
            { label : 'S', value : 'S' },
            { label : 'M', value : 'M' },
            { label : 'L', value : 'L' },
            { label : 'XL', value : 'XL' },
            { label : 'XXL', value : 'XXL' },
        ]
    }

    decreaseQuantity() {
        if (this.quantity > 1) {
            this.quantity -= 1;
            this.updateTotalPrice();
            this.updateDecreaseRegistrationForms();
        }
    }

    increaseQuantity() {
        this.quantity += 1;
        this.updateTotalPrice();
        this.updateRegistrationForms();
    }

    updateTotalPrice() {
        this.totalPrice = this.quantity * this.pricePerTicket;
    }

    updateDecreaseRegistrationForms() {
        this.registrationForms.splice(this.registrationForms.length-1, 1);
    }

    updateRegistrationForms() {
        this.registrationForms.splice(this.registrationForms.length, 0, { id : this.registrationForms.length+1, Name: '', Email: '', Phone: '', Organization: '', Size: ''})
    }

    handleSubmit(event) {
        event.preventDefault();
        const allValid = [
            ...this.template.querySelectorAll('lightning-input, lightning-combobox'),
        ].reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);
        console.log( JSON.stringify(this.registrationForms) );
        if (allValid) {
            // Handle form submission
            this.isLoading = true;
            console.log('Form Submitted');
            process({ records: JSON.stringify(this.registrationForms) })
              .then(result => {
                console.log('Result \n ', result);
              })
              .catch(error => {
                console.error('Error: \n ', error);
            })
            .finally(()=>{
                this.isLoading = false;
            })
        }
    }

    handleInputChange(event){
        event.preventDefault();
        let index = event.currentTarget.dataset.index;
        let name = event.currentTarget.name;
        let value = event.currentTarget.value;
        this.registrationForms[index][name] = value;
    }
}