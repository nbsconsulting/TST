public without sharing class LigneDeCotationController {
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getLignes(String recordId) {
        // Validate input
        if (String.isEmpty(recordId)) {
            return new Map<String, Object>{
                'articles' => new List<Article__c>(),
                'currencyIsoCode' => 'MAD' // Default currency
            };
        }

        // Query the Cotation record
        Cotation__c cotation = [SELECT Id, Opportunite__r.Entite_Juridique__c, CurrencyIsoCode 
                                FROM Cotation__c 
                                WHERE Id = :recordId LIMIT 1];
        
        // If no cotation is found, return an empty list
        if (cotation == null || cotation.Opportunite__r == null) {
            return new Map<String, Object>{
                'articles' => new List<Article__c>(),
                'currencyIsoCode' => 'MAD' // Default currency
            };
        }

        // Query related Article__c records
        List<Article__c> articles = [SELECT Id, Name, Entite_Juridique__c, Distinct__c, TVA__c, ctva__c
                FROM Article__c 
                WHERE Entite_Juridique__c = :cotation.Opportunite__r.Entite_Juridique__c];
        
        // Return both the articles and the currency code
        return new Map<String, Object>{
            'articles' => articles,
            'currencyIsoCode' => cotation.CurrencyIsoCode
        };
    }

    @AuraEnabled
    public static void saveLignes(List<Ligne_de_cotation__c> lignes) {
        try {
            insert lignes;
        } catch (Exception e) {
            throw new AuraHandledException('Error saving records: ' + e.getMessage());
        }
    }
}