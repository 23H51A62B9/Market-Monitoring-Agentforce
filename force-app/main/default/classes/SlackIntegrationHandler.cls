global with sharing class SlackIntegrationHandler { 
 
    @InvocableMethod(label='Post to Slack Channel' 
                     description='Posts message to Slack channel') 
    global static List<SlackResult> postMessage( 
            List<SlackRequest> requests) { 
 
        List<SlackResult> results = new List<SlackResult>(); 
        for (SlackRequest req : requests) { 
            results.add(sendToSlack(req)); 
        } 
        return results; 
    } 
 
    private static SlackResult sendToSlack(SlackRequest req) { 
        SlackResult r = new SlackResult(); 
        try { 
            HttpRequest httpReq = new HttpRequest(); 
            httpReq.setEndpoint('callout:Slack_Webhook/chat.postMessage'); 
            httpReq.setMethod('POST'); 
            httpReq.setHeader('Content-Type', 'application/json'); 
            // Token should be managed via Named Credential 'Slack_Webhook' 
            // httpReq.setHeader('Authorization', 'Bearer YOUR_SLACK_TOKEN'); 
 
            Map<String, Object> payload = new Map<String, Object>{ 
                'text' => req.message, 
                'channel' => '#' + req.channelName, 
                'username' => 'Market Monitoring Agent', 
                'icon_emoji' => ':chart_with_upwards_trend:' 
            }; 
 
            httpReq.setBody(JSON.serialize(payload)); 
            HttpResponse res = new Http().send(httpReq); 
            r.success = (res.getStatusCode() == 200); 
            r.messageTs = res.getBody(); 
        } catch (Exception e) { 
            r.success = false; 
            r.messageTs = e.getMessage(); 
        } 
        return r; 
    } 
 
    global class SlackRequest { 
        @InvocableVariable(required=true) global String channelName; 
        @InvocableVariable(required=true) global String message; 
        @InvocableVariable global String urgency; 
    } 
 
    global class SlackResult { 
        @InvocableVariable global Boolean success; 
        @InvocableVariable global String messageTs; 
    } 
}
