import { LightningElement, api, track } from 'lwc';

export default class ProductCard extends LightningElement {
    @api productName
    @api productStockLevel
    @api productDescription
    @api productCostPrice
    @api productSupplier
    @api productImage
    @api productCategory
    @api productMinimumStockLevel

    @track expanded = false

    expandDescription() {
        this.expanded = this.expanded == false ? true : false
    }
}