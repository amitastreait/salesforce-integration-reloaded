import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
export default class CourseTile extends NavigationMixin(LightningElement) {
    @api course;
    defaultInage = 'https://course-pantherschools-dev-ed.develop.file.force.com/sfc/dist/version/renditionDownload?rendition=ORIGINAL_Jpg&oid=00DHu000003NXeO&versionId=068Hu00000dB7Tn&d=%2Fa%2FHu000000oZGx%2FMtbrzdaHHNzl5CeAJcSLS1PJU7.iP9qobFEwxBeN53I&asPdf=false';

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