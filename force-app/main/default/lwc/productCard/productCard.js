import { LightningElement, api, track } from 'lwc';
import createSinglePO from '@salesforce/apex/ProductController.createSinglePO';
import ShowToastEvent from 'lightning/platformShowToastEvent';

export default class ProductCard extends LightningElement {
    @api productName
    @api productStockLevel
    @api productDescription
    @api productCostPrice
    @api productSupplier
    @api productImage
    @api productCategory
    @api productMinimumStockLevel
    @api productId

    @track expanded = false

    expandDescription() {
        this.expanded = this.expanded == false ? true : false
    }

    handleRestock() {
        createSinglePO({
            productId: this.productId,
            quantity: 10})
            .then(() => {
                const evt = new ShowToastEvent({
                    title: 'Success',
                    message: 'Purchase Order Created',
                    variant: 'success',
                    mode: 'dismissable'
                })
                this.dispatchEvent(evt)
                const refreshEvent = new CustomEvent('refreshRequest')
                this.dispatchEvent(refreshEvent, {bubbles: false}, {composed: false})
            })
    }
}