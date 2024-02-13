public class QBInvoice extends QBRecordInterface {
    public String Id;
    public List<SalesItemLine> Line; //Required

    public QBReferenceType CustomerRef; //Required
    public String SyncToken;
    public string PrintStatus;
    public Date DueDate;
    public String EmailStatus;
    public Decimal HomeBalance {get; private set;}
    public Decimal Balance {get; private set;}

    public QBInvoice() {
        //Empty constructor allows JSON deserialization to work correctly.
    }

    public QBInvoice(Opportunity opp) {
        id = opp.QB_Id__c;
        SyncToken = opp.QB_Sync_Token__c;

        CustomerRef = new QBReferenceType();
        CustomerRef.value = opp.Account.QB_Id__c;

        SalesItemLine billingItem = new SalesItemLine();
        billingItem.Amount = opp.Amount;
        billingItem.Description = opp.Name;

        billingItem.SalesItemLineDetail = new SalesItem_LineDetail();
        billingItem.SalesItemLineDetail.ItemRef.name = 'Service';
        // billingItem.SalesItemLineDetail.ItemRef.Value = '7';

        Line = new List<SalesItemLine> {billingItem};
    }

    /**QuickBooks Methods **/
    public QBInvoice send(){
        validate();
        return (QBInvoice)QBCallout.send(this, QBInvoice.class);
    }

    private void validate(){
        if(CustomerRef == null) {
            throw new QBInvoiceException('CustomerRef is required');
        }
        System.debug('Lines: ' + this.line);
        if(this.Line == null || this.line.isEmpty()) {
            throw new QBInvoiceException('At least one Line item is required.');
        }
    }

    public override String endpoint(){
        if(id != null) {return 'invoice/' + id;}
        return 'Invoice';
    }
    /** End QuickBooks Methods **/


    public class QBInvoiceException extends Exception {

    }

    public class SalesItemLine {
        public final string DetailType = 'SalesItemLineDetail';

        public String Id;
        public SalesItem_LineDetail SalesItemLineDetail = new SalesItem_LineDetail();
        public Decimal Amount;
        public String Description;
    }

    public class SalesItem_LineDetail {
        public QBReferenceType ItemRef = new QBReferenceType();
    }

}
