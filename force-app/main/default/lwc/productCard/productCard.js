import { LightningElement, api } from 'lwc';

export default class ProductCard extends LightningElement {
    @api productName
    @api productPrice
    @api productDescription
}