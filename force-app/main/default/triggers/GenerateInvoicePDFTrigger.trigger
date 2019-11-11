trigger GenerateInvoicePDFTrigger on Generate_Invoice_PDF__e (after insert) {
    
    //This trigger calls our next 'microservice', this handles the Generate_Invoice_PDF__e event and generats an invoice
    System.enqueueJob(new InvoiceGenerationService(trigger.new));

}