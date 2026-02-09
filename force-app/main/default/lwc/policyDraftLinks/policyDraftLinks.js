import { LightningElement, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import LEAD_FIELD from '@salesforce/schema/Policy_Draft__c.Lead__c';
import OPPORTUNITY_FIELD from '@salesforce/schema/Policy_Draft__c.Opportunity__c';
import USDOT_FIELD_LEAD from '@salesforce/schema/Lead.USDOT__c';
import USDOT_FIELD_OPPORTUNITY from '@salesforce/schema/Opportunity.USDOT__c';

export default class PolicyDraftLinks extends LightningElement {
    @api recordId; // Policy_Draft__c record ID
    leadId;
    opportunityId;
    usdDot;

    // Fetch Lead__c and Opportunity__c from Policy_Draft__c
    @wire(getRecord, { recordId: '$recordId', fields: [LEAD_FIELD, OPPORTUNITY_FIELD] })
    wiredPolicyDraft({ error, data }) {
        if (data) {
            this.leadId = data.fields.Lead__c?.value;
            this.opportunityId = data.fields.Opportunity__c?.value;
        } else if (error) {
            console.error('Error fetching Policy_Draft__c fields:', error);
        }
    }

    // Fetch USDOT__c from Opportunity if Opportunity__c is populated
    @wire(getRecord, { recordId: '$opportunityId', fields: [USDOT_FIELD_OPPORTUNITY] })
    wiredOpportunity({ error, data }) {
        if (data) {
            this.usdDot = data.fields.USDOT__c?.value;
        } else if (error) {
            console.error('Error fetching Opportunity USDOT__c field:', error);
        }
    }

    // Fetch USDOT__c from Lead if Opportunity__c is not populated
    @wire(getRecord, { recordId: '$leadId', fields: [USDOT_FIELD_LEAD] })
    wiredLead({ error, data }) {
        if (data && !this.usdDot) {  // Only set USDOT from Lead if it's not already set from Opportunity
            this.usdDot = data.fields.USDOT__c?.value;
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
        return `https://search.sunbiz.org/Inquiry/CorporationSearch/ByName`;
    }

    get smslink() {
        return `https://ai.fmcsa.dot.gov/SMS/Home`;
    }

    get cadmvlink() {
        return `https://www.dmv.ca.gov/portal/vehicle-industry-services/motor-carrier-services-mcs/motor-carrier-permits/active-motor-carriers/`;
    }

    get vindecolink() {
        return `https://vpic.nhtsa.dot.gov/decoder/`;
    }

    get vantagelink() {
        return `https://www.vantageins.us/`;
    }
}