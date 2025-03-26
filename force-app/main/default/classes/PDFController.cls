public with sharing class PDFController {
    
    public String recordId{ get; set; }
    public String quotaToBeCalled{ get; set; }
    public String cotationLanguage { get; set; }
    public String cotationName { get; set; }            


    // Constructor to retrieve recordId from page parameters
    public PDFController(ApexPages.StandardController controller) {
        this.recordId = ApexPages.currentPage().getParameters().get('id');
        Cotation__c cotation = [SELECT Name, Type_de_service__c ,Opportunite__r.Entite_Juridique__c, Langue_des_conditions_generales__c FROM Cotation__c WHERE Id = :this.recordId];
        cotationName = cotation.Name;
        
        cotationLanguage = cotation.Langue_des_conditions_generales__c ;

    

        if(Label.PDF_Quota_1_ApplicableServiceTypes.split(',').contains(cotation.Type_de_service__c)){
            quotaToBeCalled = 'VF_Cotation';
        }
        else if(Label.PDF_Quota_2_ApplicableServiceTypes.split(',').contains(cotation.Type_de_service__c)){
            quotaToBeCalled = 'VF_Cotation_2';
        }

    }


    // Confirm button logic: Associate the PDF with the record
    public PageReference confirmPDF() {
        
        try {            
            // Generate the PDF as a Blob
            PageReference pdfPage = new PageReference('/apex/' + quotaToBeCalled);
            pdfPage.getParameters().put('id', this.recordId);
            pdfPage.getParameters().put('cotationLanguage', cotationLanguage);
            system.debug('pdfPage : --' + pdfPage);
            Blob pdfBlob = Test.isRunningTest() ? Blob.valueOf('UNIT.TEST') : pdfPage.getContent();
            // Create ContentVersion (File) record
            ContentVersion cv = new ContentVersion();
            cv.Title = cotationName;
            cv.PathOnClient = cotationName + '.pdf';
            cv.VersionData = pdfBlob;
            insert cv;
            // Fetch the ContentDocument ID associated with the ContentVersion
            Id contentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id].ContentDocumentId;
            
            // Create a ContentDocumentLink to associate the file with the record
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.LinkedEntityId = recordId;
            cdl.ContentDocumentId = contentDocumentId;
            cdl.ShareType = 'I'; // 'I' means the file is visible only to the record's users
            cdl.Visibility = 'AllUsers';
            insert cdl;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'PDF successfully associated with the record!'));
        } catch (Exception ex) {
            system.debug('exception : ' + ex);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error: ' + ex.getMessage()));
        }
        return closeModal();
    }
    
    // Deny button logic: Close modal and refresh
    public PageReference closeModal() {
        String url = '/' + this.recordId;
        PageReference page = new PageReference(url);
        page.setRedirect(true);
        system.debug(page);
        return page;
    }
    
    
}