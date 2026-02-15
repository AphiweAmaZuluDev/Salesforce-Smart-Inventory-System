import { LightningElement, api } from 'lwc';

export default class ProductCard extends LightningElement {
    @api productName
    @api productStockLevel
    @api productDescription
    @api productCostPrice
    @api productSupplier
    @api productImage
    @api productCategory
}