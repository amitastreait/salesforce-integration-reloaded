import { api, LightningElement, wire } from 'lwc';
import uploadFile from '@salesforce/apex/DropboxFileManagerHandler.uploadFile';
import queryName from '@salesforce/apex/DropboxFileManagerHandler.queryName';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class DropboxFileManager extends LightningElement {

    @api recordId;
    @api objectApiName;
    isLoading = false;
    @api filePath = '/';

    @api fieldApiName = 'Name';

    @wire(queryName, { recordId: '$recordId', fieldApiName: '$fieldApiName', objectApiName: '$objectApiName' })
    wiredData({ error, data }) {
      if (data && data.Id) {
        console.log('Data', data);
        this.filePath = data[this.fieldApiName];
      } else if (error) {
         console.error('Error:', error);
      }
    }


    /**
    * [
        {
            "name": "trailblazer-social-picture.png",
            "documentId": "069Hu00000g6j8GIAQ",
            "contentVersionId": "068Hu00000gTX97IAG",
            "contentBodyId": "05THu00003FyWlUMAV",
            "mimeType": "image/png"
        }
      ]
     */
    handleUploadFinished(event){
        const uploadedFiles = event.detail.files;
        console.log(uploadedFiles);
        for (let i = 0; i < uploadedFiles.length; i++) {
            const file = uploadedFiles[i];
            this.isLoading = true;
            this.handleFileUpload(file.contentVersionId);
        }
    }
    handleFileUpload(fileId){
        uploadFile({ 
            fileId: fileId,
            filePath: this.filePath,
            recordId: this.recordId
        })
        .then(result => {
            console.log('Result', result);
            this.dispatchEvent(new ShowToastEvent({
                title: "Success",
                message: "File uploaded successfully",
                variant: "success"
            }));
        })
        .catch(error => {
            console.error('Error:', error);
            this.dispatchEvent(new ShowToastEvent({
                title: "Error",
                message: "Error while uploading file "+ JSON.stringify(error),
                variant: "error"
            }));
        })
        .finally(()=>{
            this.isLoading = false;
        })
    }
}