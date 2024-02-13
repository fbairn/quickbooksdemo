public with sharing class QBCallout {
    public static String postData(String endpoint, String data) {
        HttpRequest req = new HttpRequest();
        req.setTimeout(120000); // timeout in milliseconds
        QuickBooks__c settings = QuickBooks__c.getInstance();
        String calloutName = isSandboxOrg() ? 'QuickBooksSandbox' : 'QuickBooksProduction';

        endpoint = 'callout:' + calloutName + '/' + EncodingUtil.urlEncode(settings.Company_Id__c, 'UTF-8') + '/' + endpoint;

        req.setEndpoint(endpoint);
        System.debug(req.getEndpoint());
        req.setMethod('POST');
        req.setHeader('Accept', 'application/json');

        req.setHeader('Content-Type', 'application/json');
        System.debug('Serializing request');
        req.setBody(data);


        Http http = new Http();
        System.debug('Ready to Send Request');
        HTTPResponse res = http.send(req);
        System.debug(res.getStatusCode());
        System.debug(res.getBody());

        if(res.getStatusCode() > 299) {
            throw new QBCalloutException(res.getBody());
        }

        return res.getBody();
    }

    public static String getData(String endpoint) {
        HttpRequest req = new HttpRequest();
        req.setTimeout(120000); // timeout in milliseconds
        QuickBooks__c settings = QuickBooks__c.getInstance();
        String calloutName = 'QuickBooksSandbox';

        endpoint = 'callout:' + calloutName + '/' + EncodingUtil.urlEncode(settings.Company_Id__c, 'UTF-8') + '/' + endpoint;

        req.setEndpoint(endpoint);
        System.debug(req.getEndpoint());
        req.setMethod('GET');
        req.setHeader('Accept', 'application/json');

        Http http = new Http();
        System.debug('Ready to Send Request');
        HTTPResponse res = http.send(req);
        System.debug(res.getStatusCode());
        System.debug(res.getBody());

        if(res.getStatusCode() > 299) {
            throw new QBCalloutException(res.getBody());
        }

        return res.getBody();
    }

    public static Object send(QBRecordInterface record, System.Type returnType) {
        if(record == null) {
            throw new QBCalloutException('Record is null.');
        }

        String endpoint = record.endpoint().toLowerCase();
        if(String.isNotBlank(record.minorversion())) {
            endpoint += '?minorversion=' + record.minorversion();
        }
        String jsonString = postData(endpoint, record.serialize());
        Map<String, Object> data = (Map<String, Object>)JSON.deserializeUntyped(jsonString);
        jsonString = JSON.serialize(data.get(record.qbObject()));
        return JSON.deserialize(jsonString, returnType);
    }

    public static Object query(String query, System.Type apexType, String objectName) {
        String jsonString = getData('query?query=' + EncodingUtil.urlEncode(query, 'UTF-8'));

        Map<String, Object> data = (Map<String, Object>)JSON.deserializeUntyped(jsonString);
        Map<String, Object> queryResponse = (Map<String, Object>)data.get('QueryResponse');

        jsonString = JSON.serialize(queryResponse.get(objectName));
        System.debug('JsonString' + jsonString);
        return JSON.deserialize(jsonString, apexType);
    }

    public static Boolean isSandboxOrg(){
        //Since this is running in a dev org it always returns as a production environment.
        //This would be uncommented in a client org.
        // Organization org = [SELECT Id, IsSandbox, TrialExpirationDate FROM Organization];
        // if(Test.isRunningTest() || org.IsSandbox) {
        //     return true;
        // }

        // return false;

        return true;
    }

    public class QBCalloutException extends Exception {}
}