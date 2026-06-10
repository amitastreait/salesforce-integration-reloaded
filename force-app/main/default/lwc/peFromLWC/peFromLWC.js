import { api, LightningElement } from 'lwc';
import { createRecord } from 'lightning/uiRecordApi';
import MY_EVENT_OBJECT from '@salesforce/schema/Account_Updated__c';
export default class PeFromLWC extends LightningElement {
    @api recordId
    handleClick() {
        const fields = {};
        fields.RecordId__c= this.recordId;
        fields.Change_Type__c = 'Insert';
        const recordInput = { apiName: MY_EVENT_OBJECT.objectApiName, fields };
        createRecord(recordInput)
        .then(response => {
            console.log('Event published successfull ', JSON.stringify(response));
        })
        .catch(error => {
            console.error('Error publishing event:', JSON.stringify(error));
        });
    }
}