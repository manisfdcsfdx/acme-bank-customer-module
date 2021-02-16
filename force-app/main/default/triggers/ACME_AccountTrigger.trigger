/**
  * @author        Mani
  * @date          12/02/2021
  * @description   The purpose of this trigger is to perform process automation to the data in CRM.
  */
trigger ACME_AccountTrigger on Account (before insert, after insert,before update, after update, before delete , after delete) {
    TriggerDispatcherHandler.execute(System.Label.ACME_AccountTriggerHandler); 
}