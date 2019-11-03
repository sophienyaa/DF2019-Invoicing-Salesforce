public class InvoicePDFController {
    
    public static Date todayDate {get; set;}
    public static Date dueDate {get; set;}
    public static OpportunityChangeEventHandler.CustomerInformation customerInfo {get; set;}
    public Static List<OpportunityChangeEventHandler.LineItem> invoiceLines {get; set;}
    public static Decimal totalPrice {get; set;}
    
    public InvoicePDFController() {
        todayDate = date.today();
        dueDate = todayDate.addDays(30);
        customerInfo = (OpportunityChangeEventHandler.CustomerInformation)JSON.deserialize(System.currentPageReference().getParameters().get('custInfo'), OpportunityChangeEventHandler.CustomerInformation.class);
        invoiceLines = (List<OpportunityChangeEventHandler.LineItem>)JSON.deserialize(System.currentPageReference().getParameters().get('invoiceLines'), List<OpportunityChangeEventHandler.LineItem>.class);
    	totalPrice = calcTotalPrice(invoiceLines);
    }

    private Decimal calcTotalPrice(List<OpportunityChangeEventHandler.LineItem> invoiceLines) {
        Decimal totalPrice = 0;
        for( OpportunityChangeEventHandler.LineItem line :invoiceLines) {
            totalPrice = totalPrice + line.itemCost;
        }
        return totalPrice;
    }
}