@isTest
private class Opportunity_QBSyncTest {
    @TestSetup
    static void setup(){
        QuickBooks__c settings = QuickBooks__c.getOrgDefaults();
        settings.Company_Id__c = '0123456789';
        upsert settings;
    }

    @isTest
    static void testQBSync() {
        insert new Opportunity(
            Name = 'Test Opp 1',
            StageName = 'Prospecting',
            CloseDate = Date.Today(),
            QB_Id__c = '1',
            Amount = 1000);

        // Create mock QBCallout class for testing
        Test.setMock(HttpCalloutMock.class, new InvoiceMock());
        Test.startTest();
        System.enqueueJob(new Opportunity_QBSync());
        Test.stopTest();

        // Assert that the opportunity was updated correctly
        Opportunity updatedOpp = [SELECT Id, QB_Id__c, QB_Sync_Token__c, Balance__c, Invoice_Email_Status__c
                                  FROM Opportunity];

        Assert.areEqual('0', updatedOpp.QB_Sync_Token__c);
        Assert.areEqual(100, updatedOpp.Balance__c);
        Assert.areEqual('Sent', updatedOpp.Invoice_Email_Status__c);
    }

    public class InvoiceMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            String jsonString = '{"QueryResponse":{"Invoice":[{"Balance":100.00,"SyncToken":"0","EmailStatus":"EmailSent","Id":"1"}]}}';
            res.setBody(jsonString);
            res.setStatusCode(200);
            return res;
        }
    }
}