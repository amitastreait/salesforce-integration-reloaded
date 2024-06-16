import { LightningElement, wire, track } from 'lwc';
import fetch from '@salesforce/apex/MediaService.fetch';
export default class Home extends LightningElement {
    @track media;

    @wire(fetch, { typex: 'Home' })
    wiredData({ error, data }) {
      if (data) {
        console.log('Data \n ', data);
        this.media = data;
      } else if (error) {
         console.error('Error:', error);
      }
    }
}