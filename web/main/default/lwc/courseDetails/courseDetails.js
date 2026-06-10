import { LightningElement, wire, track } from 'lwc';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import getCourseDetails from '@salesforce/apex/CourseDetailService.getCourseDetails';
export default class CourseDetails extends NavigationMixin(LightningElement) {

  currentPageReference;
  recordId;
  @track course={};
  defaultInage = 'https://course-pantherschools-dev-ed.develop.file.force.com/sfc/dist/version/renditionDownload?rendition=ORIGINAL_Jpg&oid=00DHu000003NXeO&versionId=068Hu00000dB7Tn&d=%2Fa%2FHu000000oZGx%2FMtbrzdaHHNzl5CeAJcSLS1PJU7.iP9qobFEwxBeN53I&asPdf=false';

  isLoading = true;
  couponCode = '';
  couponInvalidMessage = '';

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

  handleChange(event){
    event.preventDefault();
    this.couponCode = event.target.value;
  }

  handleApply(event){
    event.preventDefault();
    if(!this.couponCode){
      this.couponInvalidMessage = 'Please enter a valid coupon code!';
      return;
    }else{
      
    }
  }
}