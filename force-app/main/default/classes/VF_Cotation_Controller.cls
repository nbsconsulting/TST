public with sharing class VF_Cotation_Controller {
    public String recordId{ get; set; }
    public String cotationLanguage { get; set; }
    public List<Ligne_de_cotation__c> quotationLines{ get; set; }
    public Decimal chargeableTotalValue{ get; set; }
    public Conditions_Generales__c conditions { get; set; }


    // Constructor to retrieve recordId from page parameters
    public VF_Cotation_Controller(ApexPages.StandardController controller) {
        recordId = ApexPages.currentPage().getParameters().get('id');
        Cotation__c cotation = [SELECT Name, Type_de_service__c ,Opportunite__r.Entite_Juridique__c, Langue_des_conditions_generales__c FROM Cotation__c WHERE Id = :recordId];
        
        cotationLanguage = cotation.Langue_des_conditions_generales__c ;
        quotationLines = [SELECT Article__r.Name ,Article__r.TVA__c,  Prix__c ,Prix_Total_HT__c, Prix_Total_TTC__c, Commentaire__c , CurrencyIsoCode FROM Ligne_de_cotation__c WHERE Cotation__c = :recordId];
        conditions = [SELECT English_version__c , French_version__c FROM Conditions_Generales__c WHERE Name = 'CONDITIONS GENERALES DE PRESTATIONS DE SERVICES' LIMIT 1];

        calculateChargeableValue();
    }

    public void calculateChargeableValue(){
       chargeableTotalValue = 0;
        for(Support__c support : [SELECT Chargeable_Value__c FROM Support__c WHERE Cotation__c = :recordId]){
            chargeableTotalValue += support.Chargeable_Value__c;
        }
    }
}