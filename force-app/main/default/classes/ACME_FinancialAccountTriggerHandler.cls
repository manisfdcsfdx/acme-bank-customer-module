/**
  * @author        Mani
  * @date          12/02/2021
  * @description   The purpose of this class is provide handler service to the ACME_FinancialAccountTrigger on FinancialAccount__c object to perform process automation to the data in CRM.
  */
public with sharing class ACME_FinancialAccountTriggerHandler implements callable{
    /*
    *   Populates numeric unique identifier Account number on Financial Accounts on creation
    *   example 12345678
    */
    public void populateAccountNumber(List<FinancialAccount__c> newList){
        for(FinancialAccount__c finAccRec : newList){
            finAccRec.Account_Number__c = GenerateUniqueIdentifier.getNumeric(8);
        }
    }
    
    /*
    *   this function will be invoked by the trigger framework to process local functions on sepcified conditions
    */
    public Object call(String action, Map<String, Object> args) {

        List<FinancialAccount__c> newList = (List<FinancialAccount__c>) args.get(System.Label.TRIGGER_NEWLIST);
        if(action == System.Label.TRIGGER_BEFOREINSERT){
            this.populateAccountNumber(newList);
        }
        else {
            System.debug(System.Label.NOTIMPLEMENTED);
        }
        return null;
   }
}
