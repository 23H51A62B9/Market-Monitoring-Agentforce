global with sharing class MarketSegmentationEngine { 
 
    // Entry point called by Agentforce Action or Flow 
    @InvocableMethod(label='Run Market Segmentation' 
                     description='Segments clients impacted by a market event') 
    global static List<SegmentResult> runSegmentation( 
            List<SegmentRequest> requests) { 
 
        List<SegmentResult> results = new List<SegmentResult>(); 
 
        for (SegmentRequest req : requests) { 
            results.add(processEvent(req.marketEventId)); 
        } 
        return results; 
    } 
 
    private static SegmentResult processEvent(Id eventId) { 
        // 1. Load the market event 
        Market_Event__c evt = [ 
            SELECT Id, Event_Type__c, Severity_Level__c, 
                   Affected_Asset_Class__c, Affected_Sectors__c 
            FROM Market_Event__c 
            WHERE Id = :eventId 
            LIMIT 1 
        ]; 
 
        // 2. Load all today's portfolio snapshots 
        List<Client_Portfolio_Snapshot__c> snapshots = [ 
            SELECT Id, Client__c, Total_AUM__c, 
                   Equity_Exposure_Pct__c, Debt_Exposure_Pct__c, 
                   Gold_Exposure_Pct__c, Top_Sector_1__c, 
                   Top_Sector_2__c, Risk_Score__c 
            FROM Client_Portfolio_Snapshot__c 
            WHERE Snapshot_Date__c = TODAY 
        ]; 
 
        // 3. Score each snapshot 
        List<Client_Portfolio_Snapshot__c> toUpdate = 
            new List<Client_Portfolio_Snapshot__c>(); 
        Integer impactedCount = 0; 
 
        for (Client_Portfolio_Snapshot__c snap : snapshots) { 
            Decimal score = calculateImpactScore(snap, evt); 
            snap.Impact_Score__c = score; 
            snap.Market_Event__c = eventId; 
            snap.Is_Impacted__c = (score >= 3.0); 
            if (snap.Is_Impacted__c) impactedCount++; 
            toUpdate.add(snap); 
        } 
 
        if (!toUpdate.isEmpty()) { 
            update toUpdate; 
        } 
 
        // 4. Update event with count 
        evt.Impacted_Client_Count__c = impactedCount; 
        update evt; 
 
        SegmentResult r = new SegmentResult(); 
        r.impactedCount = impactedCount; 
        r.totalProcessed = snapshots.size(); 
        r.marketEventId = eventId; 
        return r; 
    } 
 
    // Scoring algorithm — max score 10 
    private static Decimal calculateImpactScore( 
            Client_Portfolio_Snapshot__c snap, 
            Market_Event__c evt) { 
 
        Decimal score = 0; 
        String assetClass = evt.Affected_Asset_Class__c; 
        String evtType = evt.Event_Type__c; 
 
        // Equity market events 
        if (assetClass != null && assetClass.contains('Equity')) { 
            score += (snap.Equity_Exposure_Pct__c != null) 
                ? snap.Equity_Exposure_Pct__c / 20 : 0; 
        } 
 
        // Debt market events 
        if (assetClass != null && assetClass.contains('Debt')) { 
            score += (snap.Debt_Exposure_Pct__c != null) 
                ? snap.Debt_Exposure_Pct__c / 20 : 0; 
        } 
 
        // Severity multiplier 
        if (evt.Severity_Level__c == 'Critical') score *= 1.5; 
        else if (evt.Severity_Level__c == 'High') score *= 1.2; 
 
        // Risk score amplifier 
        if (snap.Risk_Score__c != null && snap.Risk_Score__c >= 7) { 
            score += 1.0; 
        } 
 
        return score.setScale(2); 
    } 
 
    // Inner classes for InvocableMethod 
    global class SegmentRequest { 
        @InvocableVariable(required=true) 
        global Id marketEventId; 
    } 
 
    global class SegmentResult { 
        @InvocableVariable 
        global Integer impactedCount; 
        @InvocableVariable 
        global Integer totalProcessed; 
        @InvocableVariable 
        global Id marketEventId; 
    } 
}
