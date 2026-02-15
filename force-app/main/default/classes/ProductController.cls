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

    public static Purchase_Order__c createSinglePO(Product2 productId) {
        
    }
    
}