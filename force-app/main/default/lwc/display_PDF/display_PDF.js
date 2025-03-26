import { LightningElement, api } from 'lwc';

export default class display_PDF extends LightningElement {
    @api recordId; // Expose the record ID as a public property

    get iframeSrc() {
        // Construct the Visualforce page URL with the record ID parameter
        return `/apex/VF_Cotation?recordId=${this.recordId}`;
    }
}