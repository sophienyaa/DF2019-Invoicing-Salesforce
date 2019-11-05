trigger OpportunityChangeEventTrigger on OpportunityChangeEvent (after insert) {
    
    //This fires the Invoicing Request platform event
    OpportunityChangeEventService.FireInvoicingRequestPE(trigger.new);

}