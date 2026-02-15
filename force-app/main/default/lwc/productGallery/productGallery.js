import { LightningElement, wire, track } from 'lwc';
import retrieveProducts from '@salesforce/apex/ProductController.retrieveProducts';

export default class ProductGallery extends LightningElement {
    @track products = []
    error

    @wire(retrieveProducts)
    wiredProducts({error, data}) {
        if(data) {
            this.products = data.map(product => {
                return {
                    ...product,
                    Supplier_Name: product.Primary_Supplier__r ? product.Primary_Supplier__r.Name : 'No Supplier',
                }
            })
            this.error = undefined
        } else if (error) {
            this.error = error
            this.products = undefined
            console.log(this.error)
        }
    }

}