@isTest
private class Opportunity_SendInvoiceTest {
    @TestSetup
    static void setup(){
        QuickBooks__c settings = QuickBooks__c.getOrgDefaults();
        settings.Company_Id__c = '0123456789';
        upsert settings;
    }

    @isTest
    static void testSendClosedWonToQB() {
        // Create test data
        List<Account> accounts = new List<Account> {
            new Account(Name = 'Test Account 1'),
            new Account(Name = 'Test Account 2')
        };
        insert accounts;

        List<Opportunity> opportunities = new List<Opportunity> {
            new Opportunity(Name = 'Test Opp 1', StageName = 'Prospecting', CloseDate = Date.Today(), Amount = 1000, Account = accounts[0]),
            new Opportunity(Name = 'Test Opp 2', StageName = 'Prospecting', CloseDate = Date.Today(), Amount = 500, Account = accounts[1])
        };
        insert opportunities;

        // Create mock callout for testing
        Test.setMock(HttpCalloutMock.class, new InvoiceMock());

        opportunities[0].StageName = 'Closed Won';
        opportunities[1].StageName = 'Closed Won';

        Test.startTest();
        update opportunities;
        Test.stopTest();

        // Assert that the opportunities were updated correctly
        List<Opportunity> updatedOpps = [SELECT Id, QB_Id__c, QB_Sync_Token__c, Balance__c, Invoice_Email_Status__c FROM Opportunity];
        System.assertEquals(2, updatedOpps.size());
        for (Opportunity opp : updatedOpps) {
            Assert.areNotEqual(null, opp.QB_Id__c);
            Assert.areNotEqual(null, opp.QB_Sync_Token__c);
            Assert.areEqual(100, opp.Balance__c);
            Assert.areEqual('Sent', opp.Invoice_Email_Status__c);
        }
    }

    public class InvoiceMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            String jsonString = '{"Invoice":{"Balance":100.00,"SyncToken":"0","EmailStatus":"EmailSent","Id":"' + Math.random() + '"}}';
            res.setBody(jsonString);
            res.setStatusCode(200);
            return res;
        }
    }
}
