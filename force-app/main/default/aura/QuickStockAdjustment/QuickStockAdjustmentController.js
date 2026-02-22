({
    handleIncrement : function(component, event, helper) {
        const currentValue = component.get('v.valueToAdjustBy')
        component.set('v.valueToAdjustBy', currentValue + 1)
        const productID = component.get('v.searchedProduct').Id
        helper.increaseStock(component, productID)
    },

     handleDecrement : function(component, event, helper) {
        const currentValue = component.get('v.valueToAdjustBy')
        component.set('v.valueToAdjustBy', currentValue - 1)
        const productID = component.get('v.searchedProduct').Id
        helper.decreaseStock(component, productID)
    },

    handleSearch : function(component, event, helper) {
        const searchTerm = component.get('v.searchTerm')
        helper.fetchProduct(component, searchTerm)
    },

    handleInputChange : function(component, event, helper) {
        const searchTerm = event.getSource().get('v.value')
        component.set('v.searchTerm', searchTerm)
    },

    adjustStock: function(component, event, helper) {
        const productID = component.get('v.searchedProduct').Id
        const adjustmentAmount = component.get('v.valueToAdjustBy')
        helper.applyChanges(component, productID, adjustmentAmount)
        component.set('v.valueToAdjustBy', 0)
    }
})