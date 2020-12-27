/*
 * This class is our first 'microservice'
 * 
 * It takes an opportunity change event, gets the relivent opportunities and line items and builds a List of Generate_Invoice_PDF__e
 * platform events. These platform events are then picked up by the next 'microservice' that will generate an invoice based on their 
 * contents. This 'microservice' doesn't need to exist inside of salesforce, but in our cases it is easier.
*/
public class OpportunityChangeEventService {
    
	//Method to build and fire an Generate_Invoice_PDF__e platform event for the invoicing engine to handle
    public static void FireInvoicingRequestPE(List<OpportunityChangeEvent> events) {
        
        List<Id> oppIds = new List<Id>();
        List<Generate_Invoice_PDF__e> invoicesToGenerate = new List<Generate_Invoice_PDF__e>();
        
        //Get the opp ids from the change event where they are closed/won
        for (OpportunityChangeEvent event : events) { 
            if(event.StageName == 'Closed Won') {
                EventBus.ChangeEventHeader header = event.ChangeEventHeader;
                oppIds.addAll(header.getRecordIds());
             }
        }
        
        // for those opps, get their details and related OLIs
        List<Opportunity> opps = [SELECT Id, Name, Account.Name, Account.BillingStreet, Account.BillingCity, 
                                  Account.BillingPostalCode, Invoice_Number__c,
              					  Account.BillingCountry, Contact__r.FirstName, Contact__r.LastName, 
                                  Contact__r.Email, Contact__r.Phone, Notes__c, 
             					 (SELECT Id, Quantity, UnitPrice, Product2.Name, Description, TotalPrice, 
                                  OpportunityId, ProductCode, ListPrice 
                                  FROM OpportunityLineItems)
              					  FROM Opportunity 
                                  WHERE Id IN :oppIds];

        // for each opp and its olis, build a Generate_Invoice_PDF__e platform event
        for(Opportunity opp :opps) {
            invoicesToGenerate.add(oppAndOLIsToGenerateInvoicePDFEvent(opp));
        }
        
        // fire the generated platform events
        List<Database.SaveResult> sr = EventBus.publish(invoicesToGenerate);

    }
    
    //converts an opp and its OLIs to a CustomerInformation object
    private static Generate_Invoice_PDF__e oppAndOLIsToGenerateInvoicePDFEvent(Opportunity opp) {
        
        Generate_Invoice_PDF__e generateInvoicePDF = new Generate_Invoice_PDF__e();
        
        generateInvoicePDF.Company_Name__c = opp.Account.Name;
        generateInvoicePDF.Customer_Name__c = opp.Contact__r.FirstName + ' ' + opp.Contact__r.LastName;
        generateInvoicePDF.Address_Street__c = opp.Account.BillingStreet;
        generateInvoicePDF.Postcode__c = opp.Account.BillingPostalCode;
        generateInvoicePDF.City__c = opp.Account.BillingCity;
        generateInvoicePDF.Country__c = opp.Account.BillingCountry;
        generateInvoicePDF.Phone__c = opp.Contact__r.Phone;
        generateInvoicePDF.Email__c = opp.Contact__r.Email;
        generateInvoicePDF.Notes__c = opp.Notes__c;
        generateInvoicePDF.Source_Record_Name__c = opp.Name;
        generateInvoicePDF.Source_Record_Id__c = opp.Id;
        generateInvoicePDF.Invoice_Number__c = opp.Invoice_Number__c;
        generateInvoicePDF.Invoice_Line_Item_JSON__c = JSON.serialize(oliToLineItems(opp.OpportunityLineItems));
        
        return generateInvoicePDF;  
    }
    
    //converts a list of opp line items to a list of LineItem objects
    private static List<InvoicingDTO.LineItem> oliToLineItems(List<OpportunityLineItem> olis) {
        List<InvoicingDTO.LineItem> lineItems = new List<InvoicingDTO.LineItem>();
        
        for(OpportunityLineItem oli :olis) {
            InvoicingDTO.LineItem item = new InvoicingDTO.LineItem();
            item.itemCost = oli.UnitPrice;
            item.itemPrice = oli.ListPrice;
            item.lineDescription = oli.Product2.Name;
            item.oliId = oli.Id;
            item.quantity = oli.Quantity;
            item.productCode = oli.ProductCode;
            lineItems.add(item);
        }
        
        return lineItems;
    }
    
}
