public class InvoicePDFController {
    
    public static Date todayDate {get; set;}
    public static Date dueDate {get; set;}
    public static Generate_Invoice_PDF__e invoiceData {get; set;}
    public Static List<InvoicingDTO.LineItem> invoiceLines {get; set;}
    public static Decimal totalPrice {get; set;}
    
    public InvoicePDFController() {
        todayDate = date.today();
        dueDate = todayDate.addDays(30);
        invoiceData = (Generate_Invoice_PDF__e) JSON.deserialize(System.currentPageReference().getParameters().get('invoiceData'), Generate_Invoice_PDF__e.class);
        invoiceLines = (List<InvoicingDTO.LineItem>)JSON.deserialize(invoiceData.Invoice_Line_Item_JSON__c, List<InvoicingDTO.LineItem>.class);
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