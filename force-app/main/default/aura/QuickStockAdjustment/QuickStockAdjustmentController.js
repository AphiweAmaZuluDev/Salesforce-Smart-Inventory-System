({
    handleIncrement : function(component, event, helper) {

    },

     handleDecrement : function(component, event, helper) {

    },

    handleSearch : function(component, event, helper) {
        const searchTerm = component.get('v.searchTerm')
        console.log(searchTerm)
    },

    handleInputChange : function(component, event, helper) {
        try {
            const searchTerm = event.getSource().get('v.value')
            component.set('v.searchTerm', searchTerm)
        } catch (e) {
            console.error(e)
            console.error(e.stack)
        }
    }
})