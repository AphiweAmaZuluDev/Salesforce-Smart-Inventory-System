public with sharing class InventoryCheckBatch implements Database.Batchable<SObject>, Database.Stateful{
    public InventoryCheckBatch() {

    }

    // Stateful Variables.
    public Integer totalProductsEvaluated = 0;
    public Integer totalPOsCreated = 0;
    public List<String> productsMissingSupplier = new List<String>();

    public Database.QueryLocator start(Database.BatchableContext context) {
        String query = 'SELECT Id, Name, Current_Stock_Level__c, Minimum_Stock_Level__c, Category__c, Primary_Supplier__c, Cost_Price__c FROM Product2 WHERE isActive = true AND Category__c = \'Clothing\' AND Current_Stock_Level__c < Minimum_Stock_Level__c';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext context, List<Product2> scope) {
        Integer defaultQuantityToAdd = 5; // This is the amount of stock to be added to the product.
        
        // Map to link product to its new purchase order.
        Map<Product2,Purchase_Order__c> productToPOMap = new Map<Product2,Purchase_Order__c>();

        // Create purchase orders
        for(Product2 product : scope) {

            totalProductsEvaluated++;
            if(product.Primary_Supplier__c != null) {
                Purchase_Order__c po = new Purchase_Order__c(
                    Supplier__c = product.Primary_Supplier__c,
                    Status__c = 'Draft'
                );
                productToPOMap.put(product, po);
            } else {
                productsMissingSupplier.add(product.Name);
                System.debug(LoggingLevel.ERROR,'This product does not have a supplier: ' + product.Name);
            }
        }
        

        // Create Purchase Order Line Items.
        if(!productToPOMap.isEmpty()) {
            insert productToPOMap.values();

            // Increment number of successful purchase orders created.
            totalPOsCreated += productToPOMap.size();

            List<Purchase_Order_Line_Item__c> lineItemsToInsert = new List<Purchase_Order_Line_Item__c>();

            for(Product2 product : productToPOMap.keySet()) {
                Purchase_Order__c insertedPO = productToPOMap.get(product);

                Purchase_Order_Line_Item__c lineItem = new Purchase_Order_Line_Item__c(
                    Purchase_Order__c = insertedPO.Id,
                    Product__c = product.Id,
                    Quantity__c = defaultQuantityToAdd,
                    Unit_Cost__c = product.Cost_Price__c
                );
                lineItemsToInsert.add(lineItem);
            } 
            
            if(!lineItemsToInsert.isEmpty()) {
                insert lineItemsToInsert;
            }
        } else {
            System.debug('All products have sufficient stock. No purchase orders created.');
        }
    }

    // Send an email to the admin with details of their batch job.
    public void finish(Database.BatchableContext context) {
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        List<String> toAddresses = new List<String>();
        toAddresses.add(System.Label.AdminEmail);
        email.setToAddresses(toAddresses);
        email.setSubject('Inventory Check Batch Completed');

        String body = 'The nightly Inventory Check Batch has finished processing.\n\n';
        body += 'Total Products Evaluated: ' + totalProductsEvaluated + '\n';
        body += 'Total Purchase Orders Created: ' + totalPOsCreated + '\n\n';

        if(!productsMissingSupplier.isEmpty()) {
            body += 'WARNING: The following ' + productsMissingSupplier.size() + ' products did not have a supplier and hence no purchase order was created for them:\n';
            for(String productName : productsMissingSupplier) {
                body += productName + '\n';
            }
        } else {
            body += 'All low-stock products had a primary supplier. No errors encountered.\n';
        }

        email.setPlainTextBody(body);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});

        System.debug('Batch Job Completed and summary email sent to admin.');
    }
}