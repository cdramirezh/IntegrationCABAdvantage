import { LightningElement, api } from 'lwc';

export default class RecordDisplayComponent extends LightningElement {
    // Public properties to receive data from Flow
    @api coverageRecords = [];
    @api vehicleRecords = [];
    @api policyVehicleRecords = [];
    @api trailerRecords = [];
    @api policyTrailerRecords = [];
    @api driverRecords = [];
    @api policyDriverRecords = [];
    
    // Labels for the sections
    @api coverageLabel = 'Coverage Records';
    @api vehicleLabel = 'Vehicle Records';
    @api trailerLabel = 'Trailer Records';
    @api driverLabel = 'Driver Records';
    
    // Control visibility of sections
    @api showCoverage;
    @api showVehicle;
    @api showTrailer;
    @api showDriver;

    // Getters to process and format the data
    get processedCoverageRecords() {
        return this.processRecords(this.coverageRecords);
    }

    get processedVehicleRecords() {
        return this.processRecords(this.policyVehicleRecords);
    }

    get processedTrailerRecords() {
        return this.processRecords(this.policyTrailerRecords);
    }

    get processedDriverRecords() {
        return this.processRecords(this.policyDriverRecords);
    }

    // Helper method to process records and extract key fields
    processRecords(records) {
        if (!records || !Array.isArray(records)) {
            return [];
        }

        return records.map(record => {
            const processedRecord = {
                Id: record.Id,
                Name: record.Name || 'N/A',
                ProductName: record.Coverage_Product_Name__c || 'N/A',
                ProductLimit: record.Limit__c || 'N/A',
                ProductDeductible: record.Deductible__c || 'N/A',               
                VehicleVIN: record.Vehicle_VIN__c || 'N/A',
                VehicleMake: record.Vehicle_Make__c || 'N/A',
                VehicleYear: record.Vehicle_Year__c || 'N/A',
                TrailerVIN: record.Trailer_VIN__c || 'N/A',
                TrailerMake: record.Trailer_Make__c || 'N/A',
                TrailerYear: record.Trailer_Year__c || 'N/A',
                DriverName: record.Driver_Name__c || 'N/A',
                DriverCDL: record.Driver_CDL__c || 'N/A',
                //fields: []
            };

            return processedRecord;
        }
        );

    }
            /*
            // Extract all non-system fields for display
            Object.keys(record).forEach(key => {
                if (this.shouldDisplayField(key)) {
                    processedRecord.fields.push({
                        label: this.formatFieldLabel(key),
                        value: this.formatFieldValue(record[key]),
                        apiName: key
                    });
                }
            });

            return processedRecord;
        });
    }

    // Determine which fields to display (exclude system fields)
    shouldDisplayField(fieldName) {
        const systemFields = [
            'Id', 'CreatedDate', 'CreatedById', 'LastModifiedDate', 
            'LastModifiedById', 'SystemModstamp', 'IsDeleted', 'Name',
            'Coverage_Product_Name__c',
            'Vehicle_VIN__c', 'Trailer_VIN__c', 
            'Driver_Name__c'

        ];
        return !systemFields.includes(fieldName);
    }

    // Format field labels for display
    formatFieldLabel(fieldName) {
        return fieldName
            .replace(/([A-Z])/g, ' $1')
            .replace(/^./, str => str.toUpperCase())
            .replace(/__c$/, '')
            .trim();
    }

    // Format field values for display
    formatFieldValue(value) {
        if (value === null || value === undefined) {
            return 'N/A';
        }
        if (typeof value === 'boolean') {
            return value ? 'Yes' : 'No';
        }
        if (typeof value === 'object' && value.displayValue) {
            return value.displayValue;
        }
        return String(value);
    }
    */

    // Check if any records exist
    get hasCoverageRecords() {
        return (this.showCoverage !== false) && this.processedCoverageRecords.length > 0;
    }

    get hasVehicleRecords() {
        return (this.showVehicle !== false) && this.processedVehicleRecords.length > 0;
    }

    get hasTrailerRecords() {
        return (this.showTrailer !== false) && this.processedTrailerRecords.length > 0;
    }

    get hasDriverRecords() {
        return (this.showDriver !== false) && this.processedDriverRecords.length > 0;
    }

    get hasAnyRecords() {
        return this.hasCoverageRecords || this.hasVehicleRecords || 
               this.hasTrailerRecords || this.hasDriverRecords;
    }
}