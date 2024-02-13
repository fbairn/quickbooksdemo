@isTest
public class QBCustomerTest {
    @TestSetup
    static void setup(){
        QuickBooks__c settings = QuickBooks__c.getOrgDefaults();
        settings.Company_Id__c = '0123456789';
        upsert settings;
    }

    @isTest
    static void testConstructor() {
        // Test empty constructor
        QBCustomer qbCustomer = new QBCustomer();
        System.assertEquals(null, qbCustomer.Id);
        System.assertEquals(null, qbCustomer.SyncToken);
        System.assertEquals(null, qbCustomer.DisplayName);

        // Test constructor with Account
        QBCustomer qbCustomerFromAccount = new QBCustomer(testAccount);
        System.assertEquals(testAccount.QB_Id__c, qbCustomerFromAccount.Id);
        System.assertEquals(testAccount.QB_Sync_Token__c, qbCustomerFromAccount.SyncToken);
        System.assertEquals(testAccount.Name, qbCustomerFromAccount.DisplayName);
    }

    @isTest
    static void testSend() {
        // Mock QBCallout.send method to avoid actual callout
        Test.setMock(QBCallout.class, new MockQBCallout());

        QBCustomer qbCustomer = new QBCustomer(testAccount);
        QBCustomer sentCustomer = qbCustomer.send();

        // Assert that the mock send method was called with the correct endpoint
        // and that the returned QBCustomer has expected values
        System.assertEquals(qbCustomer.endpoint(), 'Customer');
        // ... add assertions for sentCustomer's properties
    }

    private class MockQBCallout extends QBCallout {
        public Object send(Object objectToSend, Type responseType) {
            // Return a mock response based on the objectToSend
            // ... implement logic to create a mock QBCustomer response
        }
    }
}