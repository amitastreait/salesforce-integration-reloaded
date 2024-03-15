// driveFileExplorer.js
import { LightningElement, wire, track, api } from 'lwc';
//import fetchFilesFromGoogleDrive from '@salesforce/apex/GoogleDriveIntegration.fetchFilesFromGoogleDrive';
//import fetchFileContent from '@salesforce/apex/GoogleDriveIntegration.fetchFileContent';

export default class DriveFileExplorer extends LightningElement {
    @api files = [];
    isModalOpen = false;
    modalContentUrl = '';
    isLoading = false;

    /*@wire(fetchFilesFromGoogleDrive, { folderId: '198OxY8bJC7B13wJAQDZ7W3Fm2jteELW_' })
    wiredFiles({ error, data }) {
        if (data) {
            this.files = data.map(file => ({
                name: file.name,
                fileId: file.fileName,
                thumbnailUrl: file.thumbnailUrl,
                mimeType: file.mimeType,
                iconUrl: this.getFileIconUrl(file.name),
                previewIconUrl: this.getPreviewIconUrl(file.name)
            }));
            console.log( JSON.stringify(this.files, null, 2) );
            this.isLoading = false;
        } else if (error) {
            console.error('Error loading files:', error);
            this.isLoading = false;
        }
    }*/

    openFileModal(event) {
        this.isLoading = true;
        const fileId = event.currentTarget.dataset.fileId;
        this.modalContentUrl = 'https://drive.google.com/file/d/' + fileId + '/preview';
        this.isModalOpen = true;
        console.log(this.modalContentUrl);
        console.log(fileId);
        this.isLoading = false;
    }

    /*async openFileModalAsync(event) {
        const fileId = event.currentTarget.dataset.fileId;
        this.isLoading = true;
        try {
            // Fetch file content
            const fileContent = await fetchFileContent({ fileId: fileId });
            // Update modal content with file content
            this.modalContentUrl = URL.createObjectURL(new Blob([fileContent], { type: 'application/pdf' })); // Example for PDF file content
            console.log('this.modalContentUrl', this.modalContentUrl );
            this.isModalOpen = true;
            this.isLoading = false;
        } catch (error) {
            console.error('Error fetching file content:', error);
            this.isLoading = false;
        }
    }*/

    closeModal() {
        this.isModalOpen = false;
        this.modalContentUrl = '';
    }
    /*
    getFileIconUrl(fileName) {
        const fileExtension = this.getFileExtension(fileName);
        let iconUrl;
        console.log(fileExtension);
        switch (fileExtension.toLowerCase()) {
            case 'pdf':
                iconUrl = 'https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/svgs/solid/file-pdf.svg';
                break;
            case 'doc':
            case 'docx':
                iconUrl = 'https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/svgs/solid/file-word.svg';
                break;
            case 'xls':
            case 'xlsx':
                iconUrl = 'https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/svgs/solid/file-excel.svg';
                break;
            case 'ppt':
            case 'pptx':
                iconUrl = 'https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/svgs/solid/file-powerpoint.svg';
                break;
            case 'jpg':
            case 'jpeg':
            case 'png':
            case 'gif':
                iconUrl = 'https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/svgs/solid/file-image.svg';
                break;
            default:
                iconUrl = 'https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/svgs/solid/file.svg';
        }

        return iconUrl;
    }

    getPreviewIconUrl(fileName) {
        const fileExtension = this.getFileExtension(fileName);
        let previewIconUrl;

        switch (fileExtension.toLowerCase()) {
            case 'pdf':
                previewIconUrl = 'https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/svgs/solid/eye.svg';
                break;
            default:
                previewIconUrl = ''; // Set to empty string if no preview icon is available
        }

        return previewIconUrl;
    }

    getFileExtension(fileName) {
        const lastIndex = fileName.lastIndexOf('.');
        return lastIndex !== -1 ? fileName.substring(lastIndex + 1) : '';
    }*/
}