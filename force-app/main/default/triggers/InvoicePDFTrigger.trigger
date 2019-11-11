trigger InvoicePDFTrigger on Invoice_PDF__e (after insert) {
    
    //This calls our service class to save the incoming invoice PDF
    InvoicePDFService.SaveInvoicePDF(trigger.new);

}