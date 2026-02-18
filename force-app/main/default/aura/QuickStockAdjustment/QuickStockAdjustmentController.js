({
    handleIncrement : function(component, event, helper) {
        const productID = component.get('v.searchedProduct').Id
        QuickStockAdjustmentHelper.increaseStock(productID)
    },

     handleDecrement : function(component, event, helper) {
        const productID = component.get('v.searchedProduct').Id
        QuickStockAdjustmentHelper.decreaseStock(productID)
    },

    handleSearch : function(component, event, helper) {
        const searchTerm = component.get('v.searchTerm')
        QuickStockAdjustmentHelper.fetchProduct(searchTerm)
    },

    handleInputChange : function(component, event, helper) {
        const searchTerm = event.getSource().get('v.value')
        component.set('v.searchTerm', searchTerm)
    }
})