/**
  * @author        Mani
  * @date          12/02/2021
  * @description   The purpose of this class is provide handler service to the ACME_AccountTrigger on Account object to perform process automation to the data in CRM.
  */
public with sharing class ACME_AccountTriggerHandler implements callable{
    /*
    *   Populates alpha numeric unique identifier ABID on Accounts on creation
    *   example ABC123456789
    */
    public void populateABID(List<Account> newList){
        for(Account accRec : newList){
            if(accRec.isPersonAccount == true){
                accRec.ABID__c = (GenerateUniqueIdentifier.getString(3)).toUpperCase() + GenerateUniqueIdentifier.getNumeric(9);
            }
        }
    }

    /*
    *   Publish CustomerDataSync__e platform event on account creation
    */
    public void publishCustomerDataSync(List<Account> newList){
        List<CustomerDataSync__e> customerEvents = new List<CustomerDataSync__e>();
        for(Account accRec : newList){
            if(accRec.isPersonAccount == true){
                customerEvents.add( new CustomerDataSync__e(Data__c = JSON.serialize(new CustomerData(accRec)) ) );
            }
        }

        List<Database.SaveResult> results = EventBus.publish(customerEvents);
        //logging
    }
    
    /*
    *   this function will be invoked by the trigger framework to process local functions on sepcified conditions
    */
    public Object call(String action, Map<String, Object> args) {

        List<Account> newList = (List<Account>) args.get(System.Label.TRIGGER_NEWLIST);
        if(action == System.Label.TRIGGER_BEFOREINSERT){
            this.populateABID(newList);
        }
        else if(action == System.Label.TRIGGER_AFTERINSERT){
            this.publishCustomerDataSync(newList);
        }
        else {
            System.debug(System.Label.NOTIMPLEMENTED);
        }
        return null;
    }
    public class CustomerData{
        string name {get; set;}
        string email {get; set;}
        string phone {get; set;}
        string abId {get; set;}
        string street {get; set;}
        string city {get; set;}
        string state {get; set;}
        string country {get; set;}
        string postalcode {get; set;}
        public CustomerData(Account accRec){
            name = accRec.Name ;
            email = accRec.personemail ;
            phone = accRec.phone ;
            abId = accRec.ABID__c ;
            street = accRec.PersonMailingstreet ;
            city = accRec.PersonMailingcity ;
            state = accRec.PersonMailingstate ;
            country = accRec.Personmailingcountry ;
            postalcode = accRec.PersonMailingpostalCode ;
        }
    }
}
