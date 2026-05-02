List<String> res = new List<String>();
for(String f : Schema.getGlobalDescribe().get('MessagingSession').getDescribe().fields.getMap().keySet()) {
    res.add(f);
}
System.debug('FIELDS: ' + String.join(res, ','));
