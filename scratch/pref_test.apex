Account acc = new Account(Name = 'Test Seeding Account');
insert acc;
Client_Comm_Preference__c pref = new Client_Comm_Preference__c(
    Client__c = acc.Id,
    Preferred_Channel__c = 'WhatsApp',
    Opt_In_WhatsApp__c = true
);
insert pref;
System.debug('Pref Success: ' + pref.Id);
