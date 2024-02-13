trigger Opportunity on Opportunity (after update) {
    Opportunity_SendInvoice.sendClosedWonToQB(Trigger.new, Trigger.oldMap);
}