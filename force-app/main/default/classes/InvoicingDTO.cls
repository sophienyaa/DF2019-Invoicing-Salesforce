public class InvoicingDTO {
    
    //generic object to hold customer information for invoicing
    public class CustomerInformation {
        public String companyName {get; set;}
        public String customerName {get; set;}
        public String addressStreet {get; set;}
        public String postcode {get; set;}
        public String city {get; set;}
        public String country {get; set;}
        public String phone {get; set;}
        public String email {get; set;}
        public String notes {get; set;}
        public String oppName {get; set;}
        public String oppId {get; set;}
        public String invoiceNumber {get; set;}
    }
    
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