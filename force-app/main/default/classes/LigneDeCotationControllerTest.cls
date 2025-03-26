@isTest
public with sharing class LigneDeCotationControllerTest {

    @TestSetup
    static void setupTestData() {
    /*
        Account acc = new Account(Name = 'Test Account', Industry= 'High-tech', Type = 'Compte', BillingPostalCode = '20450', BillingCity = 'Casablanca', Client_confrere__c = 'Non', AccountSource ='Partner', Trafic__c = 'Transit', Phone = '00212675836252');
        insert acc;
        Contact con = new Contact(Title = 'title', FirstName = 'Test', LastName = 'Contact', Email = 'Example@email.com', Phone = '00212675836252', AccountId = acc.Id,  Fonction__c ='Directeur', Service__c = 'Direction', Department = 'something');
        insert con;
        Date currentDate = Date.today();
        Opportunity Opp = new Opportunity(Name = 'Test Opportunity',StageName = 'Qualification', Nombre_de_dossier_transit__c = 18, AccountId = acc.Id, Type_de_vente__c = 'Consultation', Type_de_service__c = 'Transit', Entite_Juridique__c = 'TST', Nombre_de_colis__c = 12, Volume_prevu__c = 134, Type_de_colis__c = 'Conteneur', Date_de_debut__c = currentDate, Date_de_concretisation__c = currentDate.addDays(6), CloseDate = currentDate.addDays(10));
        insert Opp;
        
        // Create test Article__c records
        List<Article__c> articlesList = new List<Article__c>();
        articlesList.add(new Article__c(Name = 'Article 1', Entite_Juridique__c = 'TST'));
        articlesList.add(new Article__c(Name = 'Article 2', Entite_Juridique__c = 'TST'));
        articlesList.add(new Article__c(Name = 'Article 3', Entite_Juridique__c = 'TST'));
        articlesList.add(new Article__c(Name = 'Article 4', Entite_Juridique__c = 'TST'));
        insert articlesList;

        // Create a test Cotation__c record
        Cotation__c cotation = new Cotation__c(Name = 'Test Cotation', Opportunite__c = opp.Id, Hauteur__c = 15, Longueur__c = 15, Largeur__c = 15, Niveau_de_service__c = 'AOG', Type_de_service__c= 'Fret Maritime', Marchandises__c = 'DGR Goods');
        insert cotation;

        // Create test Ligne_de_cotation__c records
        List<Ligne_de_cotation__c> cotationLignes = new List<Ligne_de_cotation__c>();
        cotationLignes.add(new Ligne_de_cotation__c(Article__c = articlesList[0].Id, Cotation__c = cotation.Id, Prix__c = 300000, Quantite__c = 1));
        cotationLignes.add(new Ligne_de_cotation__c(Article__c = articlesList[1].Id, Cotation__c = cotation.Id, Prix__c = 800000, Quantite__c = 10));
        insert cotationLignes;
        */
    }

    @isTest
    static void testGetLignes() {
    /*
        // Call the method to be tested
        List<Article__c> result = LigneDeCotationController.getLignes();

        // Verify the results
        System.assertNotEquals(0, result.size(), 'Expected some articles to be returned');
        for (Article__c article : result) {
            System.assertEquals('TST', article.Entite_Juridique__c, 'Entite_Juridique__c should be TST');
        }
        */
    }

    @isTest
    static void testSaveLignes() {
    /*
        // Query the test articles
        List<Article__c> articlesList = [SELECT Id FROM Article__c ORDER BY Name LIMIT 2];
        System.assert(articlesList.size() >= 2, 'Expected at least 2 articles for association');

        // Query the test cotation
        Cotation__c cotation = [SELECT Id FROM Cotation__c LIMIT 1];

        // Create test Ligne_de_cotation__c records
        List<Ligne_de_cotation__c> lignes = new List<Ligne_de_cotation__c>();
        lignes.add(new Ligne_de_cotation__c(Article__c = articlesList[0].Id, Cotation__c = cotation.Id, Prix__c = 300000, Quantite__c = 1));
        lignes.add(new Ligne_de_cotation__c(Article__c = articlesList[1].Id, Cotation__c = cotation.Id, Prix__c = 800000, Quantite__c = 10));

        // Call the method to be tested
        Test.startTest();
        LigneDeCotationController.saveLignes(lignes);
        Test.stopTest();

        // Verify the results
        List<Ligne_de_cotation__c> savedLignes = [SELECT Id, Name, Cotation__c FROM Ligne_de_cotation__c WHERE Id =: lignes];
        System.assertEquals(2, savedLignes.size(), 'Expected 2 Ligne_de_cotation__c records to be inserted');
    */
    }
    

    @isTest
    static void testSaveLignesWithException() {
    /*
        // Create a test Ligne_de_cotation__c record with invalid data to force an exception
        List<Ligne_de_cotation__c> lignes = new List<Ligne_de_cotation__c>();
        lignes.add(new Ligne_de_cotation__c());

        // Call the method to be tested and expect an exception
        Test.startTest();
        try {
            LigneDeCotationController.saveLignes(lignes);
            System.assert(false, 'Expected an exception to be thrown');
        } catch (AuraHandledException e) {
            system.debug('error message ==> '+ e.getMessage());
            // Confirm the expected exception message is contained in the exception thrown
            System.assert(e.getMessage().contains('Insert failed'), 'Expected error message to contain "Error saving records"');
        }
        Test.stopTest();
        */
    }
}