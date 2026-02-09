import { LightningElement, api, wire } from 'lwc';
import getLeadDocuments from '@salesforce/apex/LeadDocumentController.getLeadDocuments';

const columns = [
    { label: 'Document Type', fieldName: 'Type__c' },
    { label: 'Document Name', fieldName: 'NameUrl', type: 'url', typeAttributes: { label: { fieldName: 'Name' }, target: '_blank' } }
];

export default class LeadDocuments extends LightningElement {
    @api recordId;
    docPackages = [];
    columns = columns;

    @wire(getLeadDocuments, { leadId: '$recordId' })
    wiredDocPackages({ error, data }) {
        if (data) {
            this.docPackages = data.map(docPackage => {
                if (docPackage.Documents__r) {
                    return {
                        ...docPackage,
                        Documents__r: docPackage.Documents__r.map(document => {
                            return {
                                ...document,
                                NameUrl: `/${document.Id}`, // URL for the document record
                                Name: document.Name // Original name for display
                            };
                        })
                    };
                }
                return docPackage;
            });
        } else if (error) {
            console.error(error);
        }
    }
}