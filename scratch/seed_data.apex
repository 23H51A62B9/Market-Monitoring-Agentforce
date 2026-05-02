// Seed Data for Market Monitoring Agent Hackathon

// 1. Create a Market Event
Market_Event__c setupEvent = new Market_Event__c(
    Event_Title__c = 'Flash Tech Correction 2026',
    Event_Date__c = DateTime.now(),
    Event_Type__c = 'Equity Market Crash',
    Severity_Level__c = 'Critical',
    Affected_Asset_Class__c = 'Equity',
    Affected_Sectors__c = 'IT;Banking',
    Market_Summary__c = 'A sudden liquidity crunch in global tech stocks has triggered a 5% drop in Nasdaq, impacting Indian IT ADRs and local banking liquidity.',
    Recommended_Action__c = 'Review',
    Is_Active__c = true
);
insert setupEvent;

// 2. Create Sample Clients (Accounts)
// Using Person Accounts if available, or just regular Accounts for testing
List<Account> testClients = new List<Account>();
testClients.add(new Account(Name = 'Alok Sharma', Phone = '+919988776655'));
testClients.add(new Account(Name = 'Priyanaka Desai', Phone = '+919988776644'));
testClients.add(new Account(Name = 'Rohan Mehta', Phone = '+919988776633'));
testClients.add(new Account(Name = 'Siddharth Vats', Phone = '+919988776622'));
testClients.add(new Account(Name = 'Meera Kapoor', Phone = '+919988776611'));
insert testClients;

// 3. Create Communication Preferences
List<Client_Comm_Preference__c> prefs = new List<Client_Comm_Preference__c>();
for(Account acc : testClients) {
    prefs.add(new Client_Comm_Preference__c(
        Client__c = acc.Id,
        Preferred_Channel__c = 'WhatsApp',
        WhatsApp_Number__c = acc.Phone,
        Language_Preference__c = 'English',
        Opt_In_WhatsApp__c = true
    ));
}
insert prefs;

// 4. Create Portfolio Snapshots
List<Client_Portfolio_Snapshot__c> snaps = new List<Client_Portfolio_Snapshot__c>();

// High Equity Impact (Alok)
snaps.add(new Client_Portfolio_Snapshot__c(
    Client__c = testClients[0].Id,
    Snapshot_Date__c = Date.today(),
    Total_AUM__c = 5000000,
    Equity_Exposure_Pct__c = 75,
    Debt_Exposure_Pct__c = 15,
    Gold_Exposure_Pct__c = 10,
    Risk_Score__c = 8,
    Top_Sector_1__c = 'IT',
    Top_Sector_2__c = 'Banking'
));

// High Equity Impact (Priyanka)
snaps.add(new Client_Portfolio_Snapshot__c(
    Client__c = testClients[1].Id,
    Snapshot_Date__c = Date.today(),
    Total_AUM__c = 12000000,
    Equity_Exposure_Pct__c = 60,
    Debt_Exposure_Pct__c = 30,
    Gold_Exposure_Pct__c = 10,
    Risk_Score__c = 7,
    Top_Sector_1__c = 'Banking',
    Top_Sector_2__c = 'Pharma'
));

// Low Impact (Rohan)
snaps.add(new Client_Portfolio_Snapshot__c(
    Client__c = testClients[2].Id,
    Snapshot_Date__c = Date.today(),
    Total_AUM__c = 3000000,
    Equity_Exposure_Pct__c = 10,
    Debt_Exposure_Pct__c = 80,
    Gold_Exposure_Pct__c = 10,
    Risk_Score__c = 3,
    Top_Sector_1__c = 'Debt',
    Top_Sector_2__c = 'Gold'
));

// Medium Impact (Siddharth)
snaps.add(new Client_Portfolio_Snapshot__c(
    Client__c = testClients[3].Id,
    Snapshot_Date__c = Date.today(),
    Total_AUM__c = 8500000,
    Equity_Exposure_Pct__c = 40,
    Debt_Exposure_Pct__c = 50,
    Gold_Exposure_Pct__c = 10,
    Risk_Score__c = 5,
    Top_Sector_1__c = 'IT',
    Top_Sector_2__c = 'Auto'
));

insert snaps;

System.debug('Seeding Complete! Market Event ID: ' + setupEvent.Id);
