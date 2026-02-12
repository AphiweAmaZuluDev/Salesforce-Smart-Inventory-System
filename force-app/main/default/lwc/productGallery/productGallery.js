import { LightningElement } from 'lwc';

export default class ProductGallery extends LightningElement {
    products = [
        {
        Name:"Blue Shirt",
        Price: 100,
        Description: "This is a blue shirt"
        }, 
        {
        Name:"Red Shirt",
        Price: 100,
        Description: "This is a red shirt"
        }, 
        {
        Name:"Green Shirt",
        Price: 100,
        Description: "This is a green shirt"
        },
    ] 
}