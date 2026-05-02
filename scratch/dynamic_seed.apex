Market_Event__c evt = new Market_Event__c();
evt.put('Event_Title__c', 'Test Dynamic');
evt.put('Event_Type__c', 'Equity Market Crash');
insert evt;
System.debug('Inserted Success: ' + evt.Id);
