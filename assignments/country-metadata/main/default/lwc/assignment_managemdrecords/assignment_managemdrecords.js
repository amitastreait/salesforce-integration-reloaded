import { LightningElement, track } from 'lwc';
import manageRecords from '@salesforce/apex/Assignment_DeployMetadataUtils.manageRecords';
import getAllRecords from '@salesforce/apex/Assignment_DeployMetadataUtils.getAllRecords';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class Assignment_managemdrecords extends LightningElement {

    isLoading = false;

    @track records = [
        {}
    ];

    connectedCallback(){
        this.getMetadataRecords();
    }

    getMetadataRecords(){
        
        getAllRecords()
        .then(result => {
            this.records = result.map(record=>{
                return {
                    MasterLabel: record.MasterLabel,
                    CurrencyCode__c: record.CurrencyCode__c,
                    CurrencySymbol__c: record.CurrencySymbol__c,
                    ISOCode__c: record.ISOCode__c,
                    Flag__c: record.Flag__c,
                    latitude__c: record.latitude__c,
                    longitude__c: record.longitude__c,
                }
            });
            console.log( JSON.stringify(this.records, null, 2) )
        })
        .catch(error => {
            // TODO Error handling
            console.error(error);
        })
        .finally(()=>{
            this.isLoading = false;
        })
    }

    handleChange(event){
        event.preventDefault();
        let name = event.currentTarget.dataset.name;
        //console.log(name);
        let index = event.currentTarget.dataset.index;
        //console.log(index);
        let value = event.target.value;
        //console.log(value);
        this.records[index][name] = value;
    }

    handleRowAdd(event){
        event.preventDefault();
        this.records.splice(event.currentTarget.dataset.index, 0, {});
    }

    handleRowDelete(event){
        event.preventDefault();
        this.records.splice(event.currentTarget.dataset.index, 1);
    }

    handleDeploy(event){
        event.preventDefault();
        if(this.validateInput()){
            this.isLoading = true;
            console.log( JSON.stringify(this.records, null, 2) )
            manageRecords({
                records: this.records
            })
            .then(result => {
                console.log(result);
                this.dispatchEvent(new ShowToastEvent({
                    title: "Success!",
                    message: "The Metadata records deployment has been queued! Please check the records",
                    variant: "success"
                }));
            })
            .catch(error => {
                // TODO Error handling
                console.error(error);
                this.dispatchEvent(new ShowToastEvent({
                    title: "Error",
                    message: JSON.stringify(error),
                    variant: "error"
                }));
            })
            .finally(()=>{
                this.isLoading = false;
            })
        }else{
            // Not Valid
        }
    }

    validateInput(){
        const allValid = [
            ...this.template.querySelectorAll('lightning-input'),
        ].reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);
        return allValid;
    }
}