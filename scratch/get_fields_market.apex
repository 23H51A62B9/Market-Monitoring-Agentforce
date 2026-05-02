for(String f : Schema.getGlobalDescribe().get('Market_Event__c').getDescribe().fields.getMap().keySet()) {
    System.debug('Field Key: ' + f);
}
