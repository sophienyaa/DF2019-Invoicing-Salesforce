trigger InvoiceResponseTrigger on Invoice_Response__e (after insert) {
    
    InvoiceResponseService.SaveInvoiceResponse(trigger.new);

}