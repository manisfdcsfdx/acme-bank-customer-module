/**
  * @author        Mani
  * @date          12/02/2021
  * @description   The purpose of this trigger is to perform process automation to the data in CRM.
  */
trigger ACME_FinancialAccountTrigger on FinancialAccount__c (before insert) {
    TriggerDispatcherHandler.execute(System.Label.ACME_FinancialAccountTriggerHandler); 
}