import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
export default class CourseTile extends NavigationMixin(LightningElement) {
    @api course;

    handleClick(event){
        event.preventDefault();
        this[NavigationMixin.Navigate]({
            type: "standard__namedPage",
            attributes: {
                pageName: "course-details"
            },
            state: {
                "c__recordId" : this.course.Id
            }
        });
    }

    handleAuthorClick(event){
        event.preventDefault();
        this[NavigationMixin.Navigate]({
            type: "standard__webPage",
            attributes: {
               url: `https://www.linkedin.com/in/cloudyamit/`
            }
        });
    }
}