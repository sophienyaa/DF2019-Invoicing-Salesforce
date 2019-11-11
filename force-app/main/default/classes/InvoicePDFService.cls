public class InvoicePDFService {
        
    /*
     * this creates attachment records each Invoice_PDF__e record in the given list and attaches 
     * them to the related object specified in the Invoice_PDF__e event
	 */
    public static void SaveInvoicePDF(List<Invoice_PDF__e> incomingInvoicePDFs) {
        
        List<Attachment> attachmentsToInsert = new List<Attachment>();
        
        for(Invoice_PDF__e invoicePDF :incomingInvoicePDFs) {
            Attachment newAttachment = new Attachment();
            newAttachment.Body = EncodingUtil.base64Decode(invoicePDF.Invoice_PDF_Base64__c);
            newAttachment.ParentId = invoicePDF.Related_Object_Id__c;
            newAttachment.Name = 'Invoice - ' + invoicePDF.Invoice_Number__c + '.pdf';
            newAttachment.contentType = 'application/pdf';
            attachmentsToInsert.add(newAttachment); 
        }
        
        insert attachmentsToInsert;
        
    }

}