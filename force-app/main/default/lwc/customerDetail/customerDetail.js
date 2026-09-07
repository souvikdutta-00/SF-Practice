import { LightningElement, api } from 'lwc';

export default class CustomerDetail extends LightningElement {
    _value = {};
    customerDetails = {};
    rentalDetailsList = [];

    @api
    get value() {
        return this._value;
    }

    set value(data) {
        this._value = data;
        if (data) {
            this.customerDetails = data.customerDetails || {};
            this.rentalDetailsList = data.rentalDetailsList || [];
        }
    }

    get fullName() {
        return `${this.customerDetails.firstName || ''} ${this.customerDetails.lastName || ''}`.trim();
    }

    get dateOfBirth() {
        return this.customerDetails.dateOfBirth || '';
    }

    get gender() {
        return this.customerDetails.gender || '';
    }

    get loyaltyPoints() {
        return this.customerDetails.loyaltyPoints || '';
    }

    get email() {
        return this.customerDetails.email || '';
    }

    get phone() {
        return this.customerDetails.phone || '';
    }

    get hasRentals() {
        return this.rentalDetailsList && this.rentalDetailsList.length > 0;
    }
}