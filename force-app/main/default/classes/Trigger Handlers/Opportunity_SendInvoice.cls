public without sharing class Opportunity_SendInvoice implements Queueable, Database.AllowsCallouts {
    Set<Id> oppIds;

    public Opportunity_SendInvoice(Set<Id> oppIds){
        this.oppIds = new Set<Id>(oppIds);
    }

    public static void sendClosedWonToQB(List<Opportunity> newOpps, Map<Id, Opportunity> oldOpps){
        Set<Id> closeWonIds = filterClosedWonOpps(newOpps, oldOpps);
        if(closeWonIds.isEmpty()) {return;}

        Opportunity_SendInvoice oppSender = new Opportunity_SendInvoice(closeWonIds);

        System.enqueueJob(oppSender);
    }

    private static Set<Id> filterClosedWonOpps(List<Opportunity> newOpps, Map<Id, Opportunity> oldOpps) {
        Set<Id> closedWon = new Set<Id>();
        for (Opportunity opp : newOpps) {
            if(opp.IsClosed && opp.IsWon && oldOpps.get(opp.Id).StageName != opp.StageName) {
                closedWon.add(opp.Id);
            }
        }
        return closedWon;
    }

    public void execute(QueueableContext context) {
        run();
    }

    public void run(){
        List<Opportunity> updatedOpportunities = new List<Opportunity>();

        for (Opportunity opp : [SELECT Id, Name, QB_Id__c, QB_Sync_Token__c, Amount, Account.QB_Id__c
                                FROM Opportunity WHERE Id IN :oppIds AND QB_Id__c = NULL]) {
            QBInvoice qbinvc = new QBInvoice(opp).send();
            opp.QB_Id__c = qbinvc.Id;
            opp.QB_Sync_Token__c = qbinvc.SyncToken;
            opp.Balance__c = qbinvc.Balance;
            opp.Invoice_Email_Status__c = qbinvc.EmailStatus == 'EmailSent' ? 'Sent' : 'Not Sent';
            updatedOpportunities.add(opp);
            oppIds.remove(opp.Id);
            if(System.Limits.getLimitCallouts() == 0) {
                break;
            }
        }

        update updatedOpportunities;

        //Ensures that if we have processed all the opportunities that we don't get stuck in a loop.
        if(System.Limits.getLimitCallouts() > 0 || oppIds.size() == 0) {
            return;
        }

        System.enqueueJob(this);
    }
}