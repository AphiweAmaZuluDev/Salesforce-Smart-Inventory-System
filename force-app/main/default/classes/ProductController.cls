public with sharing class ProductController {
    public ProductController() {
        
    }

    // Method to retrieve products from the database.
    @AuraEnabled(cacheable=true)
    public static List<Product2> retrieveProducts() {
        try {
            List<Product2> products = [SELECT Id, Name, Current_Stock_Level__c, Cost_Price__c, Product_Image__c, Primary_Supplier__r.Name, Description, Category__c, Minimum_Stock_Level__c, Barcode_ID__c FROM Product2 WHERE Category__c = 'Clothing'];
            return products;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    // Method to Create a purchase order when a Restock is Requested.
    @AuraEnabled    
    public static void createSinglePO(String productId, Integer quantity) {
        // Validate Inputs
        if(productId == null || quantity <= 0) {
            throw new AuraHandledException('Invalid Product ID or Quantity Value');
        }

        // Security/CRUD check
        if(!Schema.SObjectType.Purchase_Order__c.isCreateable() || !Schema.SObjectType.Purchase_Order_Line_Item__c.isCreateable()) {
            throw new AuraHandledException('You do not have permission to create purchase orders.');
        }

        // Create the Purchase Order & Line Items.
        try {
            // Query current product.
            Product2 product = [SELECT Id, Name, Primary_Supplier__c, Cost_Price__c FROM Product2 Where Id = :productId LIMIT 1];

            if(product.Primary_Supplier__c == null) {
                throw new AuraHandledException('This product does not have a primary supplier hence the purchase order cannot be made. Please go to the product record and select a supplier for this product.');
            }

            // Create Purchase order Record.
            Purchase_Order__c po = new Purchase_Order__c(
                Supplier__c = product.Primary_Supplier__c,
                Status__c = 'Draft'
            );
            insert po;

            // Create Purchase Order Line Item Record.
            Purchase_Order_Line_Item__c lineItem = new Purchase_Order_Line_Item__c(
                Purchase_Order__c = po.Id,
                Product__c = product.Id,
                Quantity__c = quantity,
                Unit_Cost__c = product.Cost_Price__c
            );
            insert lineItem;

        } catch (DmlException e) {
            throw new AuraHandledException('The following error occured while creating the Purchase Order:' + e.getMessage());            
        } catch (Exception e) {
            throw new AuraHandledException('Unexpected Error: ' + e.getMessage());
        }
    }
    
    // Method used to Search for products using the barcode in QuickAdjust Aura Component.
    @AuraEnabled
    public static Product2 searchUsingBarcode(String barcodeID) {
        try{
            product2 product = [SELECT Id, Name, Current_Stock_Level__c, Cost_Price__c, Barcode_ID__c, Product_Image__c FROM Product2 WHERE Barcode_ID__c = :barcodeID LIMIT 1];
            return product != null ? product : null;
        } catch(Exception e) {
            throw new AuraHandledException('Product not found. Error: ' + e);
        }
        
    }

    // Method used to update the stock level of a product.
    @AuraEnabled
    public static void updateInventory(String productId, Integer adjustmentAmount) {
        List<product2> product = [SELECT Id, Name, Current_Stock_Level__c, Cost_Price__c, Barcode_ID__c FROM Product2 WHERE Id = :productId LIMIT 1];

        if(!product.isEmpty()) {
            product[0].Current_Stock_Level__c += adjustmentAmount;
            update product;
        } else {
            throw new AuraHandledException('Product not found');
        }
    }
}