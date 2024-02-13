public with sharing class Opportunity_QBSync implements Queueable, Database.AllowsCallouts {
    public class ScheduleSync implements Schedulable {
        //The scheduled class calls the queable as callouts are not allowed from scheduled jobs.
        public void execute(SchedulableContext SC) {
            System.enqueueJob(new Opportunity_QBSync());
        }
    }

    public static void schedulesync(){
        System.schedule('Invoice QB Sync', '0 0 0 * * ?', new ScheduleSync());
    }

    public void execute(QueueableContext context) {
        run();
    }

    public void run(){
        List<QBInvoice> invoices = (List<QBInvoice>)QBCallout.query('select * from Invoice', List<QBInvoice>.class, 'Invoice');
        System.debug(invoices);
        Map<String, Opportunity> oppByQBId = getOppsByQbId(invoices);

        List<Opportunity> updatedOpportunities = new List<Opportunity>();

        for (QBInvoice invoice : invoices) {
            if(oppByQBId.containsKey(invoice.Id) == false) {continue;}

            Opportunity opp = oppByQBId.get(invoice.Id);
            opp.QB_Id__c = invoice.Id;
            opp.QB_Sync_Token__c = invoice.SyncToken;
            opp.Balance__c = invoice.Balance;
            opp.Invoice_Email_Status__c = invoice.EmailStatus == 'EmailSent' ? 'Sent' : 'Not Sent';
            updatedOpportunities.add(opp);
        }

        update updatedOpportunities;
    }

    private Map<String, Opportunity> getOppsByQbId(List<QBInvoice> invoices) {
        Set<String> qbIds = new Set<String>();
        for (QBInvoice invoice : invoices) {
            qbIds.add(invoice.Id);
        }

        Map<String, Opportunity> opps = new Map<String, Opportunity>();
        for (Opportunity opp : [SELECT Id, Qb_Id__c FROM Opportunity WHERE Qb_Id__c IN :qbIds]) {
            opps.put(opp.QB_Id__c, opp);
        }

        return opps;
    }
}