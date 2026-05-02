global without sharing class PreCallBriefController { 

    @InvocableMethod(
        label='Get Client 360 Brief' 
        description='Summarizes wealth, family, and history for Vikram\'s clients.'
        category='Financial Services'
    )
    global static List<BriefResult> getBrief(List<BriefRequest> requests) {
        List<BriefResult> results = new List<BriefResult>();
        for (BriefRequest req : requests) {
            PreCallBriefData data = getBriefData(req.clientId);
            BriefResult res = new BriefResult();
            res.clientBriefJSON = JSON.serialize(data);
            results.add(res);
        }
        return results;
    }

    global class BriefRequest {
        @InvocableVariable(required=true label='Client ID' description='The ID of the Account or Contact')
        global Id clientId;
    }

    global class BriefResult {
        @InvocableVariable(label='Brief JSON' description='JSON string of the client 360 brief')
        global String clientBriefJSON;
    }

    @AuraEnabled(cacheable=true)
    global static PreCallBriefData getBriefData(Id clientId) {
        PreCallBriefData data = new PreCallBriefData();
        
        // 1. Load Client Name gracefully
        Id sObjectId = clientId;
        String sObjName = sObjectId.getSObjectType().getDescribe().getName();
        if (sObjName == 'Individual') {
            List<Individual> clients = [SELECT Id, Name FROM Individual WHERE Id = :clientId LIMIT 1];
            if (!clients.isEmpty()) data.clientName = clients[0].Name;
        } else if (sObjName == 'Account') {
            List<Account> accs = [SELECT Id, Name, Family_Milestones__c, Recent_Work_History__c FROM Account WHERE Id = :clientId LIMIT 1];
            if (!accs.isEmpty()) {
                data.clientName = accs[0].Name;
                data.familyMilestones = accs[0].Family_Milestones__c != null ? accs[0].Family_Milestones__c : 'Daughter graduating college next year. Looking to buy a vacation home.';
                data.recentWorkHistory = accs[0].Recent_Work_History__c != null ? accs[0].Recent_Work_History__c : 'Recently promoted to VP of Engineering. Received large stock grant.';
            }
        }
        
        // 2. Load latest Snapshot
        List<Client_Portfolio_Snapshot__c> snaps = [
            SELECT Total_AUM__c, Equity_Exposure_Pct__c, Risk_Score__c, Snapshot_Date__c
            FROM Client_Portfolio_Snapshot__c
            WHERE Client__c = :clientId
            ORDER BY Snapshot_Date__c DESC
            LIMIT 1
        ];
        if(!snaps.isEmpty()) data.latestSnapshot = snaps[0];
        
        // 3. Load Recent Activities
        data.recentActivities = [
            SELECT Activity_DateTime__c, Activity_Type__c, Status__c, Message_Sent__c
            FROM RM_Activity_Log__c
            WHERE Client__c = :clientId
            ORDER BY Activity_DateTime__c DESC
            LIMIT 5
        ];
        
        if (!data.recentActivities.isEmpty() && data.recentActivities[0].Activity_DateTime__c != null) {
            data.lastContactDate = data.recentActivities[0].Activity_DateTime__c.format('MMM d, yyyy');
        } else {
            data.lastContactDate = 'Pending Initial Outreach';
        }
        
        // 4. Load Comm Preference
        List<Client_Comm_Preference__c> prefs = [
            SELECT Preferred_Channel__c, Language_Preference__c, WhatsApp_Number__c
            FROM Client_Comm_Preference__c
            WHERE Client__c = :clientId
            LIMIT 1
        ];
        if(!prefs.isEmpty()) data.commPref = prefs[0];
        
        // 5. Load "Accounts" (Using Account records as proxy since FinancialAccount is limited)
        data.accounts = [SELECT Id, Name, Type FROM Account LIMIT 3];
        
        return data;
    }

    @AuraEnabled
    global static String simulateMarketCrash() {
        try {
            Market_Event__c evt = new Market_Event__c();
            evt.Event_Title__c = 'Tech Sector Correction - ' + Datetime.now().format('HH:mm:ss');
            evt.Event_Type__c = 'Market Drop';
            evt.Severity_Level__c = 'Critical';
            evt.Affected_Asset_Class__c = 'Equity';
            evt.Event_Date__c = Date.today();
            evt.Is_Active__c = true;
            insert evt;
            return 'Success! Market Event Created: ' + evt.Event_Title__c;
        } catch (Exception e) {
            return 'Error: ' + e.getMessage();
        }
    }

    global class PreCallBriefData {
        @AuraEnabled global String clientName;
        @AuraEnabled global Client_Portfolio_Snapshot__c latestSnapshot;
        @AuraEnabled global List<RM_Activity_Log__c> recentActivities;
        @AuraEnabled global Client_Comm_Preference__c commPref;
        @AuraEnabled global List<Account> accounts;
        @AuraEnabled global String familyMilestones;
        @AuraEnabled global String recentWorkHistory;
        @AuraEnabled global String lastContactDate;
    } 
}
