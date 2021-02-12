@isTest
private class ACME_FinancialAccountTriggerHandlerTest {
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
    static void testFinancialAccountCreate(){
        System.runAs(getTestRunUser()) {
            
            Id personAccountRecordTypeId =  Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(System.Label.PersonAccountRT).getRecordTypeId();
            Account persAcc = new Account();
            persAcc.RecordTypeId = personAccountRecordTypeId;
            persAcc.FirstName = 'John';
            persAcc.LastName = 'Doe';
            persAcc.PersonEmail = 'test14@test14.com';
            insert persAcc;

            Test.startTest();

            FinancialAccount__c finAcc = new FinancialAccount__c();
            finAcc.AccountType__c = 'Spending';
            finAcc.Customer__c = persAcc.Id;
            insert finAcc;
            
            Test.stopTest();
        }

        List<FinancialAccount__c> finaccList = [SELECT Id, Account_Number__c FROM FinancialAccount__c LIMIT 1];

        System.assert( String.isNotBlank(finaccList[0].Account_Number__c), 'Account Number is not populated.');
    }
}
