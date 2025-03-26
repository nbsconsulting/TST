@isTest
public class VF_Cotation_2_Controller_Test {
    @TestSetup
    static void makeData(){
        System.runAs(getDfaultAdminUser()){
            Account acc = new Account();
            acc.Name = 'Test Account';
            // Create a dummy Opportunity record if required by Cotation__c
            Opportunity opp = new Opportunity(
                Name = 'Test Opp',
                StageName = 'Analyse',
                CloseDate = Date.today(),
                AccountId = acc.Id
            );
            insert opp;
            
            // Create a dummy Cotation__c record with required fields
            Cotation__c cotation = new Cotation__c(
                Name = 'Test Cotation',
                Opportunite__c = opp.Id,
                Type_de_service__c = 'Fret Aérien',
                Langue_des_conditions_generales__c = 'EN'
            );
            insert cotation;

            Conditions_Generales__c conditions = new Conditions_Generales__c(
                Name = 'CONDITIONS GENERALES DE PRESTATIONS DE SERVICES',
                English_version__c = 'Test English',
                French_version__c = 'Test French'
            );
            insert conditions;
        }
    }

    @isTest
    static void testController(){
        System.runAs(getDfaultAdminUser()){
    
            // Create a dummy Cotation__c record with required fields
            Cotation__c cotation = [SELECT Id from Cotation__c LIMIT 1];
            // Set up page parameters: supply the 'id' parameter to simulate a Visualforce request
            PageReference pageRef = Page.VF_Cotation; // Use any existing VF page (DummyPage used solely for parameter passing)
            pageRef.getParameters().put('id', String.valueOf(cotation.Id));
            pageRef.getParameters().put('cotationLanguage', 'EN');
            Test.setCurrentPage(pageRef);
            
            // Create the standard controller and instance of PDFController
            ApexPages.StandardController sc = new ApexPages.StandardController(cotation);
            new VF_Cotation_2_Controller(sc);
        }
    }

    private static User getDfaultAdminUser(){
        
        User us = [SELECT Bypass_Flow__c , Bypass_VR__c FROM User WHERE Profile.Name = 'System Administrator' AND isActive = true LIMIT 1];

        us.Bypass_Flow__c = true;
        us.Bypass_VR__c = true;
        update us;

        return us;
    }
}