public with sharing class GuidelineSearchController {
    public List<Guideline__c> guidelines { get; set; }

    public String selectedMarket { get; set; }
    public String selectedState { get; set; }
    public String selectedTypeOfUnit { get; set; }
    public String selectedUnitAge { get; set; }
    public String selectedCommodities { get; set; }
    public String selectedCDLExperience { get; set; }
    public String selectedInternationalDriver { get; set; }
    public String selectedUSDriver { get; set; }
    public String selectedTypeOfBusiness { get; set; }
    public String selectedMGA { get; set; }
    public String selectedInsurance { get; set; }

    public List<SelectOption> marketOptions { get; set; }
    public List<SelectOption> stateOptions { get; set; }
    public List<SelectOption> unitOptions { get; set; }
    public List<SelectOption> ageOptions { get; set; }
    public List<SelectOption> commoditiesOptions { get; set; }
    public List<SelectOption> cdlOptions { get; set; }
    public List<SelectOption> InternationalDriverOptions { get; set; }
    public List<SelectOption> businessOptions { get; set; }
    public List<SelectOption> mgaOptions { get; set; }
    public List<SelectOption> insuranceOptions { get; set; }

    public GuidelineSearchController() {
        guidelines = new List<Guideline__c>();

        mgaOptions = new List<SelectOption>{
            new SelectOption('', '-- All --'),
            new SelectOption('AmWINS', 'AmWINS'),
            new SelectOption('Appalachian', 'Appalachian (APPUND)'),
            new SelectOption('Berkshire', 'Berkshire'),
            new SelectOption('Blackmoor', 'Blackmoor'),
            new SelectOption('CountyHall', 'County Hall'),
            new SelectOption('CoverWhale', 'CoverWhale'),
            new SelectOption('FirstLight', 'First Light'),
            new SelectOption('RTSpecialty', 'RT Specialty'),
            new SelectOption('StarMutual', 'Star Mutual'),
            new SelectOption('GSIAY', 'GSIAY'),
            new SelectOption('GEICO', 'GEICO'),
            new SelectOption('NTA', 'NTA'),
            new SelectOption('ONE80', 'ONE80'),
            new SelectOption('Universal', 'Universal'),
            new SelectOption('MTM', 'MTM'),
            new SelectOption('CRC', 'CRC'),
            new SelectOption('Progressive', 'Progressive'),
            new SelectOption('Maximum', 'Maximum'),
            new SelectOption('Coverbadger', 'Coverbadger'),
            new SelectOption('FuturisticUW', 'Futuristic UW')
        };

        insuranceOptions = new List<SelectOption>{
            new SelectOption('', '-- All --'),
            new SelectOption('Canal', 'Canal'),
            new SelectOption('Northland', 'Northland'),
            new SelectOption('IAT', 'IAT (Occidental)'),
            new SelectOption('CrumForster', 'Crum & Forster'),
            new SelectOption('BerkleyPrime', 'Berkley Prime Transportation (Fleets)'),
            new SelectOption('BerkleySmall', 'Berkley Small Business'),
            new SelectOption('Nico', 'Nico'),
            new SelectOption('NirvanaNonFleet', 'Nirvana Non Fleet'),
            new SelectOption('NirvanaFleet', 'Nirvana Fleet Program'),
            new SelectOption('Southwind', 'Southwind'),
            new SelectOption('BulldogRRG', 'Bulldog RRG'),
            new SelectOption('DumpTruck', 'Dump Truck Program'),
            new SelectOption('BerkshireDirect', 'Berkshire Direct'),
            new SelectOption('ProfessionalTransport', 'Professional Transportation RRG'),
            new SelectOption('CountyHall', 'County Hall'),
            new SelectOption('Everspan', 'Everspan'),
            new SelectOption('Ascot', 'Ascot'),
            new SelectOption('Knight', 'Knight'),
            new SelectOption('Trisura', 'Trisura'),
            new SelectOption('Accredited', 'Accredited'),
            new SelectOption('Navigators', 'Navigators'),
            new SelectOption('StarMutual', 'Star Mutual'),
            new SelectOption('Trailblazers', 'Trailblazers'),
            new SelectOption('Geico', 'Geico'),
            new SelectOption('Southlake', 'Southlake'),
            new SelectOption('KnightSpecialty', 'Knight Specialty'),
            new SelectOption('UniversalCasualty', 'Universal Casualty'),
            new SelectOption('MotorTransport', 'Motor Transport Mutual'),
            new SelectOption('TrisuraBE', 'Trisura (Policy#BE)'),
            new SelectOption('Progressive', 'Progressive'),
            new SelectOption('Prime', 'Prime'),
            new SelectOption('Interline', 'Interline'),
            new SelectOption('Qualitas', 'Qualitas')
        };

        marketOptions = new List<SelectOption>{
            new SelectOption('', '-- All --'),
            new SelectOption('GL', 'General Liability - GL'),
            new SelectOption('MTC', 'Motor Truck Cargo - MTC'),
            new SelectOption('TI', 'Trailer Interchange - TI'),
            new SelectOption('NTL', 'Non-Trucking Liability - NTL'),
            new SelectOption('PD', 'Physical Damage - PD'),
            new SelectOption('WC', 'Workers Compensation - WC')
        };

        // Example hardcoded lists (these could also be pulled from custom metadata or settings)
        stateOptions = new List<SelectOption>{
            new SelectOption('', '-- All States --'),
            new SelectOption('AL', 'Alabama - AL'),
            new SelectOption('AK', 'Alaska - AK'),
            new SelectOption('AZ', 'Arizona - AZ'),
            new SelectOption('AR', 'Arkansas - AR'),
            new SelectOption('CA', 'California - CA'),
            new SelectOption('CO', 'Colorado - CO'),
            new SelectOption('CT', 'Connecticut - CT'),
            new SelectOption('DE', 'Delaware - DE'),
            new SelectOption('DC', 'District of Columbia - DC'),
            new SelectOption('FL', 'Florida - FL'),
            new SelectOption('GA', 'Georgia - GA'),
            new SelectOption('HI', 'Hawaii - HI'),
            new SelectOption('ID', 'Idaho - ID'),
            new SelectOption('IL', 'Illinois - IL'),
            new SelectOption('IN', 'Indiana - IN'),
            new SelectOption('IA', 'Iowa - IA'),
            new SelectOption('KS', 'Kansas - KS'),
            new SelectOption('KY', 'Kentucky - KY'),
            new SelectOption('LA', 'Louisiana - LA'),
            new SelectOption('ME', 'Maine - ME'),
            new SelectOption('MD', 'Maryland - MD'),
            new SelectOption('MA', 'Massachusetts - MA'),
            new SelectOption('MI', 'Michigan - MI'),
            new SelectOption('MN', 'Minnesota - MN'),
            new SelectOption('MS', 'Mississippi - MS'),
            new SelectOption('MO', 'Missouri - MO'),
            new SelectOption('MT', 'Montana - MT'),
            new SelectOption('NE', 'Nebraska - NE'),
            new SelectOption('NV', 'Nevada - NV'),
            new SelectOption('NH', 'New Hampshire - NH'),
            new SelectOption('NJ', 'New Jersey - NJ'),
            new SelectOption('NM', 'New Mexico - NM'),
            new SelectOption('NY', 'New York - NY'),
            new SelectOption('NC', 'North Carolina - NC'),
            new SelectOption('ND', 'North Dakota - ND'),
            new SelectOption('OH', 'Ohio - OH'),
            new SelectOption('OK', 'Oklahoma - OK'),
            new SelectOption('OR', 'Oregon - OR'),
            new SelectOption('PA', 'Pennsylvania - PA'),
            new SelectOption('RI', 'Rhode Island - RI'),
            new SelectOption('SC', 'South Carolina - SC'),
            new SelectOption('SD', 'South Dakota - SD'),
            new SelectOption('TN', 'Tennessee - TN'),
            new SelectOption('TX', 'Texas - TX'),
            new SelectOption('UT', 'Utah - UT'),
            new SelectOption('VT', 'Vermont - VT'),
            new SelectOption('VA', 'Virginia - VA'),
            new SelectOption('WA', 'Washington - WA'),
            new SelectOption('WV', 'West Virginia - WV'),
            new SelectOption('WI', 'Wisconsin - WI'),
            new SelectOption('WY', 'Wyoming - WY')
        };

        /*
        unitOptions = new List<SelectOption>{
            new SelectOption('', '-- Select --'),
            new SelectOption('Box Truck', 'Box Truck'),
            new SelectOption('Semi', 'Semi'),
            new SelectOption('Pickup', 'Pickup'),
            new SelectOption('Flatbed', 'Flatbed')
        };
        */

        unitOptions = new List<SelectOption>{
            new SelectOption('', '-- All --'),
            new SelectOption('Box Truck', 'Box Truck'),
            new SelectOption('Semi', 'Semi'),
            new SelectOption('Pickup', 'Pickup'),
            new SelectOption('Flatbed', 'Flatbed'),
            new SelectOption('Bus', 'Buses'),
            new SelectOption('Cargo Vans', 'Cargo Vans'),
            new SelectOption('Dump Trucks', 'Dump Trucks'),
            new SelectOption('Straight Trucks', 'Straight Trucks'),
            new SelectOption('Tank', 'Tank'),
            new SelectOption('Tow Trucks', 'Tow Trucks'),
            new SelectOption('Vans', 'Vans')
        };

        ageOptions = new List<SelectOption>{
            new SelectOption('', '-- Any Age --'),
            new SelectOption('25 Years', '25 Years maximum'),
            new SelectOption('20 Years', '20 Years maximum')
        };

        /*
        commoditiesOptions = new List<SelectOption>{
            new SelectOption('', '-- Select --'),
            new SelectOption('General Freight', 'General Freight'),
            new SelectOption('Refrigerated', 'Refrigerated'),
            new SelectOption('Hazmat', 'Hazmat')
        };
        */

        commoditiesOptions = new List<SelectOption>{
            new SelectOption('', '-- All --'),
            new SelectOption('General Freight', 'General Freight'),
            new SelectOption('Reefer', 'Reefer'),
            new SelectOption('Hazmat', 'Hazmat'),
            new SelectOption('Dry Van', 'Dry Van'),
            new SelectOption('Flatbed', 'Flatbed'),
            new SelectOption('Auto Hauler', 'Auto Hauler'),
            new SelectOption('Intermodal', 'Intermodal'),
            new SelectOption('Dump', 'Dump'),
            new SelectOption('Livestock', 'Livestock'),
            new SelectOption('Dirt Sand & Gravel', 'Dirt Sand & Gravel'),
            new SelectOption('Grain, Feed & Hay', 'Grain, Feed & Hay'),
            new SelectOption('Boat Hauler', 'Boat Hauler'),
            new SelectOption('Tank Hauler', 'Tank Hauler'),
            new SelectOption('Milk', 'Milk'),
            new SelectOption('Frac Sand', 'Frac Sand'),
            new SelectOption('Water', 'Water'),
            new SelectOption('Asphalt', 'Asphalt'),
            new SelectOption('Aggregate', 'Aggregate'),
            new SelectOption('Towing', 'Towing'),
            new SelectOption('Containers (No UIIA)', 'Containers (No UIIA)'),
            new SelectOption('Metal Sheet & Rolls', 'Metal Sheet & Rolls'),
            new SelectOption('Scrap Metal', 'Scrap Metal'),
            new SelectOption('Household Goods', 'Household Goods'),
            new SelectOption('Agricultural', 'Agricultural'),
            new SelectOption('Bulk Cement', 'Bulk Cement'),
            new SelectOption('Logging', 'Logging'),
            new SelectOption('Oversize & Overweight', 'Oversize & Overweight'),
            new SelectOption('Garbage Haulers', 'Garbage Haulers'),
            new SelectOption('Cement', 'Cement'),
            new SelectOption('Steel', 'Steel'),
            new SelectOption('Oilfield Equipment', 'Oilfield Equipment'),
            new SelectOption('Bulk Commodities', 'Bulk Commodities')
        };

        /*
        cdlOptions = new List<SelectOption>{
            new SelectOption('', '-- Select --'),
            new SelectOption('0 years', '0 years'),
            new SelectOption('1 year', '1 year'),
            new SelectOption('2+ years', '2+ years')
        };
        */

        cdlOptions = new List<SelectOption>{
            new SelectOption('', '-- All --'),
            new SelectOption('0', '0 years experience'),
            new SelectOption('1 year', '1 year CDL experience'),
            new SelectOption('2 year', '2 years CDL experience'),
            new SelectOption('5+ year', '5+ years of experience'),
            new SelectOption('Canadian Licenses accepted', 'Canadian Licenses accepted (with CDL)')
        };

        InternationalDriverOptions = new List<SelectOption>{
            new SelectOption('', '-- All --'),
            new SelectOption('Yes', 'Yes'),
            new SelectOption('No', 'No')
        };

        businessOptions = new List<SelectOption>{
            new SelectOption('', '-- All --'),
            new SelectOption('New Venture', 'New Venture'),
            new SelectOption('Renewal', 'Renewal')
        };
    }

    public void searchGuidelines() {
        String query = 'SELECT 	Name, MGA_Company_T__c, Insurance_Company_T__c, Market__c, Available_States__c, Business_Tenure__c, Type_of_Units__c, Unit_Age__c, Commodities__c, CDL_Experience__c, Driver_Age__c, Amount_of_units__c, Radius__c, CAB_Score__c, IFTAS_required__c, International_Drivers__c, Team_Driving__c, Documents_Required__c, Online_System__c, BOR__c, ELD_required__c FROM Guideline__c WHERE Id != null';

        if (!String.isBlank(selectedMGA)) {
            query += ' AND MGA_Company_T__c LIKE \'%' + String.escapeSingleQuotes(selectedMGA) + '%\'';
        }
        if (!String.isBlank(selectedInsurance)) {
            query += ' AND Insurance_Company_T__c LIKE \'%' + String.escapeSingleQuotes(selectedInsurance) + '%\'';
        }
        if (!String.isBlank(selectedMarket)) {
            query += ' AND Market__c LIKE \'%' + String.escapeSingleQuotes(selectedMarket) + '%\'';
        }
        if (!String.isBlank(selectedState)) {
            query += ' AND Available_States__c LIKE \'%' + String.escapeSingleQuotes(selectedState) + '%\'';
        }
        if (!String.isBlank(selectedTypeOfUnit)) {
            query += ' AND Type_of_Units__c LIKE \'%' + String.escapeSingleQuotes(selectedTypeOfUnit) + '%\'';
        }
        if (!String.isBlank(selectedUnitAge)) {
            query += ' AND Unit_Age__c LIKE \'%' + String.escapeSingleQuotes(selectedUnitAge) + '%\'';
        }
        if (!String.isBlank(selectedCommodities)) {
            query += ' AND Commodities__c LIKE \'%' + String.escapeSingleQuotes(selectedCommodities) + '%\'';
        }
        if (!String.isBlank(selectedCDLExperience)) {
            query += ' AND CDL_Experience__c LIKE \'%' + String.escapeSingleQuotes(selectedCDLExperience) + '%\'';
        }
        if (!String.isBlank(selectedInternationalDriver)) {
            query += ' AND International_Drivers__c LIKE \'%' + String.escapeSingleQuotes(selectedInternationalDriver) + '%\'';
        }
        if (!String.isBlank(selectedUSDriver)) {
            query += ' AND Driver_Age__c LIKE \'%' + String.escapeSingleQuotes(selectedUSDriver) + '%\'';
        }
        if (!String.isBlank(selectedTypeOfBusiness)) {
            query += ' AND Business_Tenure__c LIKE \'%' + String.escapeSingleQuotes(selectedTypeOfBusiness) + '%\'';
        }

        guidelines = Database.query(query);
    }
}