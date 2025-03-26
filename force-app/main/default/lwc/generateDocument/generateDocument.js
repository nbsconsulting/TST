import { LightningElement, api, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import Type_de_document from '@salesforce/schema/Account.Type_de_document__c';
import { loadStyle } from 'lightning/platformResourceLoader';
const fields = [Type_de_document];


export default class GenerateDocument extends LightningElement {

    isRendered = false;
    selectedVFPage;
    vfPageURL;
    @api recordId;
    vfPageOptions = [];
   
    @wire(getRecord, { recordId: '$recordId', fields })
    account({ data, error }) {
        if (data) 
        {
            this.accountRecordTypeId = '012000000000000AAA';
           
        } else if (error) 
        {
            console.error('Error fetching account record:', error);
        }
    }



    connectedCallback(){
        console.log('test');
    }

    handlePageSelection(event){
    
        this.selectedVFPage = event.detail.value;
        console.log('selectedVFPage', this.selectedVFPage)
        if (this.selectedVFPage == 'Account_Form') 
        {
            this.vfPageURL = `/apex/${this.selectedVFPage}?Id=${this.recordId}`;
            console.log('vf url :',this.vfPageURL)
        } 
        else if(this.selectedVFPage == 'Contrat_de_service')
        {
            this.vfPageURL = `/apex/${this.selectedVFPage}?Id=${this.recordId}`;

        }

    }

    renderedCallback(){
        if(!this.isRendered)
        {
            this.isRendered = true;
            this.vfPageOptions = 
            [
                { label: 'Fiche client', value: 'Account_Form' },
                { label: 'Contrat de service', value: 'Contrat_de_service' }
            ];            
        }
    }


 
    
}