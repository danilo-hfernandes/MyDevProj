import { LightningElement, api } from 'lwc';

export default class CustomNameCell extends LightningElement {
    @api name;
    @api url;
}