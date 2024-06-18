import { LightningElement } from 'lwc';

import verifySignature from '@salesforce/apex/RazorpayConfig.verifySignature';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class RazorpayCallback extends LightningElement {

    isLoading = true;
    success = true;
    errorMessage = 'There was an unknown error! This is probably the error because of an invalid url. If you think this is an error, please reachout to us at contact@muledreamin.com !';

    //callbackUrl;
    connectedCallback() {
        this.handleCallback();
    }

    async handleCallback() {
        try {

            let urlParams = new URLSearchParams(window.location.search);
            let paymentId = urlParams.get('razorpay_payment_id');
            let paymentLinkId = urlParams.get('razorpay_payment_link_id');
            let referenceId = urlParams.get('razorpay_payment_link_reference_id');
            let paymentStatus = urlParams.get('razorpay_payment_link_status');
            let signature = urlParams.get('razorpay_signature');

            /* console.log(referenceId);
            console.log(paymentId);
            console.log(paymentLinkId);
            console.log(signature);
            console.log(paymentStatus); */

            if (paymentStatus === 'paid') {
                this.handleVerifySignature(
                    paymentId,
                    paymentLinkId,
                    signature
                );
            }
        } catch (error) {
            this.errorMessage = `Error in verification: ${error.message}`;
        } finally {
            this.isLoading = false;
        }
    }

    handleVerifySignature(paymentId, linkId, signature) {
        verifySignature({
            paymentId: paymentId,
            linkId: linkId,
            signature: signature
        })
            .then(result => {
                console.log('Result ', result);
                this.success = result;
                if (!result) {
                    this.dispatchEvent(new ShowToastEvent({
                        title: "Error!",
                        message: this.errorMessage,
                        variant: "error"
                    }));
                }
            })
            .catch(error => {
                console.error('Error: ', error);
            })
            .finally(() => {
                this.isLoading = false;
            });
    }

}