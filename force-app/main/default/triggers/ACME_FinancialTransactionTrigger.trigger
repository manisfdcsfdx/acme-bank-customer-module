trigger ACME_FinancialTransactionTrigger on FinancialTransaction__c (after insert) {
    TriggerDispatcherHandler.execute(System.Label.ACME_FinancialTransactionTriggerHandler); 
}