/**
  * @author        Mani
  * @date          12/02/2021
  * @description   The purpose of this trigger is to perform process automation to the data in CRM.
  */
trigger ACME_FinancialTransactionTrigger on FinancialTransaction__c (after insert) {
    TriggerDispatcherHandler.execute(System.Label.ACME_FinancialTransactionTriggerHandler); 
}