@isTest
public class PDFControllerTest {

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
        }
    }

    // Test the success path of confirmPDF()
    @isTest
    static void testConfirmPDF_Success_Quota() {

        System.runAs(getDfaultAdminUser()){
    
            // Create a dummy Cotation__c record with required fields
            Cotation__c cotation = [SELECT Id from Cotation__c LIMIT 1];
            // Set up page parameters: supply the 'id' parameter to simulate a Visualforce request
            PageReference pageRef = Page.VFCotationWrapper; // Use any existing VF page (DummyPage used solely for parameter passing)
            pageRef.getParameters().put('id', String.valueOf(cotation.Id));
            Test.setCurrentPage(pageRef);
            
            // Create the standard controller and instance of PDFController
            ApexPages.StandardController sc = new ApexPages.StandardController(cotation);
            PDFController controller = new PDFController(sc);
            
            // Verify that the constructor properly retrieved values from the record
            System.assertEquals(String.valueOf(cotation.Id), controller.recordId, 'recordId should be set from page parameter');
            System.assertEquals('Test Cotation', controller.cotationName, 'cotationName should match');
            System.assertEquals('EN', controller.cotationLanguage, 'cotationLanguage should match');
            // Assuming that Label.PDF_Quota_1_ApplicableServiceTypes contains "A", quotaToBeCalled should be VF_Cotation
            System.assertEquals('VF_Cotation', controller.quotaToBeCalled, 'quotaToBeCalled should be set based on service type');
            
            // Now, test the confirmPDF method
            // The VF page used for PDF generation is built dynamically based on quotaToBeCalled.
            // For testing, we assume that VF_Cotation exists and returns non-empty content.
            // If VF_Cotation is not available, you must create a simple VF page named VF_Cotation that renders a small PDF.
            Test.startTest();
            PageReference resultPage = controller.confirmPDF();
            Test.stopTest();
            
            // Validate that a ContentVersion record was created
            ContentVersion cv = [SELECT Id, Title, PathOnClient, VersionData FROM ContentVersion WHERE Title = :controller.cotationName LIMIT 1];
            System.assertNotEquals(null, cv, 'A ContentVersion record should be inserted');
            System.assert(cv.VersionData != null && cv.VersionData.size() > 0, 'PDF blob should not be empty');
            
            // Validate that a ContentDocumentLink record was created
            ContentDocumentLink cdl = [SELECT Id, LinkedEntityId, ContentDocumentId, ShareType, Visibility FROM ContentDocumentLink WHERE LinkedEntityId = :controller.recordId LIMIT 1];
            System.assertNotEquals(null, cdl, 'A ContentDocumentLink record should be inserted');
            
            // Validate that closeModal returns a PageReference with URL "/" + recordId
            PageReference pr = controller.closeModal();
            System.assertEquals('/' + controller.recordId, pr.getUrl(), 'closeModal should return the correct URL');
        }
        

    }

    @isTest
    static void testConfirmPDF_Success_Quota2() {

        System.runAs(getDfaultAdminUser()){
    
            // Create a dummy Cotation__c record with required fields
            Cotation__c cotation = [SELECT Id , Type_de_service__c from Cotation__c LIMIT 1];
            cotation.Type_de_service__c = 'Transit';
            update cotation;
            // Set up page parameters: supply the 'id' parameter to simulate a Visualforce request
            PageReference pageRef = Page.VFCotationWrapper; // Use any existing VF page (DummyPage used solely for parameter passing)
            pageRef.getParameters().put('id', String.valueOf(cotation.Id));
            Test.setCurrentPage(pageRef);
            
            // Create the standard controller and instance of PDFController
            ApexPages.StandardController sc = new ApexPages.StandardController(cotation);
            PDFController controller = new PDFController(sc);
            
            // Verify that the constructor properly retrieved values from the record
            System.assertEquals(String.valueOf(cotation.Id), controller.recordId, 'recordId should be set from page parameter');
            System.assertEquals('Test Cotation', controller.cotationName, 'cotationName should match');
            System.assertEquals('EN', controller.cotationLanguage, 'cotationLanguage should match');
            // Assuming that Label.PDF_Quota_1_ApplicableServiceTypes contains "A", quotaToBeCalled should be VF_Cotation
            System.assertEquals('VF_Cotation_2', controller.quotaToBeCalled, 'quotaToBeCalled should be set based on service type');
            
            // Now, test the confirmPDF method
            // The VF page used for PDF generation is built dynamically based on quotaToBeCalled.
            // For testing, we assume that VF_Cotation exists and returns non-empty content.
            // If VF_Cotation is not available, you must create a simple VF page named VF_Cotation that renders a small PDF.
            Test.startTest();
            PageReference resultPage = controller.confirmPDF();
            Test.stopTest();
            
            // Validate that a ContentVersion record was created
            ContentVersion cv = [SELECT Id, Title, PathOnClient, VersionData FROM ContentVersion WHERE Title = :controller.cotationName LIMIT 1];
            System.assertNotEquals(null, cv, 'A ContentVersion record should be inserted');
            System.assert(cv.VersionData != null && cv.VersionData.size() > 0, 'PDF blob should not be empty');
            
            // Validate that a ContentDocumentLink record was created
            ContentDocumentLink cdl = [SELECT Id, LinkedEntityId, ContentDocumentId, ShareType, Visibility FROM ContentDocumentLink WHERE LinkedEntityId = :controller.recordId LIMIT 1];
            System.assertNotEquals(null, cdl, 'A ContentDocumentLink record should be inserted');
            
            // Validate that closeModal returns a PageReference with URL "/" + recordId
            PageReference pr = controller.closeModal();
            System.assertEquals('/' + controller.recordId, pr.getUrl(), 'closeModal should return the correct URL');
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