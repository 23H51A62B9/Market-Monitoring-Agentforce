List<Individual> clients = new List<Individual>();
clients.add(new Individual(FirstName='Ankitha', LastName='Ravella'));
clients.add(new Individual(FirstName='Hanmanthu', LastName='Lavudya'));
clients.add(new Individual(FirstName='Prasanna', LastName='Kamallapally'));
clients.add(new Individual(FirstName='Manvitha', LastName='Narmeta'));
clients.add(new Individual(FirstName='Sthvika', LastName='Koleti'));
insert clients;

List<Account> accounts = new List<Account>();
for(Individual client : clients) {
    accounts.add(new Account(Name=client.FirstName + ' ' + client.LastName + ' - Wealth Account'));
}
insert accounts;

List<SObject> prefs = new List<SObject>();
List<SObject> snaps = new List<SObject>();

Decimal[] aums = new Decimal[]{5000000, 2500000, 8000000, 1500000, 12000000};
Decimal[] risks = new Decimal[]{8, 5, 9, 3, 7};
Decimal[] equities = new Decimal[]{85, 40, 90, 20, 75};
String[] channels = new String[]{'WhatsApp', 'Email', 'WhatsApp', 'SMS', 'WhatsApp'};

for(Integer i=0; i<accounts.size(); i++) {
    SObject pref = (SObject)Type.forName('Client_Comm_Preference__c').newInstance();
    pref.put('Client__c', accounts[i].Id);
    pref.put('Preferred_Channel__c', channels[i]);
    pref.put('WhatsApp_Number__c', '+155500010' + i);
    prefs.add(pref);
    
    SObject snap = (SObject)Type.forName('Client_Portfolio_Snapshot__c').newInstance();
    snap.put('Client__c', accounts[i].Id);
    snap.put('Snapshot_Date__c', Date.today());
    snap.put('Total_AUM__c', aums[i]);
    snap.put('Equity_Exposure_Pct__c', equities[i]);
    snap.put('Risk_Score__c', risks[i]);
    snaps.add(snap);
}
insert prefs;
insert snaps;


