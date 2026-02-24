@isTest
private class InventoryCheckBatchTest {
    
    @testSetup
    static void setupTestData() {
        Account supplier = new Account(Name = 'Batch Test Supplier');
        insert supplier;
        
        List<Product2> products = TestDataFactory.createProducts(4);
        
        // Products 0 & 1: Valid Clothing products with a supplier
        for(Integer i = 0; i < 2; i++) {
            products[i].Category__c = 'Clothing';
            products[i].Primary_Supplier__c = supplier.Id;
            products[i].Cost_Price__c = 10.00;
            products[i].IsActive = true;
        }
        
        // Product 2: Valid Clothing product WITHOUT a supplier
        products[2].Category__c = 'Clothing';
        products[2].Primary_Supplier__c = null;
        products[2].Cost_Price__c = 15.00;
        products[2].IsActive = true;
        
        // Product 3: Inactive product (Should be ignored by the batch)
        products[3].Category__c = 'Clothing';
        products[3].Primary_Supplier__c = supplier.Id;
        products[3].IsActive = false;
        
        update products;
    }

    @isTest
    static void testBatchExecution() {
        // Verify initial state
        System.assertEquals(0, [SELECT Count() FROM Purchase_Order__c], 'There should be no POs before the batch runs.');
        
        Test.startTest();
        // Execute the batch
        InventoryCheckBatch batch = new InventoryCheckBatch();
        Database.executeBatch(batch);
        Test.stopTest(); // The batch physically executes and finishes when stopTest() is called.
        
        // 1. Verify POs were created only for active Clothing products WITH a supplier (Products 0 & 1)
        List<Purchase_Order__c> createdPOs = [SELECT Id, Supplier__c FROM Purchase_Order__c];
        System.assertEquals(2, createdPOs.size(), 'Two Purchase Orders should have been created.');
        
        // 2. Verify Line Items were created with the default quantity of 5
        List<Purchase_Order_Line_Item__c> createdLines = [SELECT Id, Quantity__c, Unit_Cost__c FROM Purchase_Order_Line_Item__c];
        System.assertEquals(2, createdLines.size(), 'Two Line Items should have been created.');
        
        for(Purchase_Order_Line_Item__c line : createdLines) {
            System.assertEquals(5, line.Quantity__c, 'Default quantity added should be 5.');
            System.assertEquals(10.00, line.Unit_Cost__c, 'Unit cost should map to the product Cost Price.');
        }
    }

    @isTest
    static void testCreateSinglePO_InvalidInputs() {
        Test.startTest();
        try {
            // Intentionally pass bad data to trigger the validation rule
            ProductController.createSinglePO(null, 0);
            System.assert(false, 'An exception should have been thrown for invalid inputs.');
        } catch (Exception e) {
            // If we get here, the code successfully caught the bad input!
            System.assertNotEquals(null, e, 'Exception was successfully thrown.');
        }
        Test.stopTest();
    }

    @isTest
    static void testSearchUsingBarcode_NotFound() {
        Test.startTest();
        try {
            // Intentionally search for a barcode that is not in the database
            ProductController.searchUsingBarcode('FAKE-BARCODE-999');
            System.assert(false, 'An exception should have been thrown because the product does not exist.');
        } catch (Exception e) {
            // The catch block in your controller successfully handled the query error!
            System.assertNotEquals(null, e, 'Exception was successfully thrown.');
        }
        Test.stopTest();
    }
}