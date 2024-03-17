import { LightningElement, api } from 'lwc';
import downloadFile from '@salesforce/apex/GoogleDriveFolderController.downloadFile';
export default class DriveFile extends LightningElement {

    @api file;
    iconUrl = '/apexpages/slds/latest/assets/icons/doctype-sprite/svg/symbols.svg#';
    docType;
    isLoading = false;

    getFileExtension(fileName) {
        return fileName.split('.').pop();
    }

    @api
    get icon() {
        const fileExtension = this.getFileExtension(this.file.name);
    
        switch (fileExtension.toLowerCase()) {
            case 'pdf':
                this.docType = 'pdf';
                break;
            case 'mp4':
                this.docType = 'mp4';
                break;
            case 'ai':
                this.docType = 'ai';
                break;
            case 'png':
            case 'jpg':
            case 'jpeg':
            case 'png':
                this.docType = 'image';
                break;
            case 'mp4':
                this.docType = 'mp4';
                break;
            case 'doc':
            case 'docx':
                this.docType = 'word';
                break;
            case 'xls':
            case 'xlsx':
                this.docType = 'excel';
                break;
            case 'ppt':
            case 'pptx':
                this.docType = 'ppt';
                break;
            case 'audio':
                this.docType = 'audio';
                break;
            case 'folder':
                this.docType = 'folder';
                break;
            case 'slide':
                this.docType = 'slide';
                break;
            case 'webx':
                this.docType = 'webex';
                break;
            case 'word':
                this.docType = 'word';
                break;
            case 'xml':
                this.docType = 'xml';
                break;
            case 'zip':
                this.docType = 'zip';
                break;
            case 'video':
                this.docType = 'video';
                break;
            case 'excel':
                this.docType = 'excel';
                break;
            case 'gform':
                this.docType = 'gform';
                break;
            default:
                this.docType = 'unknown';
                break;
        }
        return this.iconUrl+this.docType;
    }

    handleDownload(event){
        event.preventDefault();
        this.isLoading = true;
        
        downloadFile({ fileId : this.file.itemId })
        .then(result => {
            window.location.assign(result);
        })
        .catch(error => {
            console.error('Error: ', error);
        })
        .finally(()=>{
            this.isLoading = false;
        })
    }
    
}