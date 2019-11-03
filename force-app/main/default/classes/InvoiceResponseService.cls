public class InvoiceResponseService {
    
    public static void SaveInvoiceResponse(List<Invoice_Response__e> responses) {
        
        List<Attachment> atts = new List<Attachment>();
        
        for(Invoice_Response__e response :responses) {
            Attachment att = new Attachment();
            att.Body = EncodingUtil.base64Decode(response.Invoice_PDF_Base64__c);
            att.ParentId = response.Related_OppId__c;
            att.Name = 'Invoice - ' + response.Invoice_Number__c + '.pdf';
            att.contentType = 'application/pdf';
            atts.add(att); 
        }
        
        insert atts;
        
    }

}