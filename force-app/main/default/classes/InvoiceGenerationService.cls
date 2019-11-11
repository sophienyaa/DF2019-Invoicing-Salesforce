/* This 'microservice' is responsible for generating invoices based on Invoice_Requests__e platform events
 * It has no direct connection to the Opportunity object, and could be invoked by Invoice_Requests__e generated from
 * any source.
 */
public class InvoiceGenerationService implements Queueable, Database.AllowsCallouts {

    //This generates the invoice on platform from the Generate_Invoice_PDF__e platform event, responds with a Invoice_Response__e event
    private List<Generate_Invoice_PDF__e> invoicesToGenerate; 
    
    //set our list of Generate_Invoice_PDF__e from our constructor
    public InvoiceGenerationService(List<Generate_Invoice_PDF__e> incomingInvoicesToGenerate){
        this.invoicesToGenerate = incomingInvoicesToGenerate;  
    }
     
    //process the Generate_Invoice_PDF__e records
    public void execute(QueueableContext context) {

        List<Invoice_PDF__e> generatedInvoicePDFs = new List<Invoice_PDF__e >();
        
        for(Generate_Invoice_PDF__e invoice :invoicesToGenerate) {
            
            Invoice_PDF__e invoicePDF = new Invoice_PDF__e();   
            
            //Use VisualForce to generate our invoices, this counts as a callout
            PageReference pdf = Page.InvoicePDF;
            pdf.getParameters().put('invoiceData', JSON.serialize(invoice));
            pdf.setRedirect(true);
            
            //Populate our Invoice_PDF__e platform event with the invoice and its info
            invoicePDF.Invoice_PDF_Base64__c = EncodingUtil.base64Encode(pdf.getContent());
            invoicePDF.Related_Object_Id__c  = invoice.Source_Record_Id__c;
            invoicePDF.Invoice_Number__c = invoice.Invoice_Number__c;
            
            generatedInvoicePDFs.add(invoicePDF);
        }
        
        // Reference the attachment page and pass in the Id
        List<Database.SaveResult> sr = EventBus.publish(generatedInvoicePDFs);
        
    }
   
}