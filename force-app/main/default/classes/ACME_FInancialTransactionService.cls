/**
  * @author        Mani
  * @date          12/02/2021
  * @description   The purpose of this class is provide Apex rest service to be exposed as a API to external to be able to send financial transactions into CRM.
  */
@RestResource(urlMapping='/accounttransaction/*')
global with sharing class ACME_FInancialTransactionService {
    /*
    *   HTTP post service to create financial transaction
    */
    @HttpPost
    global static string doPost(){
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;

        TransactionData tranDetails = getTransactionData(req.requestBody.toString());

        if(String.isBlank(tranDetails.accountNumber) == null || String.isBlank(tranDetails.abid) || String.isBlank(tranDetails.merchantName) == null ||
        tranDetails.amount == null || String.isBlank(tranDetails.merchantABN) == null || String.isBlank(tranDetails.merchantBSB) == null || 
        tranDetails.transactionDate == null || tranDetails.transactionTime == null || String.isBlank(tranDetails.transactionType) ){

            res.statusCode = 400;
            return 'Mandatory fields are missing.'; 
        }

        List<FinancialAccount__c> ficAccounts = [SELECT Id,Customer__c FROM FinancialAccount__c 
                                                WHERE (Account_Number__c =: tranDetails.accountNumber AND Customer__r.ABID__c =: tranDetails.abid) WITH SECURITY_ENFORCED];
        if(ficAccounts.isEmpty()){
            res.statusCode = 400;
            return 'Either the Customer or Acount is not found in CRM.'; 
        }

        List<FinancialTransaction__c> finTrans = [SELECT Amount__c,Currency_Type__c,Date__c,FinancialAccount__c, MerchantBSB__c,MerchantName__c,
                                                Merchant_ABN__c,Time__c,Type__c FROM FinancialTransaction__c
                                                WHERE (Amount__c=: tranDetails.amount AND Date__c=: tranDetails.transactionDate AND Time__c=: tranDetails.transactionTime AND 
                                                FinancialAccount__c =: ficAccounts[0].Id AND MerchantBSB__c =: tranDetails.merchantBSB AND 
                                                MerchantName__c =: tranDetails.merchantName AND Merchant_ABN__c =: tranDetails.merchantABN AND 
                                                Type__c =: tranDetails.transactionType AND Currency_Type__c =: tranDetails.currencyType) WITH SECURITY_ENFORCED];

        if(!finTrans.isEmpty()){
            res.statusCode = 200;
            return 'Trasaction already processed.'; 
        }

        FinancialTransaction__c finTran = new FinancialTransaction__c();
        finTran.Amount__c= tranDetails.amount;
        finTran.Date__c= tranDetails.transactionDate;
        finTran.Time__c= tranDetails.transactionTime;
        finTran.FinancialAccount__c = ficAccounts[0].Id;
        finTran.MerchantBSB__c = tranDetails.merchantBSB;
        finTran.MerchantName__c = tranDetails.merchantName;
        finTran.Merchant_ABN__c = tranDetails.merchantABN;
        finTran.Type__c = tranDetails.transactionType;
        finTran.Currency_Type__c = tranDetails.currencyType;

        Database.SaveResult sr = Database.insert(finTran,false);
        if (!sr.isSuccess()) {
            res.statusCode = 400;
            string errorMessage = System.Label.GenericTransactionError;
            for(Database.Error err : sr.getErrors()) {
                if(err.getMessage().contains(System.Label.InsufficientBalance)){
                    errorMessage = System.Label.InsufficientBalance;
                }
            }
            return errorMessage;
        }

        res.statusCode = 200;
        return 'Trasaction processed successfully.';

    }
    /*
    * As most of the below Keys are reserved in apex following below conversion is used
    */
    public static TransactionData getTransactionData(String requestBody){
        Map<String, Object> request = (Map<String, Object>)JSON.deserializeUntyped(requestBody);

        TransactionData tranDetails = new TransactionData();
        tranDetails.abid = ( String.isNotBlank((String)request.get('abid')) ? ((String)request.get('abid')).replaceAll( '\\s+', '') : null);
        tranDetails.accountNumber = getString((Long)request.get('accountNumber'));
        tranDetails.amount = (Decimal)request.get('amount');
        tranDetails.currencyType = (String)request.get('currency');
        tranDetails.transactionDate = getDate((String)request.get('date'));
        tranDetails.transactionTime = getTime((String)request.get('time'));
        tranDetails.merchantABN = getString((Long)request.get('merchantABN') );
        tranDetails.merchantBSB = getString((Long)request.get('merchantBSB') );
        tranDetails.merchantName = (String)request.get('merchantName');
        tranDetails.transactionType = (String)request.get('type');
        return tranDetails;
    }
    private static string getString(Long value){
        return (value != null ? String.valueOf( value ): null );
    }
    private static Date getDate(String value){
        return (value != null ? Date.valueOf( value.replace('/','-') ): null );
    }
    private static Time getTime(String value){
        if(value == null){
            return null;
        }
        List<String> parts = value.split(':');

        Time transactionTime = Time.newInstance( Integer.ValueOf(parts[0]),  Integer.ValueOf(parts[1]) , Integer.ValueOf(parts[2]) , 0);
        return transactionTime;
    }
    public class TransactionData{
        public String abid;
        public String accountNumber;
        public Decimal amount;
        public String currencyType;
        public Date transactionDate;
        public String merchantABN;
        public String merchantBSB;
        public String merchantName;
        public Time transactionTime;
        public String transactionType;
    }
}
