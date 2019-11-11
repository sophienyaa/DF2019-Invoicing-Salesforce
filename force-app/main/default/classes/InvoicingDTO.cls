public class InvoicingDTO {

    //generic object to hold line item information for invoicing
    public class LineItem {
        public String lineDescription {get; set;}
        public String productCode {get; set;}
        public Decimal quantity {get; set;}
        public Decimal itemCost {get; set;}
        public Decimal itemPrice {get; set;}
        public String oliId {get; set;}
    }
    
}