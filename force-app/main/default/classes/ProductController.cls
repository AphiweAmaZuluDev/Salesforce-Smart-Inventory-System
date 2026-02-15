public with sharing class ProductController {
    public ProductController() {
        
    }

    @AuraEnabled(cacheable=true)
    public static List<Product2> retrieveProducts(){
        try {
            List<Product2> products = [SELECT Id, Name, Current_Stock_Level__c, Cost_Price__c, Product_Image__c, Primary_Supplier__r.Name, Description, Category__c, Minimum_Stock_Level__c FROM Product2 WHERE Category__c = 'Clothing'];
            return products;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
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
            Product2 product = [SELECT Id, Name, Primary_Supplier__c, Cost_Price__c FROM Product2 Where Id = :productId LIMIT 1];

            if(product.Primary_Supplier__c == null) {
                throw new AuraHandledException('This product does not have a primary supplier hence the purchase order cannot be made. Please go to the product record and select a supplier for this product.');
            }

            Purchase_Order__c po = new Purchase_Order__c(
                Supplier__c = product.Primary_Supplier__c,
                Status__c = 'Draft'
            );
            insert po;

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
    
}