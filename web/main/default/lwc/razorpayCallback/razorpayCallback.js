import { LightningElement } from 'lwc';

import verifySignature from '@salesforce/apex/RazorpayConfig.verifySignature';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import success from '@salesforce/resourceUrl/success';
import eventInfo from '@salesforce/label/c.EventInfoBookingPage';

export default class RazorpayCallback extends LightningElement {

    isLoading = true;
    success = true;
    errorMessage = 'There was an unknown error! This is probably the error because of an cyber attack. If you think this is an error, please reachout to us at contact@muledreamin.com !';

    bookings;
    referenceId;
    bookingCode;

    icons = {
        success
    }
    labels = {
        eventInfo
    }

    //callbackUrl;
    connectedCallback() {
        this.handleCallback();
    }

    async handleCallback() {
        try {

            let urlParams = new URLSearchParams(window.location.search);
            let paymentId = urlParams.get('razorpay_payment_id');
            let paymentLinkId = urlParams.get('razorpay_payment_link_id');
            this.referenceId = urlParams.get('razorpay_payment_link_reference_id');
            let paymentStatus = urlParams.get('razorpay_payment_link_status');
            let signature = urlParams.get('razorpay_signature');

            let params = {
                'paymentId': paymentId,
                'paymentLinkId': paymentLinkId,
                'referenceId': this.referenceId,
                'status': paymentStatus,
                'signature': signature
            }
            
            this.handleVerifySignature(params);

        } catch (error) {
            this.errorMessage = `Error in verification: ${error.message}`;
        } finally {
            this.isLoading = false;
        }
    }

    handleVerifySignature(params) {
        verifySignature(params)
        .then(result => {
            this.success = true;
            //console.table(result);
            this.bookings = result;
            if(this.bookings.length > 0 && this.bookings.length === 1){
                this.bookingCode = this.bookings[0]?.BookingCode__c?.toUpperCase();
            }
            if (!this.success) {
                this.dispatchEvent(new ShowToastEvent({
                    title: "Error!",
                    message: this.errorMessage,
                    variant: "error"
                }));
            }
            this.referenceId = this.referenceId.toUpperCase();
        })
        .catch(error => {
            console.error('Error: ', error);
            this.success = false;
        })
        .finally(() => {
            this.isLoading = false;
        });
    }

}