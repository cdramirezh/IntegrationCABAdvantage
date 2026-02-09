import { LightningElement, api, wire, track } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import getEndorsementHistory from '@salesforce/apex/PolicyEndorsementController.getEndorsementHistory';
import getLatestEndorsements from '@salesforce/apex/PolicyEndorsementController.getLatestEndorsements';

const POLICY_FIELDS = ['Policy__c.Id'];

export default class PolicyEndorsementHistory extends LightningElement {
    @api recordId;
    @track endorsementHistory = [];
    @track latestEndorsements = [];
    @track isLoading = true;
    @track error;
    @track activeTab = 'latest';

    // Column definitions for the full history table
    VehicleTrailerHistoryColumns = [
        { 
            label: 'Endorsement Request', 
            fieldName: 'endorsementRequestName', 
            type: 'text',
            sortable: true
        },
        { 
            label: 'Effective Date', 
            fieldName: 'endorsementCreatedDate', 
            type: 'text',
            sortable: true
        },
        { 
            label: 'VIN', 
            fieldName: 'identifier', 
            type: 'text',
            sortable: true
        },        
        { 
            label: 'Make', 
            fieldName: 'make', 
            type: 'text',
            sortable: true
        },
        { 
            label: 'Year', 
            fieldName: 'year', 
            type: 'text',
            sortable: true
        },
        { 
            label: 'Value',
            fieldName: 'value',
            type: 'currency',
            sortable: true
        },
        { 
            label: 'Weight',
            fieldName: 'weight',
            type: 'number',
            sortable: true
        },
        { 
            label: 'Action', 
            fieldName: 'action', 
            type: 'text',
            sortable: true
        }
    ];

    DriverHistoryColumns = [
        { 
            label: 'Endorsement Request', 
            fieldName: 'endorsementRequestName', 
            type: 'text',
            sortable: true
        },
        { 
            label: 'Effective Date', 
            fieldName: 'endorsementCreatedDate', 
            type: 'text',
            sortable: true
        },
        { 
            label: 'CDL', 
            fieldName: 'identifier', 
            type: 'text',
            sortable: true
        },        
        { 
            label: 'Driver Name', 
            fieldName: 'drivername', 
            type: 'text',
            sortable: true
        },        
        { 
            label: 'Action', 
            fieldName: 'action', 
            type: 'text',
            sortable: true
        }
    ];    

    @wire(getRecord, { recordId: '$recordId', fields: POLICY_FIELDS })
    policy;

    connectedCallback() {
        this.loadEndorsementData();
    }

    async loadEndorsementData() {
        this.isLoading = true;
        this.error = null;

        try {
            // Load both history and latest endorsements in parallel
            const [historyResult, latestResult] = await Promise.all([
                getEndorsementHistory({ policyId: this.recordId }),
                getLatestEndorsements({ policyId: this.recordId })
            ]);

            this.endorsementHistory = this.formatEndorsementData(historyResult);
            this.latestEndorsements = this.formatEndorsementData(latestResult);

        } catch (error) {
            this.error = error.body ? error.body.message : error.message;
            console.error('Error loading endorsement data:', error);
        } finally {
            this.isLoading = false;
        }
    }

    formatEndorsementData(data) {
        return data.map(item => ({
            id: item.Id,
            endorsementRequestName: item.endorsementRequestName,
            endorsementCreatedDate: item.endorsementCreatedDate,
            recordType: item.recordType,
            identifier: item.identifier,
            make: item.Make || '', // Ensure Make is defined
            year: item.Year || '', // Ensure Year is defined
            value: item.Value || 0, // Ensure Value is defined
            weight: item.Weight || 0, // Ensure Weight is defined
            drivername: item.DriverName || '', // Ensure DriverName is defined
            action: item.action
        }));
    }

    handleTabChange(event) {
        this.activeTab = event.target.value;
    }

    get showHistory() {
        return this.activeTab === 'history';
    }

    get showLatest() {
        return this.activeTab === 'latest';
    }

    get hasHistoryData() {
        return this.endorsementHistory && this.endorsementHistory.length > 0;
    }

    get hasLatestData() {
        return this.latestEndorsements && this.latestEndorsements.length > 0;
    }

    get historyCount() {
        return this.endorsementHistory ? this.endorsementHistory.length : 0;
    }

    get latestCount() {
        return this.latestEndorsements ? this.latestEndorsements.length : 0;
    }

    //variables for buttons labels
    get FullHistoryLabel() {
        return this.historyCount > 0 ? `Endorsements Full History (${this.historyCount})` : 'Full History';  
    }
    get LatestLabel() {
        return this.latestCount > 0 ? `Final Endorsed List (${this.latestCount})` : 'Latest';
    }

    // computed filtered lists for each recordType (Vehicle, Trailer, Driver) 
    get vehicleHistory() {
    return this.endorsementHistory.filter(item => item.recordType === 'Vehicle');
    }

    get trailerHistory() {
        return this.endorsementHistory.filter(item => item.recordType === 'Trailer');
    }

    get driverHistory() {
        return this.endorsementHistory.filter(item => item.recordType === 'Driver');
    }

    get vehicleLatest() {
        return this.latestEndorsements.filter(item => item.recordType === 'Vehicle' && (item.action === 'Add' || item.action === 'Modify'));
    }

    get trailerLatest() {
        return this.latestEndorsements.filter(item => item.recordType === 'Trailer' && (item.action === 'Add' || item.action === 'Modify'));
    }

    get driverLatest() {
        return this.latestEndorsements.filter(item => item.recordType === 'Driver' && (item.action === 'Add' || item.action === 'Modify'));
    }

}