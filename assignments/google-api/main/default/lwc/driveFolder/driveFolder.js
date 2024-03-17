import { LightningElement, api } from 'lwc';

export default class DriveFolder extends LightningElement {
    @api folder;

    get icon() {
        return '/apexpages/slds/latest/assets/icons/doctype-sprite/svg/symbols.svg#folder';
    }

    handleClick(event){
        event.preventDefault();
        const selectedEvent = new CustomEvent("select", {
            detail: {
                name: this.folder.name,
                folderId: this.folder.itemId
            }
        });
        this.dispatchEvent(selectedEvent);
    }
}