/*
 * This class is our first 'microservice'
 * 
 * It takes an opportunity change event, gets the relivent opportunities and line items and builds a List of Invoice_Requests__e
 * platform events. These platform events are then picked up by the next 'microservice' that will generate an invoice based on their 
 * contents. This 'microservice' doesn't need to exist inside of salesforce, but in our cases it is easier.
*/
public class OpportunityChangeEventService {
    
	//Method to build and fire an Invoice_Requests__e platform event for the invoicing engine to handle
    public static void FireInvoicingRequestPE(List<OpportunityChangeEvent> events) {
        
        List<Id> oppIds = new List<Id>();
        List<Invoice_Requests__e> requests = new List<Invoice_Requests__e>();
        
        //Get the opp ids from the change event where they are closed/won
        for (OpportunityChangeEvent event : events) { 
            if(event.StageName == 'Closed Won') {
                EventBus.ChangeEventHeader header = event.ChangeEventHeader;
                oppIds.add(header.getRecordIds()[0]);
             }
        }
        
        //get the opp details
        Map<Id, Opportunity> opps = New Map<Id, Opportunity>(
            [ SELECT Id, Name, Account.Name, Account.BillingStreet, Account.BillingCity, Account.BillingPostalCode, Invoice_Number__c,
              Account.BillingCountry, Contact__r.FirstName, Contact__r.LastName, Contact__r.Email, Contact__r.Phone, Notes__c
              FROM Opportunity WHERE Id IN :oppIds]
        );
        
        //get the oli details
        Map<Id, List<OpportunityLineItem>> oliMap = new Map<Id, List<OpportunityLineItem>>();
        List<OpportunityLineItem> olis = [ SELECT Id, Quantity, UnitPrice, Product2.Name, Description, TotalPrice, OpportunityId, 
                                          ProductCode, ListPrice
                                          FROM OpportunityLineItem WHERE OpportunityId IN :oppIds ORDER BY OpportunityId];
        
        for(OpportunityLineItem oli :olis) {
            if(oliMap.get(oli.OpportunityId) == null) { //no OLIs yet, create a map entry
                List<OpportunityLineItem> mapOlis = new List<OpportunityLineItem>();
                mapOlis.add(oli);
                oliMap.put(oli.OpportunityId, mapOlis);
            }
            else { //has OLIs, get list from map, append and re-add to map
                List<OpportunityLineItem> mapOlis = oliMap.get(oli.OpportunityId);
                mapOlis.add(oli);
                oliMap.put(oli.OpportunityId, mapOlis);
            }
        }
            
        for(Id oppId : opps.keySet()) {
            Invoice_Requests__e invReq = new Invoice_Requests__e();
            
            //Populate our CustomerInfo object with info from the opp and JSON serialise it
            invReq.Customer_Information__c = JSON.serialize(oppToCustomerInfo(opps.get(oppId)));
            
            //Populate our LineItem object with info from the OLIs and JSON serialise it
            invReq.Line_Item_Information__c = JSON.serialize(oliToLineItems(oliMap.get(oppId)));
            
            requests.add(invReq);
        }
        
        //Fire the Platform Events
        List<Database.SaveResult> sr = EventBus.publish(requests);

    }
    
    //converts an opp to a CustomerInformation object
    private static InvoicingDTO.CustomerInformation oppToCustomerInfo(Opportunity opp) {
        
        InvoicingDTO.CustomerInformation custInfo = new InvoicingDTO.CustomerInformation();
        
        custInfo.companyName = opp.Account.Name;
        custInfo.customerName = opp.Contact__r.FirstName + ' ' + opp.Contact__r.LastName;
        custInfo.addressStreet = opp.Account.BillingStreet;
        custInfo.postcode = opp.Account.BillingPostalCode;
        custInfo.city = opp.Account.BillingCity;
        custInfo.country = opp.Account.BillingCountry;
        custInfo.phone = opp.Contact__r.Phone;
        custInfo.email = opp.Contact__r.Email;
        custInfo.notes = opp.Notes__c;
        custInfo.oppName = opp.Name;
        custInfo.oppId = opp.Id;
        custInfo.invoiceNumber = opp.Invoice_Number__c;
        
        return custInfo;  
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