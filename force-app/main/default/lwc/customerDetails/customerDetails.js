import { LightningElement, api, track } from "lwc";

export default class CustomerDetails extends LightningElement {
  @api value;
  @track customerData;
  @track rentalDataList;

  connectedCallback() {
    console.log("customerDetails value -> ", JSON.stringify(this.value));
    this.customerData = this.value.customerDetails;
    this.rentalDataList = this.value.rentalDetailsList;
  }
}
