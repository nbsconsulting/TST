import { LightningElement, track, wire, api } from 'lwc';
import getLignes from '@salesforce/apex/LigneDeCotationController.getLignes';
import saveLignes from '@salesforce/apex/LigneDeCotationController.saveLignes';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import editableDataTable from '@salesforce/resourceUrl/editableDataTable';
import { loadStyle } from 'lightning/platformResourceLoader';
import { FlowAttributeChangeEvent, FlowNavigationNextEvent, FlowNavigationBackEvent } from 'lightning/flowSupport';

// Extend FlowNavigationMixin for Flow compatibility
export default class LigneDeCotationTable extends LightningElement {
    @api recordId; 
    @api availableActions = [];
    
    @track data = []; 
    @track selectedRecords = []; 
    @track draftValues = []; 
    @track searchKey = ''; 
    @track currencyCode = 'MAD'; 

    @track showFirstTable = true;
    @track showSecondTable = false;
    @track showSpinner = false;
    @track selectedRows = []; 
    @track hasError = false;
    @track errorMessage = '';

    @track columns1 = [
        { label: 'Designation', fieldName: 'Name', type: 'text' },
        { label: 'Entité Juridique', fieldName: 'Entite_Juridique__c', type: 'text' },
        { label: 'Distinct', fieldName: 'Distinct__c', type: 'text' }, 
        { label: 'TVA', fieldName: 'TVA__c', type: 'number' },
        { label: 'CTVA', fieldName: 'ctva__c', type: 'text' },
    ];

    @track columns2 = [
        { label: 'Article Name', fieldName: 'Name', type: 'text' },
        { label: 'Quantity', fieldName: 'Quantite__c', type: 'number', editable: true },
        { 
            label: 'Prix Unitaire', 
            fieldName: 'Prix__c', 
            type: 'currency', 
            editable: true,
            typeAttributes: { 
                currencyCode: 'MAD',
                currencyDisplayAs: 'code'
            }
        },
        { label: 'Commentaire', fieldName: 'Commentaire__c', type: 'text', editable: true },
        { 
            type: 'button',
            typeAttributes: { 
                label: 'Remove', 
                name: 'remove', 
                title: 'Remove', 
                variant: 'destructive', 
                class: 'slds-m-left_x-small' 
            }
        }
    ];

    connectedCallback() {
        loadStyle(this, editableDataTable)
            .catch(error => {
                console.error('Error loading styles:', error);
            });
        
        // Load data on initial connection
        this.loadData();
    }

    loadData() {
        this.showSpinner = true;
        getLignes({ recordId: this.recordId })
            .then(result => {
                if (result) {
                    this.data = result.articles || [];
                    this.currencyCode = result.currencyIsoCode || 'MAD';
                    
                    // Update the currency in the columns2 definition
                    const updatedColumns = [...this.columns2];
                    const currencyColIndex = updatedColumns.findIndex(col => col.fieldName === 'Prix__c');
                    if (currencyColIndex >= 0) {
                        updatedColumns[currencyColIndex] = {
                            ...updatedColumns[currencyColIndex],
                            typeAttributes: {
                                ...updatedColumns[currencyColIndex].typeAttributes,
                                currencyCode: this.currencyCode
                            }
                        };
                        this.columns2 = updatedColumns;
                    }
                }
            })
            .catch(error => {
                console.error('Error loading data:', error);
                this.hasError = true;
                this.errorMessage = error.body ? error.body.message : error.message;
            })
            .finally(() => {
                this.showSpinner = false;
            });
    }

    get filteredData() {
        return this.data.filter(record => {
            return record.Name.toLowerCase().includes(this.searchKey.toLowerCase());
        });
    }

    handleSearch(event) {
        this.searchKey = event.target.value;
    }

    handleRowSelection(event) {
        const selectedRows = event.detail.selectedRows;
        this.selectedRows = selectedRows.map(row => row.Id);

        selectedRows.forEach(row => {
            if (!this.selectedRecords.some(rec => rec.Id === row.Id)) {
                this.selectedRecords.push({
                    Id: row.Id,
                    Name: row.Name,
                    Quantite__c: null,
                    Prix__c: null,
                    Commentaire__c: null
                });
            }
        });

        // Remove deselected rows
        this.selectedRecords = this.selectedRecords.filter(row => this.selectedRows.includes(row.Id));
    }

    handleCellChange(event) {
        const draftValues = event.detail.draftValues;
        if (draftValues && draftValues.length > 0) {
            draftValues.forEach(updatedItem => {
                const rowId = updatedItem.Id;
                this.selectedRecords = this.selectedRecords.map(row => {
                    if (row.Id === rowId) {
                        return { ...row, ...updatedItem };
                    }
                    return row;
                });
            });
        }
    }

    handleNext() {
        if (this.selectedRows.length === 0) {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error',
                message: 'Please select at least one record before proceeding.',
                variant: 'error'
            }));
            return;
        }
    
        this.showSpinner = true;
        setTimeout(() => {
            this.showFirstTable = false;
            this.showSecondTable = true;
            this.showSpinner = false;
        }, 500);
    }

    handlePrevious() {
        this.showSpinner = true;
        setTimeout(() => {
            this.showFirstTable = true;
            this.showSecondTable = false;
            this.showSpinner = false;
        }, 500);
    }

    handleRowAction(event) {
        if (event.detail.action.name === 'remove') {
            const rowId = event.detail.row.Id;
            this.selectedRecords = this.selectedRecords.filter(row => row.Id !== rowId);
            this.selectedRows = this.selectedRows.filter(id => id !== rowId);
        }
    }

    handleSave() {
        let validationError = false;
        this.selectedRecords.forEach(row => {
            if (!row.Quantite__c || !row.Prix__c) {
                validationError = true;
            }
        });
    
        if (validationError) {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error',
                message: 'All input fields (Quantity & Price) are required before saving.',
                variant: 'error'
            }));
            return;
        }
    
        this.showSpinner = true;
        
        const lignes = this.selectedRecords.map(row => ({
            Article__c: row.Id,
            Cotation__c: this.recordId,
            Quantite__c: row.Quantite__c,
            Prix__c: row.Prix__c,
            Commentaire__c: row.Commentaire__c,
            CurrencyIsoCode: this.currencyCode
        }));
    
        saveLignes({ lignes })
            .then(() => {
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Success',
                    message: 'Lignes de cotation saved successfully!',
                    variant: 'success'
                }));
                this.refreshComponent();
            })
            .catch(error => {
                console.error('Error saving records:', error);
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Error',
                    message: error.body.message,
                    variant: 'error'
                }));
            });
    }

    handleCancel() {
        this.selectedRecords = [];
        this.refreshComponent();
    }

    refreshComponent() {
        try {
            eval("$A.get('e.force:refreshView').fire();");
        } catch (e) {
            window.location.reload();
        }
    }
}