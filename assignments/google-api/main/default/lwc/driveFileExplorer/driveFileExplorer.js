// driveFileExplorer.js
import { LightningElement, wire, track, api } from 'lwc';
//import fetchFilesFromGoogleDrive from '@salesforce/apex/GoogleDriveIntegration.fetchFilesFromGoogleDrive';
//import fetchFileContent from '@salesforce/apex/GoogleDriveIntegration.fetchFileContent';

export default class DriveFileExplorer extends LightningElement {
    @api files = [];
    isModalOpen = false;
    modalContentUrl = '';
    isLoading = false;

    openFileModal(event) {
        this.isLoading = true;
        const fileId = event.currentTarget.dataset.fileId;
        this.modalContentUrl = 'https://drive.google.com/file/d/' + fileId + '/preview';
        this.isModalOpen = true;
        console.log(this.modalContentUrl);
        console.log(fileId);
        this.isLoading = false;
    }

    closeModal() {
        this.isModalOpen = false;
        this.modalContentUrl = '';
    }

    handleFolderClick(event){
        event.preventDefault();
        let details = event.detail;
        console.log(JSON.stringify(details));
        const selectedEvent = new CustomEvent("select", {
            detail: {
                name: details.name,
                folderId: details.folderId
            }
        });
        this.dispatchEvent(selectedEvent);
    }
    
}