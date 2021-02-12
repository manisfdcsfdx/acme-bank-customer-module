trigger ACME_FinancialAccountTrigger on FinancialAccount__c (before insert) {
    TriggerDispatcherHandler.execute(System.Label.ACME_FinancialAccountTriggerHandler); 
}