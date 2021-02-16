/**
  * @author        Mani
  * @date          12/02/2021
  * @description   The purpose of this class is to provide utility trigger framework to avoid having the boiler plate code in all apex triggers.
  */
public with sharing class TriggerDispatcherHandler {
    
    /*
    *   Executes the given handler on a apex trigger event.
    */
    public static void execute(String handler){
        String triggerContext = '';
        if (Trigger.isBefore ){
            if (Trigger.isInsert){          
                triggerContext = System.Label.TRIGGER_BEFOREINSERT;
            }
            else if (Trigger.isUpdate){
                triggerContext = System.Label.TRIGGER_BEFOREUPDATE;
            }
            else if (Trigger.isDelete){
                triggerContext = System.Label.TRIGGER_BEFOREDELETE;
            }
        }         
        // After trigger logic
        else{
            if (Trigger.isInsert){
                triggerContext = System.Label.TRIGGER_AFTERINSERT;
            }
            else if (Trigger.isUpdate){
                triggerContext = System.Label.TRIGGER_AFTERUPDATE;
            }
            else if (Trigger.isDelete){
                triggerContext = System.Label.TRIGGER_AFTERDELETE;
            }
            else if (Trigger.isUndelete){
                triggerContext = System.Label.TRIGGER_AFTERUNDELETE;
            }
        }

        Type handlerType = Type.forName(handler);
        if(handlerType != null){      
            Callable handlerInstance = (Callable)handlerType.newInstance();

            Map<String, Object> args = new Map<String, Object>{System.Label.TRIGGER_NEWLIST => Trigger.new,
                                                                System.Label.TRIGGER_OLDLIST => Trigger.old};
            handlerInstance.call( triggerContext , args);
        }
    }
}
