import { LightningElement, wire, track } from 'lwc';
import retrieveProducts from '@salesforce/apex/ProductController.retrieveProducts';
import {refreshApex} from '@salesforce/apex';
import { subscribe, MessageContext, APPLICATION_SCOPE } from 'lightning/messageService';
import INVENTORY_UPDATE_CHANNEL from '@salesforce/messageChannel/Inventory_Update__c'

export default class ProductGallery extends LightningElement {
    @track products = []
    error
    wiredProductsResult

    @wire(MessageContext)
    messageContext

    connectedCallback() {
        this.subscribeToMessageChannel()
    }

    subscribeToMessageChannel() {
        if(!this.subscription) {
            // Subscription to Lightning Message Channel.
            this.subscription = subscribe(
                this.messageContext,
                INVENTORY_UPDATE_CHANNEL,
                () => this.handleMessage(),
                {scope: APPLICATION_SCOPE}
            )
        }
    }

    handleMessage() {
        this.handleResfreshRequest()
    }

    // Get the products from the apex controller
    @wire(retrieveProducts)
    wiredProducts(result) {
        this.wiredProductsResult = result

        const {data, error} = result
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

    // refresh the component once values are changed due to restock.
    handleResfreshRequest() {
        return refreshApex(this.wiredProductsResult)
    }
}