import { LightningElement, api, wire, track } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import batchUploadContentVersionsToDropbox from '@salesforce/apex/PS_ContentVersionDropboxUploader.batchUploadContentVersionsToDropbox';
import getStoredFiles from '@salesforce/apex/FileManagerController.getStoredFiles';
import listDropboxFiles from '@salesforce/apex/PS_ContentVersionDropboxUploader.listDropboxFiles';
import { NavigationMixin } from 'lightning/navigation';

const DELAY = 300;

export default class FileManager extends NavigationMixin(LightningElement) {

    @api recordId;
    @api recordName = 'Amazon.com';
    @api objectApiName;
    @api dropboxfolder = 'Amazon.com';

    dropboxFiles = [];
    storedFiles = [];
    error;
    storedFilesError;
    isLoading = true;
    isStoredFilesLoading = true;
    searchTerm = '';
    storedFilesSearchTerm = '';
    isTableView = true;
    isStoredFilesTableView = true;
    sortedBy = 'name';
    sortedDirection = 'asc';
    storedFilesSortedBy = 'Name';
    storedFilesSortedDirection = 'asc';
    showToast = false;
    toastMessage = '';
    toastVariant = 'success';
    wiredFilesResult;
    wiredStoredFilesResult;

    fileName = '';
    filesUploaded = [];
    fileSize;

    // Accepted file formats for upload
    get acceptedFormats() {
        return ['.pdf', '.png', '.jpg', '.jpeg', '.doc', '.docx', '.xls', '.xlsx', '.csv', '.txt'];
    }
    
    // Columns for Dropbox files table
    get columns() {
        return [
            { 
                label: 'File Name', 
                fieldName: 'name', 
                type: 'text',
                sortable: true
            },
            { 
                label: 'Path', 
                fieldName: 'path', 
                type: 'url',
                sortable: true,
                typeAttributes: {
                    label: { 
                        fieldName: 'name' 
                    },
                    target : '_blank'
                }
            },
            { 
                label: 'Size', 
                fieldName: 'formattedSize', 
                type: 'text',
                sortable: true
            },
            { 
                label: 'Last Modified', 
                fieldName: 'modifiedTime', 
                type: 'text',
                sortable: true
            }
        ];
    }
    
    // Columns for Stored files table
    get storedFilesColumns() {
        return [
            { 
                label: 'Name', 
                fieldName: 'Name', 
                type: 'text',
                sortable: true
            },
            { 
                label: 'Path', 
                fieldName: 'ServerUrl__c', 
                type: 'url',
                sortable: true
            },
            { 
                label: 'Size', 
                fieldName: 'File_Size__c', 
                type: 'text',
                sortable: true,
                typeAttributes: {
                    minimumIntegerDigits: 1,
                    minimumFractionDigits: 0,
                    maximumFractionDigits: 0
                },
                cellAttributes: { alignment: 'right' }
            }
        ];
    }
    
    // Button variants for view toggle
    get tilesViewBtnVariant() {
        return this.isTableView ? 'border' : 'border-filled';
    }
    
    get tableViewBtnVariant() {
        return this.isTableView ? 'border-filled' : 'border';
    }
    
    get storedFilesTilesViewBtnVariant() {
        return this.isStoredFilesTableView ? 'border' : 'border-filled';
    }
    
    get storedFilesTableViewBtnVariant() {
        return this.isStoredFilesTableView ? 'border-filled' : 'border';
    }
    
    // Check if files exist
    get hasDropboxFiles() {
        return this.dropboxFiles && this.dropboxFiles.length > 0;
    }
    
    get hasStoredFiles() {
        return this.storedFiles && this.storedFiles.length > 0;
    }
    
    // Filtered files based on search
    get filteredDropboxFiles() {
        if (!this.searchTerm) {
            return this.dropboxFiles;
        }
        
        const loweredSearchTerm = this.searchTerm.toLowerCase();
        return this.dropboxFiles.filter(file => 
            file.name.toLowerCase().includes(loweredSearchTerm) ||
            file.path.toLowerCase().includes(loweredSearchTerm)
        );
    }
    
    get filteredStoredFiles() {
        if (!this.storedFilesSearchTerm) {
            return this.storedFiles;
        }
        
        const loweredSearchTerm = this.storedFilesSearchTerm.toLowerCase();
        return this.storedFiles.filter(file => 
            file.Name.toLowerCase().includes(loweredSearchTerm) ||
            (file.Path__c && file.Path__c.toLowerCase().includes(loweredSearchTerm))
        );
    }
    
    // Toast related getters
    get toastClass() {
        return `slds-notify slds-notify_toast slds-theme_${this.toastVariant}`;
    }
    
    get toastIcon() {
        switch(this.toastVariant) {
            case 'success':
                return 'utility:success';
            case 'warning':
                return 'utility:warning';
            case 'error':
                return 'utility:error';
            default:
                return 'utility:info';
        }
    }
    
    // Load Dropbox files
    @wire(listDropboxFiles, { dropboxFolderPath: '$dropboxfolder' })
    wiredFiles(result) {
        this.wiredFilesResult = result;
        const { data, error } = result;
        this.isLoading = false;
        if (data) {
            console.log('Dropbox files:', JSON.stringify(data));
            this.dropboxFiles = data.map(file => {
                return {
                    ...file,
                    iconName: file.isFolder ? 'doctype:folder' : 'doctype:unknown',
                    fileType: file.isFolder ? 'Folder' : 'File',
                    formattedSize: file.isFolder ? '' : this.formatBytes(file.size),
                    path: `https://www.dropbox.com/home/${file.path}`,

                };
            });
            this.error = undefined;
        } else if (error) {
            this.error = 'Error loading Dropbox files: ' + error.body.message;
            this.dropboxFiles = [];
        }
    }
    
