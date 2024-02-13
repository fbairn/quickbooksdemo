public class QBCustomer extends QBRecordInterface {
    public String Id;
    public String SyncToken;
    public String DisplayName;

    public QBCustomer(){
        //Empty constructor allows JSON deserialization to work correctly.
    }

    public QBCustomer(Account customer){
        id = customer.QB_Id__c;
        SyncToken = customer.QB_Sync_Token__c;
        DisplayName = customer.Name;
    }

    public QBCustomer send(){
        return (QBCustomer)QBCallout.send(this, QBCustomer.class);
    }

    public override String endpoint(){
        return 'Customer';
    }

    public class TelephoneNumber {
        public String FreeFormNumber;
    }

    public class Email {
        public string Address;
    }

    public class Address {
        public String Id;
        public String PostalCode;
        public String City;
        public String Country;
        public String Line1;
        public String Line2;
        public String CountrySubDivisionCode;
    }

}
