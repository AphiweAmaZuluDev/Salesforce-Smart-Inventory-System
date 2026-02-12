public with sharing class ProductTriggerHandler {
    public static void handleBeforeUpdate(List<Product2> productRecordsToUpdate) {
        for(Product2 p : productRecordsToUpdate) {
            if(p.Current_Stock_Level__c < 0) {
                p.addError('Current Stock Level cannot be less than 0');
            } 
        }
    }
}