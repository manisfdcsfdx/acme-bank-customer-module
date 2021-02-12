public with sharing class ACME_FinancialAccountTriggerHandler implements callable{
    public void populateAccountNumber(List<FinancialAccount__c> newList){
        for(FinancialAccount__c finAccRec : newList){
            finAccRec.Account_Number__c = GenerateUniqueIdentifier.getNumeric(8);
        }
    }
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
