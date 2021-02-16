/**
  * @author        Mani
  * @date          12/02/2021
  * @description   The purpose of this class is provide handler service to the ACME_FinancialTransactionTrigger on FinancialTransaction__c object to perform process automation to the data in CRM.
  */
public with sharing class ACME_FinancialTransactionTriggerHandler implements callable{
    /*
    *   This function populates the Aggregate amount of credit and debit balance in its financial account
    */
    public void populateBalaceAmountInAccount(List<FinancialTransaction__c> newList){
        Set<string> finAccountIds = new Set<string>();
        for(FinancialTransaction__c finTranRec : newList){
            finAccountIds.add(finTranRec.FinancialAccount__c);
        }

        List<FinancialAccount__c> ficAccounts = [SELECT Id,Balance_Amount__c, (SELECT Id, Amount__c, Type__c FROM Financial_Transactions__r ORDER BY Type__c ASC) FROM FinancialAccount__c WHERE Id IN: finAccountIds WITH SECURITY_ENFORCED];
        for(FinancialAccount__c ficAcc : ficAccounts){
            ficAcc.Balance_Amount__c = calculateBalance(ficAcc.Financial_Transactions__r);
        }
        List<Database.SaveResult> svResults = Database.Update(ficAccounts,false);
        
        handleError(newList, ficAccounts, svResults);
    }
    /*
    *   This function checks if there are errors in updating financial account then stop the financial transactions to those accounts.
    */
    private void handleError(List<FinancialTransaction__c> newList, List<FinancialAccount__c> ficAccounts, List<Database.SaveResult> svResults){
        Map<String,String> errorMap = new Map<String,String>();
        for (Integer i =0 ; i < svResults.size(); i++) {
            if (!svResults[i].isSuccess()) {
                for(Database.Error err : svResults[i].getErrors()) {
                    string errorMessage = (err.getMessage().contains(System.Label.InsufficientBalance) ? (System.Label.InsufficientBalance) : System.Label.GenericTransactionError);
                    errorMap.put(ficAccounts[i].Id, errorMessage);
                }
            }
        }
        //Send Error
        for(FinancialTransaction__c finTranRec : newList){
            if(errorMap.containsKey(finTranRec.FinancialAccount__c)){
                finTranRec.addError(errorMap.get(finTranRec.FinancialAccount__c));
            }
        }
    }
    
    /*
    *   This function calculate the Aggregate amount of credit and debit balance 
    */
    private static Decimal calculateBalance(List<FinancialTransaction__c> finTrans){
        Decimal balance = 0;
        for(FinancialTransaction__c finTran : finTrans){
            balance = (finTran.Type__c == System.Label.FinancialTransactionCredit ? ( balance + finTran.Amount__c) : (finTran.Type__c == System.Label.FinancialTransactionDebit ? (balance - finTran.Amount__c) : balance ) );
        }
        return balance;
    }
    
    /*
    *   this function will be invoked by the trigger framework to process local functions on sepcified conditions
    */
    public Object call(String action, Map<String, Object> args) {

        List<FinancialTransaction__c> newList = (List<FinancialTransaction__c>) args.get(System.Label.TRIGGER_NEWLIST);
        if(action == System.Label.TRIGGER_AFTERINSERT){
            this.populateBalaceAmountInAccount(newList);
        }
        else {
            System.debug(System.Label.NOTIMPLEMENTED);
        }
        return null;
    }
}
