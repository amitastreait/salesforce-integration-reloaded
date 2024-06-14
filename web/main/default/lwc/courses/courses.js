import { LightningElement, wire } from 'lwc';
import listCourses from '@salesforce/apex/CourseListService.listCourses';
export default class Courses extends LightningElement {
    records;
    errors;
    isLoading = true;
    @wire(listCourses)
    wiredData({ error, data }) {
      if (data) {
        //console.log('Data ', JSON.stringify(data));
        this.records = data;
        this.isLoading = false;
      } else if (error) {
        console.error('Error: ', error);
        this.isLoading = false;
      }
    }
}