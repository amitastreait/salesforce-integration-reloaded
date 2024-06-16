import { LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
export default class EventConfirmation extends NavigationMixin(LightningElement) {

    handleVisit(event){
        event.preventDefault();
        this[NavigationMixin.Navigate]({
            type: "standard__webPage",
            attributes: {
               url: "https://www.muledreamin.com"
            }
        });
    }
}