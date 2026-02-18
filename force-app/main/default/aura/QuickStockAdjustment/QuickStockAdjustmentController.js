({
    handleIncrement : function(component, event, helper) {
        const productID = component.get('v.searchedProduct').Id
        helper.increaseStock(component, productID)
    },

     handleDecrement : function(component, event, helper) {
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
    }
})