({
    fetchProduct : function(component, barcodeID) {
        let productFound
        const action = component.get('c.searchUsingBarcode')

        action.setParams({
            barcodeID : barcodeID
        })

        action.setCallback(this, (response) => {
            const state = response.getState()
            if(state === 'SUCCESS') {
                productFound = response.getReturnValue()
                component.set('v.searchedProduct', productFound)
            } else {
                console.error('Cannot find product with defined barcode. Failed with status: ' + state)
            }
        })

        $A.enqueueAction(action)
    },
    
    increaseStock : function(component, adjustmentValue) {
        
    },

    decreaseStock : function(component, adjustmentValue) {
        
    }
})