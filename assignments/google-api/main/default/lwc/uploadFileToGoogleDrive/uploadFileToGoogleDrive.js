// uploadFileToGoogleDrive.js
import { LightningElement, track, api } from 'lwc';
import uploadFileToGoogleDrive from '@salesforce/apex/GoogleDriveIntegration.uploadFileToGoogleDrive';

export default class UploadFileToGoogleDrive extends LightningElement {
    @track isLoading = false;
    @track file;

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

    handleFileChange(event) {
        this.file = event.target.files[0];
    }
    
    uploadFile() {
        if (this.file) {
            if (this.file.size > 4 * 1024 * 1024) {
                // Handle file size exceeds the limit
                return;
            }
            
            this.isLoading = true;

            const reader = new FileReader();
            reader.onloadend = () => {
                let fileContents = reader.result;
                let base64Data = btoa(fileContents);
                let folderId = '198OxY8bJC7B13wJAQDZ7W3Fm2jteELW_'; // Provide the Google Drive folder ID
                let fileName = this.file.name;

                let lastIndex = fileName.lastIndexOf('.');
                let fileExt = fileName.substring(lastIndex + 1).toLowerCase();
                console.log(fileExt);
                let contentType = this.getFileContentType(fileExt);
                console.log(contentType);
                
                uploadFileToGoogleDrive({
                    folderId: folderId,
                    fileName: fileName,
                    base64Data: base64Data,
                    contentType: contentType
                })
                    .then(result => {
                        console.log(result);
                    })
                    .catch(error => {
                        console.error(error)
                    })
                    .finally(()=>{
                        this.isLoading = false;
                    })
            };
            reader.readAsBinaryString(this.file);
        } else {
            // Handle no file selected
        }
    }

    getFileContentType(fileExtension){
        fileExtension = fileExtension.toLowerCase();
        if (this.contentTypeMap.hasOwnProperty(fileExtension)) {
            return this.contentTypeMap[fileExtension];
        } else {
            // Default to application/octet-stream if content type is not found
            return 'application/octet-stream';
        }
    }
}