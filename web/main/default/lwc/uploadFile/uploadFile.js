import { LightningElement, track, api } from 'lwc';
import uploadFile from '@salesforce/apex/UploadFileController.uploadFile';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const MAX_FILE_SIZE = 4500000;
const CHUNK_SIZE = 750000;

export default class UploadFile extends LightningElement {
    @api recordId;
    @api fieldApiName;
    @api objectApiName;

    isLoading = false;
    fileSize;
    @track file;
    message = '';

    contentTypeMap = {
        'txt': 'text/plain',
        'csv': 'text/csv',
        'htm': 'text/html',
        'html': 'text/html',
        'css': 'text/css',
        'js': 'application/javascript',
        'json': 'application/json',
        'xml': 'application/xml',
        'pdf': 'application/pdf',
        'doc': 'application/msword',
        'docx': 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
        'xls': 'application/vnd.ms-excel',
        'xlsx': 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
        'ppt': 'application/vnd.ms-powerpoint',
        'pptx': 'application/vnd.openxmlformats-officedocument.presentationml.presentation',
        'jpg': 'image/jpeg',
        'jpeg': 'image/jpeg',
        'png': 'image/png',
        'gif': 'image/gif',
        'bmp': 'image/bmp',
        'svg': 'image/svg+xml',
        'tiff': 'image/tiff',
        'ico': 'image/x-icon',
        'zip': 'application/zip',
        'rar': 'application/x-rar-compressed',
        'tar': 'application/x-tar',
        '7z': 'application/x-7z-compressed',
        'gz': 'application/gzip',
        'mp3': 'audio/mpeg',
        'ogg': 'audio/ogg',
        'wav': 'audio/wav',
        'mp4': 'video/mp4',
        'avi': 'video/x-msvideo',
        'mov': 'video/quicktime',
        'wmv': 'video/x-ms-wmv'
    };

    connectedCallback(){
        if(this.objectApiName === 'Blog__c'){
            this.message = 'The valid values are TitleImage__c for Blog Title Image and AuthorImage__c for Author Profile Pic!'
        }else{
            this.message = '';
        }
    }

    handleFileChange(event) {
        this.file = event.target.files[0];
        this.fileSize = this.formatBytes(this.file.size, 2);
    }

    handleChange(event){
        event.preventDefault();
        this.fieldApiName = event.target.value;
    }
    
    uploadFile() {
        if (this.file) {
            if (this.file.size > MAX_FILE_SIZE) {
                let message = 'File size cannot exceed ' + MAX_FILE_SIZE + ' bytes.\n' + 'Selected file size: ' + this.file.size;
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Error',
                    message: message,
                    variant: 'error'
                }));
                return;
            }
            this.isLoading = true;
            const reader = new FileReader();
            var self = this;
            reader.onload = function() {
                var fileContents = reader.result;
                var base64Mark = 'base64,';
                var dataStart = fileContents.indexOf(base64Mark) + base64Mark.length;
                fileContents = fileContents.substring(dataStart);
                console.log('preparing parameters for file upload....');
                let params = {
                    recordId : self.recordId,
                    fileContent: encodeURIComponent(fileContents),
                    fieldApiName: self.fieldApiName,
                    fileName: self.file.name
                }
                console.log('uploading file...');
                uploadFile(params)
                .then(()=>{
                    self.dispatchEvent(new ShowToastEvent({
                        title: "Success!",
                        message: "File Uploaded",
                        variant: "success"
                    }));
                })
                .catch((error)=>{
                    console.error(error);
                })
                .finally(()=>{
                    self.isLoading = false;
                })
            };
            reader.readAsDataURL(this.file);
        } else {
            let message = 'Please select a file';
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error',
                message: message,
                variant: 'error'
            }));
            return;
        }
    }

    getFileContentType(fileExtension){
        fileExtension = fileExtension.toLowerCase();
        if (this.contentTypeMap.hasOwnProperty(fileExtension)) {
            return contentTypeMap[fileExtension];
        } else {
            return 'application/octet-stream';
        }
    }

    formatBytes(bytes,decimals) {
        if(bytes == 0) return '0 Bytes';
        var k = 1024,
            dm = decimals || 2,
            sizes = ['Bytes', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB'],
            i = Math.floor(Math.log(bytes) / Math.log(k));
        return parseFloat((bytes / Math.pow(k, i)).toFixed(dm)) + ' ' + sizes[i];
    }
}