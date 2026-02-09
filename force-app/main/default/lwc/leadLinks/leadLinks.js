import { LightningElement, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import USDOT_FIELD from '@salesforce/schema/Lead.USDOT__c';

export default class LeadQuickLinks extends LightningElement {
    @api recordId; // Automatically populated on the Lead record page
    usdDot;

    @wire(getRecord, { recordId: '$recordId', fields: [USDOT_FIELD] })
    wiredLead({ error, data }) {
        if (data) {
            this.usdDot = data.fields.USDOT__c.value;
        } else if (error) {
            console.error('Error fetching Lead USDOT__c field:', error);
        }
    }

    // Dynamically construct the URLs
    get cabLink() {
        return this.usdDot
            ? `https://subscriber.cabadvantage.com/CABreport.cfm?dot=${this.usdDot}`
            : '';
    }

    get saferLink() {
        return this.usdDot
            ? `https://safer.fmcsa.dot.gov/query.asp?searchtype=ANY&query_type=queryCarrierSnapshot&query_param=USDOT&query_string=${this.usdDot}#Safety`
            : '';
    }

    get txdmvLink() {
        return this.usdDot
            ? `https://apps.txdmv.gov/APPS/MCCS/TRUCKSTOP/Certificate/Certificate_Search_Message.asp?search_customer_name=&search_dba_name=&search_us_dot_number=${this.usdDot}&search_certificate_nbr=&search_vin_number=&search_city=&search_zip=&search_carrier_type=`
            : '';
    }

    get sunbizlink() {
        return this.usdDot
            ? `https://search.sunbiz.org/Inquiry/CorporationSearch/ByName`
            : '';
    }

    get smslink() {
        return this.usdDot
            ? `https://ai.fmcsa.dot.gov/SMS/Home`
            : '';
    }

    get cadmvlink() {
        return this.usdDot
            ? `https://www.dmv.ca.gov/portal/vehicle-industry-services/motor-carrier-services-mcs/motor-carrier-permits/active-motor-carriers/`
            : '';
    }

    get vindecolink() {
        return this.usdDot
            ? `https://vpic.nhtsa.dot.gov/decoder/`
            : '';
    }

    get vantagelink() {
        return this.usdDot
            ? `https://www.vantageins.us/`
            : '';
    }

    
}