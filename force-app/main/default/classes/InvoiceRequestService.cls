/* This 'microservice' is responsible for generating invoices based on Invoice_Requests__e platform events
 * It has no direct connection to the Opportunity object, and could be invoked by Invoice_Requests__e generated from
 * any source.
 */
public class InvoiceRequestService implements Queueable, Database.AllowsCallouts {

    //This generates the invoice on platform from the Invoice_Requests__e platform event, responds with a Invoice_Response__e event
    public List<Invoice_Requests__e> invList; 
    
    public InvoiceRequestService(List<Invoice_Requests__e> invoices){
        this.invList = invoices;  
    }
     
    public void execute(QueueableContext context) {

        List<Invoice_Response__e> responses = new List<Invoice_Response__e>();
        
        for(Invoice_Requests__e invoice :invList) {
            
            InvoicingDTO.CustomerInformation custInfo = (InvoicingDTO.CustomerInformation)JSON.deserialize(invoice.Customer_Information__c, InvoicingDTO.CustomerInformation.class);
            List<InvoicingDTO.LineItem> invoiceLines = (List<InvoicingDTO.LineItem>)JSON.deserialize(invoice.Line_Item_Information__c, List<InvoicingDTO.LineItem>.class);

            Invoice_Response__e response = new Invoice_Response__e();   
            
            PageReference pdf = Page.InvoicePDF;
            pdf.getParameters().put('custInfo',JSON.serialize(custInfo));
            pdf.getParameters().put('invoiceLines',JSON.serialize(invoiceLines));

            pdf.setRedirect(true);
            
            response.Invoice_PDF_Base64__c = EncodingUtil.base64Encode(pdf.getContent());
            response.Related_OppId__c = custInfo.oppId;
            response.Invoice_Number__c = custInfo.invoiceNumber;
            
            responses.add(response);
        }
        
        // Reference the attachment page and pass in the Id
        List<Database.SaveResult> sr = EventBus.publish(responses);
        
    }
   
}