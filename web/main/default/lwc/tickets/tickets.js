import { LightningElement, track } from 'lwc';
import process from '@salesforce/apex/RazorpayPaymentLinkService.process';
import basePath from "@salesforce/community/basePath";
import CallbackAPIEndpoint from '@salesforce/label/c.CallbackAPIEndpoint';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';

export default class BookTickets extends NavigationMixin(LightningElement) {
    quantity = 1;
    totalPrice = 999;
    pricePerTicket = 999;
    @track registrationForms = [ { id : 1, Name: '', Email: '', Phone: '', Organization: '', Size: ''} ];
    isLoading = false;

    customerInfo = {}

    callbackUrl;
    connectedCallback(){
        this.callbackUrl = this.baseUrl()+basePath+'/'+CallbackAPIEndpoint;
        console.log(this.callbackUrl);
    }

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
        const allValid = [...this.template.querySelectorAll('lightning-input, lightning-combobox'),].reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);
        
        if (allValid) {
            this.isLoading = true;
            this.customerInfo.callback_url = this.callbackUrl;
            this.customerInfo.amount = this.totalPrice;
            
            process({
                customerInfo : this.customerInfo,
                bookingInfo  : JSON.stringify(this.registrationForms) 
            })
              .then(result => {
                const event = new ShowToastEvent({
                    title: 'Success!',
                    message: 'We are redirecting you to {0} ! Please wait, if it get stuck, click {1} to redirect!',
                    mode : 'sticky',
                    variant: 'success',
                    messageData: [
                        'Payment Page', {
                            url: result,
                            label: 'Here',
                        },
                    ],
                });
                this.dispatchEvent(event);
                window.location.href = result;
                /* this[NavigationMixin.Navigate]({
                    type: "standard__webPage",
                    attributes: {
                       url: result
                    }
                },
                true
              ); */
            })
            .catch(error => {
                console.error(JSON.stringify(error));
                const event = new ShowToastEvent({
                    title: 'Error!',
                    message: 'Error While Creating {0} ! Please try again, if you get the same error please {1} us!',
                    mode : 'sticky',
                    variant: 'error',
                    messageData: [
                        'Booking',
                        {
                            url: 'mailto:contact@muledreamin.com',
                            label: 'Contact',
                        },
                    ],
                });
                this.dispatchEvent(event);
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

    handleInfoChange(event){
        event.preventDefault();
        let name = event.currentTarget.name;
        let value = event.currentTarget.value;
        this.customerInfo[name] = value;
    }

    baseUrl(){
        const path = 'course';
        const before_ = `${path}`.substring(0, `${path}`.indexOf('/s')+1);
        const communityUrl = `https://${location.host}${before_}`;
        return communityUrl;
    }
}