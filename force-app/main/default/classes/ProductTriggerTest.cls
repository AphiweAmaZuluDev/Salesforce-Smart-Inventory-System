@isTest
private class ProductTriggerTest {
    @isTest
    static void beforeUpdateTest() {
        
        Test.startTest();
        List<Product2> products = TestDataFactory.createProducts(1);
        products[0].Current_Stock_Level__c = -1;
        Database.SaveResult result = Database.update(products[0], false);
        Test.stopTest();

        Assert.isFalse(result.isSuccess());
        Assert.areEqual('Current Stock Level cannot be less than 0', result.getErrors()[0].getMessage(), 'The Validation Error Message does not match');
    }
}