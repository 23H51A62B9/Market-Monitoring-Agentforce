global with sharing class WhatsAppOutreachHandler { 
 
    @InvocableMethod(label='Send WhatsApp Message' 
                     description='Dispatches advisory via preferred channel') 
    global static List<OutreachResult> sendOutreach( 
            List<OutreachRequest> requests) { 
 
        List<OutreachResult> results = new List<OutreachResult>(); 
        List<RM_Activity_Log__c> logs = new List<RM_Activity_Log__c>(); 
 
        for (OutreachRequest req : requests) { 
            OutreachResult r = dispatchMessage(req); 
            results.add(r); 
 
            // Auto-log the activity 
            RM_Activity_Log__c log = new RM_Activity_Log__c( 
                Client__c = req.clientId, 
                Activity_Type__c = 'Outreach Sent', 
                Activity_DateTime__c = DateTime.now(), 
                Channel__c = req.channel, 
                Initiated_By__c = 'Agentforce', 
                Message_Sent__c = req.message, 
                Status__c = r.success ? 'Sent' : 'Failed', 
                Market_Event__c = req.marketEventId, 
                Agentforce_Trace_ID__c = req.traceId 
            ); 
            logs.add(log); 
        } 
 
        if (!logs.isEmpty()) insert logs; 
        return results; 
    } 
 
    private static OutreachResult dispatchMessage(OutreachRequest req) { 
        OutreachResult r = new OutreachResult(); 
        try { 
            if (req.channel == 'WhatsApp') { 
                // Call Salesforce Messaging for WhatsApp API 
                // MessagingSession or ConnectedApp callout 
                sendWhatsApp(req.phoneNumber, req.message); 
            } else if (req.channel == 'Email') { 
                sendEmail(req.email, req.message, req.clientName); 
            } else if (req.channel == 'SMS') { 
                sendSMS(req.phoneNumber, req.message); 
            } 
            r.success = true; 
            r.statusMessage = 'Message dispatched via ' + req.channel; 
        } catch (Exception e) { 
            r.success = false; 
            r.statusMessage = e.getMessage(); 
        } 
        return r; 
    } 
 
    private static void sendWhatsApp(String phone, String body) { 
        // Salesforce Messaging for WhatsApp via Named Credential 
        HttpRequest req = new HttpRequest(); 
        req.setEndpoint('callout:WhatsApp_MCS/v1/messages'); 
        req.setMethod('POST'); 
        req.setHeader('Content-Type', 'application/json'); 
        req.setBody(JSON.serialize(new Map<String, Object>{ 
            'to' => phone, 
            'type' => 'text', 
            'text' => new Map<String, String>{ 'body' => body } 
        })); 
        new Http().send(req); 
    } 
 
    private static void sendEmail(String email, String body, String name) { 
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); 
        mail.setToAddresses(new List<String>{ email }); 
        mail.setSubject('Important Market Update — Action Required'); 
        mail.setPlainTextBody(body); 
        Messaging.sendEmail(new List<Messaging.Email>{ mail }); 
    } 
 
    private static void sendSMS(String phone, String body) { 
        // Implement via Twilio or Salesforce SMS callout 
    } 
 
    global class OutreachRequest { 
        @InvocableVariable(required=true) global Id clientId; 
        @InvocableVariable(required=true) global String channel; 
        @InvocableVariable(required=true) global String message; 
        @InvocableVariable global String phoneNumber; 
        @InvocableVariable global String email; 
        @InvocableVariable global String clientName; 
        @InvocableVariable global Id marketEventId; 
        @InvocableVariable global String traceId; 
    } 
 
    global class OutreachResult { 
        @InvocableVariable global Boolean success; 
        @InvocableVariable global String statusMessage; 
    } 
}
