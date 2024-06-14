import { LightningElement, wire, track } from 'lwc';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import getCourseDetails from '@salesforce/apex/CourseDetailService.getCourseDetails';
export default class CourseDetails extends NavigationMixin(LightningElement) {

  currentPageReference;
  recordId;
  @track course={};

  isLoading = true;

  @wire(CurrentPageReference)
  setCurrentPageReference(currentPageReference) {
    this.currentPageReference = currentPageReference;
    this.recordId = this.currentPageReference.state.c__recordId;
    this.isLoading = true;
  }

  @wire(getCourseDetails, { recordId: '$recordId' })
  displayRecordInformation({ error, data }) {
    if (data) {
      //console.log('Data ', JSON.stringify(data));
      this.course = data;
      this.isLoading = false;
    } else if (error) {
       console.error('Error:', error);
       this.isLoading = false;
    }
  }

  handleRegister(event){
    event.preventDefault();
    this[NavigationMixin.Navigate]({
        type: "standard__webPage",
        attributes: {
           url: this.course.BookingUrl__c
        }
    });
  }
}