/**
  * @author        Mani
  * @date          12/02/2021
  * @description   The purpose of this class is to cover the until test for ACME_AccountTriggerHandler.
  */
@isTest
private class ACME_AccountTriggerHandlerTest {
    @testSetUp
    static void setup() {
        Profile readOnlyProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User'];
        
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
    static void testAccountCreate(){
        System.runAs(getTestRunUser()) {
            Test.startTest();
            
            Id personAccountRecordTypeId =  Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(System.Label.PersonAccountRT).getRecordTypeId();
            Account persAcc = new Account();
            persAcc.RecordTypeId = personAccountRecordTypeId;
            persAcc.FirstName = 'John';
            persAcc.LastName = 'Doe';
            persAcc.PersonEmail = 'test14@test14.com';
            insert persAcc;
            
            Test.stopTest();

            update persAcc;
        }

        List<Account> accList = [SELECT Id, ABID__c FROM Account WHERE isPersonAccount = true LIMIT 1];

        System.assert( String.isNotBlank(accList[0].ABID__c), 'ABIS is not populated.');

        delete accList;
    }
}