    // Load Stored files from DropBoxFile__c
    @wire(getStoredFiles, { accountId: '$recordId' })
    wiredStoredFiles(result) {
        this.wiredStoredFilesResult = result;
        const { data, error } = result;
        this.isStoredFilesLoading = false;
        
        if (data) {
            this.storedFiles = data;
            this.storedFiles = data.map(file => {
                return {
                    ...file,
                    File_Size__c: this.formatBytes(file.File_Size__c)
                }
            })
            this.storedFilesError = undefined;
        } else if (error) {
            this.storedFilesError = 'Error loading stored files: ' + error.body.message;
            this.storedFiles = [];
        }
    }
    
    // File upload handler
    handleUploadFinished(event) {
        console.log(JSON.stringify(event.detail));
        const uploadedFiles = event.detail.files;
        let fileIds = uploadedFiles.map(file => file.contentVersionId);
        this.isLoading = true;
        batchUploadContentVersionsToDropbox({ 
            contentVersionIds: fileIds,
            dropboxPath: `/${this.dropboxfolder}`
        })
        .then(result => {
            console.log('Upload result:', JSON.stringify(result));
            this.showNotification('Success', `${uploadedFiles.length} file(s) uploaded successfully`, 'success');
        })
        .catch(error => {
            console.error('Error:', error);
            this.showNotification('Error', 'Failed to upload files', 'error');
        })
        .finally(() => {
            this.isLoading = false;
        })
    }
    
    // Search handlers
    handleSearchChange(event) {
        this.searchTerm = event.target.value;
    }
    
    handleStoredFilesSearchChange(event) {
        this.storedFilesSearchTerm = event.target.value;
    }
    
    // View toggle handlers
    switchToTilesView() {
        this.isTableView = false;
    }
    
    switchToTableView() {
        this.isTableView = true;
    }
    
    switchToStoredFilesTilesView() {
        this.isStoredFilesTableView = false;
    }
    
    switchToStoredFilesTableView() {
        this.isStoredFilesTableView = true;
    }
    
    // Sort handlers
    handleSort(event) {
        this.sortedBy = event.detail.fieldName;
        this.sortedDirection = event.detail.sortDirection;
        this.sortData(this.sortedBy, this.sortedDirection);
    }
    
    handleStoredFilesSort(event) {
        this.storedFilesSortedBy = event.detail.fieldName;
        this.storedFilesSortedDirection = event.detail.sortDirection;
        this.sortStoredFilesData(this.storedFilesSortedBy, this.storedFilesSortedDirection);
    }
    
    sortData(fieldname, direction) {
        let parseData = JSON.parse(JSON.stringify(this.dropboxFiles));
        let keyValue = (a) => {
            return a[fieldname];
        };
        
        let isReverse = direction === 'asc' ? 1 : -1;
        parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : '';
            y = keyValue(y) ? keyValue(y) : '';
            
            return isReverse * ((x > y) - (y > x));
        });
        
        this.dropboxFiles = parseData;
    }
    
    sortStoredFilesData(fieldname, direction) {
        let parseData = JSON.parse(JSON.stringify(this.storedFiles));
        let keyValue = (a) => {
            return a[fieldname];
        };
        
        let isReverse = direction === 'asc' ? 1 : -1;
        parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : '';
            y = keyValue(y) ? keyValue(y) : '';
            
            return isReverse * ((x > y) - (y > x));
        });
        
        this.storedFiles = parseData;
    }
    
    // Refresh handlers
    refreshDropboxFiles() {
        this.isLoading = true;
        refreshApex(this.wiredFilesResult)
            .then(() => {
                this.showNotification('Success', 'Dropbox files refreshed', 'success');
            })
            .catch(error => {
                this.showNotification('Error', 'Failed to refresh Dropbox files', 'error');
            })
            .finally(() => {
                this.isLoading = false;
            });
    }
    
    refreshStoredFiles() {
        this.isStoredFilesLoading = true;
        refreshApex(this.wiredStoredFilesResult)
            .then(() => {
                this.showNotification('Success', 'Stored files refreshed', 'success');
            })
            .catch(error => {
                this.showNotification('Error', 'Failed to refresh stored files', 'error');
            })
            .finally(() => {
                this.isStoredFilesLoading = false;
            });
    }
    
    formatBytes(bytes,decimals=2) {
        if(bytes == 0) return '0 Bytes';
        var k = 1024,
            dm = decimals || 2,
            sizes = ['Bytes', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB'],
            i = Math.floor(Math.log(bytes) / Math.log(k));
        return parseFloat((bytes / Math.pow(k, i)).toFixed(dm)) + ' ' + sizes[i];
    }
    
    // Toast methods
    showNotification(title, message, variant) {
        this.toastTitle = title;
        this.toastMessage = message;
        this.toastVariant = variant;
        this.showToast = true;
        
        // Auto hide after 3 seconds
        setTimeout(() => {
            this.closeToast();
        }, 3000);
    }
    
    closeToast() {
        this.showToast = false;
    }
}