@isTest
private class ACME_FinancialTransTriggerHandlerTest {
    @testSetUp
    static void setup() {
        Profile readOnlyProfile = [SELECT Id FROM Profile WHERE Name = 'Read Only'];
        
        User testUser = new User(FirstName = 'Test',
                                    LastName = 'user',
                                    Email = 'testuser@email.com',
                                    Username = 'testuser@email.com'+ '.' + Math.random(),
                                    Alias = 'tuser',
                                    ProfileId = readOnlyProfile.Id,
                                    TimeZoneSidKey = 'Australia/Sydney',
                                    LocaleSidKey = 'en_US',
                                    EmailEncodingKey = 'ISO-8859-1',
                                    LanguageLocaleKey = 'en_US');
        insert testUser;

        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'ACME'];
        insert new PermissionSetAssignment(AssigneeId = testUser.id, PermissionSetId = ps.Id);
    }
    private static User getTestRunUser(){
        return [SELECT Id FROM User WHERE Email = 'testuser@email.com'];
    }

    @isTest
    static void testFinancialAccountTransCreate(){
        System.runAs(getTestRunUser()) {
            
            Id personAccountRecordTypeId =  Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(System.Label.PersonAccountRT).getRecordTypeId();
            Account persAcc = new Account();
            persAcc.RecordTypeId = personAccountRecordTypeId;
            persAcc.FirstName = 'John';
            persAcc.LastName = 'Doe';
            persAcc.PersonEmail = 'test14@test14.com';
            insert persAcc;

            FinancialAccount__c finAcc = new FinancialAccount__c();
            finAcc.AccountType__c = 'Spending';
            finAcc.Customer__c = persAcc.Id;
            insert finAcc;
            
            Test.startTest();

            Time currentTime =  Time.newInstance(3, 14, 15, 926);
            List<FinancialTransaction__c> finTrans = new List<FinancialTransaction__c>();
            finTrans.add(new FinancialTransaction__c(FinancialAccount__c = finAcc.Id, Amount__c = 300,Currency_Type__c = 'AUD', Date__c = System.today().addDays(-30), MerchantBSB__c = '123456',MerchantName__c = 'test food court',
                                                Merchant_ABN__c = '12345678912',Time__c = currentTime,Type__c = 'credit'));
            finTrans.add(new FinancialTransaction__c(FinancialAccount__c = finAcc.Id, Amount__c = 100,Currency_Type__c = 'AUD', Date__c = System.today().addDays(-25), MerchantBSB__c = '123456',MerchantName__c = 'test food court',
                                                Merchant_ABN__c = '12345678912',Time__c = currentTime,Type__c = 'debit'));
            finTrans.add(new FinancialTransaction__c(FinancialAccount__c = finAcc.Id, Amount__c = 50,Currency_Type__c = 'AUD', Date__c = System.today().addDays(-20), MerchantBSB__c = '123456',MerchantName__c = 'test food court',
                                                Merchant_ABN__c = '12345678912',Time__c = currentTime,Type__c = 'debit'));
            finTrans.add(new FinancialTransaction__c(FinancialAccount__c = finAcc.Id, Amount__c = 100,Currency_Type__c = 'AUD', Date__c = System.today().addDays(-17), MerchantBSB__c = '123456',MerchantName__c = 'test food court',
                                                Merchant_ABN__c = '12345678912',Time__c = currentTime,Type__c = 'credit'));
            finTrans.add(new FinancialTransaction__c(FinancialAccount__c = finAcc.Id, Amount__c = 75,Currency_Type__c = 'AUD', Date__c = System.today().addDays(-10), MerchantBSB__c = '123456',MerchantName__c = 'test food court',
                                                Merchant_ABN__c = '12345678912',Time__c = currentTime,Type__c = 'debit'));
            insert finTrans;
            
            Test.stopTest();
        }

        List<FinancialAccount__c> finaccList = [SELECT Id, Balance_Amount__c FROM FinancialAccount__c LIMIT 1];

        System.assertEquals( finaccList[0].Balance_Amount__c, 175, 'Account balance is not calculated');
    }
}
