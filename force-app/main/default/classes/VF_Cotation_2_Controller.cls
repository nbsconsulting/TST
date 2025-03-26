public class VF_Cotation_2_Controller {
    
    public List<Ligne_de_cotation__c> quotationLines{ get; set; }
    public String cotationLanguage{ get; set; }
    public Conditions_Generales__c conditions { get; set; }
    
    public VF_Cotation_2_Controller(ApexPages.StandardController controller) {
        
        String quotationId = ApexPages.currentPage().getParameters().get('Id');
        cotationLanguage = ApexPages.currentPage().getParameters().get('cotationLanguage');
        
        quotationLines = [SELECT Article__r.Name , Prix__c , Prix_Total_TTC__c , Commentaire__c , CurrencyIsoCode FROM Ligne_de_cotation__c WHERE Cotation__c = :quotationId];
        conditions = [SELECT English_version__c , French_version__c FROM Conditions_Generales__c WHERE Name = 'CONDITIONS GENERALES DE PRESTATIONS DE SERVICES' LIMIT 1];
    }
    
}