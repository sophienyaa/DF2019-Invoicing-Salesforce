trigger InvoiceRequestTrigger on Invoice_Requests__e (after insert) {

    //This trigger calls our next 'microservice', this handles the Invoice_Requests__e event and generats an invoice
    System.enqueueJob(new InvoiceRequestService(trigger.new));
     
}