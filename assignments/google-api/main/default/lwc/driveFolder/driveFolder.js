import { LightningElement, api } from 'lwc';

export default class DriveFolder extends LightningElement {
    @api folder;

    get icon() {
        return '/apexpages/slds/latest/assets/icons/doctype-sprite/svg/symbols.svg#folder';
    }
}