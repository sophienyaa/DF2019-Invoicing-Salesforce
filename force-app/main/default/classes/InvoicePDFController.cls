public class InvoicePDFController {
    
    public static Date todayDate {get; set;}
    public static Date dueDate {get; set;}
    public static InvoicingDTO.CustomerInformation customerInfo {get; set;}
    public Static List<InvoicingDTO.LineItem> invoiceLines {get; set;}
    public static Decimal totalPrice {get; set;}
    
    public InvoicePDFController() {
        todayDate = date.today();
        dueDate = todayDate.addDays(30);
        customerInfo = (InvoicingDTO.CustomerInformation)JSON.deserialize(System.currentPageReference().getParameters().get('custInfo'), InvoicingDTO.CustomerInformation.class);
        invoiceLines = (List<InvoicingDTO.LineItem>)JSON.deserialize(System.currentPageReference().getParameters().get('invoiceLines'), List<InvoicingDTO.LineItem>.class);
    	totalPrice = calcTotalPrice(invoiceLines);
    }

    private Decimal calcTotalPrice(List<InvoicingDTO.LineItem> invoiceLines) {
        Decimal totalPrice = 0;
        for( InvoicingDTO.LineItem line :invoiceLines) {
            totalPrice = totalPrice + line.itemCost;
        }
        return totalPrice;
    }
}