global with sharing class AdvisoryMessageGenerator { 
 
    @InvocableMethod(label='Generate Advisory Message' 
                     description='Creates personalized market advisory using Einstein AI') 
    global static List<MessageResult> generateMessage( 
            List<MessageRequest> requests) { 
 
        List<MessageResult> results = new List<MessageResult>(); 
        for (MessageRequest req : requests) { 
            results.add(buildMessage(req)); 
        } 
        return results; 
    } 
 
    private static MessageResult buildMessage(MessageRequest req) { 
        // Load client + portfolio 
        Individual client = [ 
            SELECT Id, Name 
            FROM Individual 
            WHERE Id = :req.clientId LIMIT 1 
        ]; 
 
        Client_Portfolio_Snapshot__c snap = [ 
            SELECT Total_AUM__c, Equity_Exposure_Pct__c, 
                   Risk_Score__c, Impact_Score__c 
            FROM Client_Portfolio_Snapshot__c 
            WHERE Client__c = :req.clientId 
            AND Snapshot_Date__c = TODAY 
            LIMIT 1 
        ]; 
 
        Client_Comm_Preference__c pref = [ 
            SELECT Preferred_Channel__c, Language_Preference__c 
            FROM Client_Comm_Preference__c 
            WHERE Client__c = :req.clientId LIMIT 1 
        ]; 
 
        // Build contextual prompt 
        String prompt = buildPrompt(client, snap, req.eventSummary, pref); 
 
        MessageResult r = new MessageResult(); 
        r.generatedMessage = prompt;  // Replace with Einstein API call 
        r.preferredChannel = pref.Preferred_Channel__c; 
        r.clientName = client.Name; 
        return r; 
    } 
 
    private static String buildPrompt(Individual c, 
            Client_Portfolio_Snapshot__c s, 
            String eventSummary, 
            Client_Comm_Preference__c pref) { 
 
        return 'Dear ' + c.Name + ',' 
            + ' Given recent market developments — ' + eventSummary 
            + ' — and your current portfolio allocation of ' 
            + s.Equity_Exposure_Pct__c + '% in equities with AUM of INR ' 
            + s.Total_AUM__c.format() 
            + ', our research team recommends a portfolio review. ' 
            + 'Please reply to schedule a call or visit your portal. ' 
            + 'Vikram, Your Relationship Manager | ABC Wealth.'; 
    } 
 
    global class MessageRequest { 
        @InvocableVariable(required=true) global Id clientId; 
        @InvocableVariable(required=true) global String eventSummary; 
        @InvocableVariable global Id marketEventId; 
    } 
 
    global class MessageResult { 
        @InvocableVariable global String generatedMessage; 
        @InvocableVariable global String preferredChannel; 
        @InvocableVariable global String clientName; 
    } 
}
