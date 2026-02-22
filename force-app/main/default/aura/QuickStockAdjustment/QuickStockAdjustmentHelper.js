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
    
    applyChanges: function(component, productID, adjustmentAmount) {
        const action = component.get('c.updateInventory')
        
        action.setParams({
            productId: productID,
            adjustmentAmount: adjustmentAmount
        })

        action.setCallback(this, (response) => {
            const state = response.getState()
            if(state ==="SUCCESS") {
                component.find('inventoryChannel').publish()
                const productStock = component.get('v.searchedProduct').Current_Stock_Level__c
                component.set('v.searchedProduct.Current_Stock_Level__c', productStock + adjustmentAmount)
            } else {
                console.error('Failed to update inventory. Failed with status: ' + state)
            }
        })

        $A.enqueueAction(action)
    }
})