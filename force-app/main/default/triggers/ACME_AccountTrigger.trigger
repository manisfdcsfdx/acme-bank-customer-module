trigger ACME_AccountTrigger on Account (before insert, after insert,before update, after update, before delete , after delete) {
    TriggerDispatcherHandler.execute(System.Label.ACME_AccountTriggerHandler); 
}