@isTest
private class ProductControllerTest {
    
    @testSetup
    static void setupTestData() {
        // 1. Create a primary supplier (Account)
        Account supplier = new Account(Name = 'Test Clothing Supplier');
        insert supplier;
        
        // 2. Create base products using your TestDataFactory
        List<Product2> products = TestDataFactory.createProducts(3);
        
        // 3. Update the products to fit our test scenarios
        // Product 0: Perfect valid product with a supplier
        products[0].Category__c = 'Clothing';
        products[0].Primary_Supplier__c = supplier.Id;
        products[0].Cost_Price__c = 15.00;
        products[0].Current_Stock_Level__c = 10;
        products[0].Barcode_ID__c = 'BARCODE-001';
        products[0].IsActive = true;
        
        // Product 1: Clothing product WITHOUT a supplier (for negative testing)
        products[1].Category__c = 'Clothing';
        products[1].Primary_Supplier__c = null; 
        products[1].Cost_Price__c = 20.00;
        products[1].Current_Stock_Level__c = 5;
        products[1].Barcode_ID__c = 'BARCODE-002';
        products[1].IsActive = true;
        
        // Product 2: Out-of-category product (should not be retrieved)
        products[2].Category__c = 'Electronics'; 
        products[2].Current_Stock_Level__c = 50;
        products[2].Barcode_ID__c = 'BARCODE-003';
        products[2].IsActive = true;
        
        update products;
    }

    @isTest
    static void testRetrieveProducts() {
        Test.startTest();
        List<Product2> results = ProductController.retrieveProducts();
        Test.stopTest();
        
        // Assert that we only got the 2 'Clothing' products, ignoring 'Electronics'
        System.assertEquals(2, results.size(), 'Should only retrieve products in the Clothing category.');
    }

    @isTest
    static void testCreateSinglePO_Success() {
        Product2 validProduct = [SELECT Id FROM Product2 WHERE Barcode_ID__c = 'BARCODE-001' LIMIT 1];
        
        Test.startTest();
        ProductController.createSinglePO(validProduct.Id, 10);
        Test.stopTest();
        
        // Verify PO was created
        List<Purchase_Order__c> pos = [SELECT Id, Status__c, Supplier__c FROM Purchase_Order__c];
        System.assertEquals(1, pos.size(), 'One Purchase Order should have been created.');
        System.assertEquals('Draft', pos[0].Status__c, 'PO Status should be Draft.');
        
        // Verify Line Item was created
        List<Purchase_Order_Line_Item__c> lines = [SELECT Id, Quantity__c, Unit_Cost__c FROM Purchase_Order_Line_Item__c WHERE Purchase_Order__c = :pos[0].Id];
        System.assertEquals(1, lines.size(), 'One PO Line Item should have been created.');
        System.assertEquals(10, lines[0].Quantity__c, 'Quantity should match the input.');
    }

    @isTest
    static void testCreateSinglePO_NoSupplier() {
        Product2 noSupplierProduct = [SELECT Id FROM Product2 WHERE Barcode_ID__c = 'BARCODE-002' LIMIT 1];
        
        Test.startTest();
        try {
            ProductController.createSinglePO(noSupplierProduct.Id, 5);
            System.assert(false, 'Expected an AuraHandledException to be thrown due to missing supplier.');
        } catch (AuraHandledException e) {
            System.assert(e.getMessage().contains('does not have a primary supplier'), 'The exception message should mention the missing supplier.');
        }
        Test.stopTest();
    }

    @isTest
    static void testSearchUsingBarcode_Success() {
        Test.startTest();
        Product2 foundProduct = ProductController.searchUsingBarcode('BARCODE-001');
        Test.stopTest();
        
        System.assertNotEquals(null, foundProduct, 'Product should be found.');
        System.assertEquals('BARCODE-001', foundProduct.Barcode_ID__c, 'Returned product should have the matching barcode.');
    }

    @isTest
    static void testUpdateInventory_Success() {
        Product2 productBefore = [SELECT Id, Current_Stock_Level__c FROM Product2 WHERE Barcode_ID__c = 'BARCODE-001' LIMIT 1];
        System.assertEquals(10, productBefore.Current_Stock_Level__c, 'Initial stock should be 10.');
        
        Test.startTest();
        // Add 5 to the stock
        ProductController.updateInventory(productBefore.Id, 5);
        Test.stopTest();
        
        Product2 productAfter = [SELECT Id, Current_Stock_Level__c FROM Product2 WHERE Id = :productBefore.Id LIMIT 1];
        System.assertEquals(15, productAfter.Current_Stock_Level__c, 'Stock should have been incremented by 5.');
    }
}