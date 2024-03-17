import { LightningElement, wire } from 'lwc';
import fetchFolders from '@salesforce/apex/GoogleDriveFolderController.fetchFolders';
import fetchFilesFromGoogleDrive from '@salesforce/apex/GoogleDriveIntegration.fetchFilesFromGoogleDrive';

export default class GoogleDriveFoldersList extends LightningElement {
    folders;
    selectedFolderItems;
    isLoading = true;

    myBreadcrumbs = [
        { label: 'Home', name: 'home', id: 'home' },
    ];

    breadCrumbsMap = {
        home: '',
    };

    handleNavigateTo(event) {
        event.preventDefault();
        const name = event.target.name;
        
        if(name === 'home'){
            this.selectedFolderItems = '';
            this.myBreadcrumbs = [
                { label: 'Home', name: 'home', id: 'home' },
            ];
        }
    }

    @wire(fetchFolders)
    wiredFolders({ error, data }) {
        if (data) {
            this.isLoading = false;
            this.folders = data.map(folder => ({
                name: folder.name,
                folderId: folder.folderId,
                iconUrl : 'https://icons8.com/icon/12160/folder'
            }));
        } else if (error) {
            this.isLoading = false;
            console.error('Error fetching Google Drive folders:', error);
        }
    }

    handleFolderClick(event) {
        this.isLoading = true;
        const folderId = event.currentTarget.dataset.folderId;
        const folderName = event.currentTarget.dataset.folderName;
        this.myBreadcrumbs.push({
            label : folderName,
            name : folderId,
            id: folderId
        })
        this.fetchFilesAndSubfolders(folderId);
    }

    async fetchFilesAndSubfolders(folderId) {
        try {
            const result = await fetchFilesFromGoogleDrive({ folderId: folderId });
            console.log(result);
            this.selectedFolderItems = result.map(file => ({
                name: file.name,
                itemId: file.fileName,
                mimeType: file.mimeType,
                thumbnailUrl: file.thumbnailUrl,
                isFolder : file.mimeType === 'application/vnd.google-apps.folder'
            }));
            this.isLoading = false;
            //console.log(JSON.stringify(selectedFolderItems));
        } catch (error) {
            console.error('Error fetching files and subfolders:', JSON.stringify(error));
            this.isLoading = false;
        }
    }

    handleFolderClickSelect(event){
        event.preventDefault();
        this.isLoading = true;
        let details = event.detail;
        this.myBreadcrumbs.push({
            label : details.name,
            name : details.folderId,
            id: details.folderId
        })
        this.fetchFilesAndSubfolders(details.folderId);
    }
}