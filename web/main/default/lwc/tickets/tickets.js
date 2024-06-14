import { LightningElement, track } from 'lwc';

export default class BookTickets extends LightningElement {
    quantity = 1;
    totalPrice = 999;
    pricePerTicket = 999;
    @track registrationForms = [ { id : 1, Name: '', Email: '', Phone: '', Organization: '', Size: ''} ];

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
            this.updateRegistrationForms();
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

    updateRegistrationForms() {
        this.registrationForms = Array.from({ length: this.quantity }, (v, i) => ({ id : i+1, Name: '', Email: '', Phone: '', Organization: '', Size: ''}));
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
            console.log('Form Submitted');
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
