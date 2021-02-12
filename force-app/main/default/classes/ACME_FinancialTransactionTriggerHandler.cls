public with sharing class ACME_FinancialTransactionTriggerHandler implements callable{
    
    public void populateBalaceAmountInAccount(List<FinancialTransaction__c> newList){
        Set<string> finAccountIds = new Set<string>();
        for(FinancialTransaction__c finTranRec : newList){
            finAccountIds.add(finTranRec.FinancialAccount__c);
        }

        List<FinancialAccount__c> ficAccounts = [SELECT Id,Balance_Amount__c, (SELECT Id, Amount__c, Type__c FROM Financial_Transactions__r ORDER BY Type__c ASC) FROM FinancialAccount__c WHERE Id IN: finAccountIds WITH SECURITY_ENFORCED];
        for(FinancialAccount__c ficAcc : ficAccounts){
            ficAcc.Balance_Amount__c = calculateBalance(ficAcc.Financial_Transactions__r);
        }

        List<Database.SaveResult> results = Database.update(ficAccounts);
        //logging
    }
    private static Decimal calculateBalance(List<FinancialTransaction__c> finTrans){
        Decimal balance = 0;
        for(FinancialTransaction__c finTran : finTrans){
            balance = (finTran.Type__c == System.Label.FinancialTransactionCredit ? ( balance + finTran.Amount__c) : (finTran.Type__c == System.Label.FinancialTransactionDebit ? (balance - finTran.Amount__c) : balance ) );
        }
        return balance;
    }
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
