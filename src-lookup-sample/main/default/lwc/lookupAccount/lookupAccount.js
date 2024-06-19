import { LightningElement, api, track } from "lwc";
import { NavigationMixin } from "lightning/navigation";

export default class LookupAccount extends NavigationMixin( LightningElement ) {

  @track contactPayload;
  accountValue;
  contactValue;
  _accountText;
  _contactText;

  @api
  get accountText() {
    return this._accountText;
  }

  set accountText(value) {
    this._accountText = value;
  }

  @api
  get contactText() {
    return this._contactText;
  }

  set contactText(value) {
    this._contactText = value;
  }

  handleAccountChange(event) {

    this.contactValue = [];
    this._accountText = "";
    this._contactText = "";
    this.accountValue = event.detail.value[0];
    this.contactPayload = { accountId : event.detail.value[0] };

    if (this.accountValue !== undefined) {
      const account = event.detail.payload[this.accountValue];
      this._accountText = `Your account selected was ${account.name}`;
    }
  }

  handleContactChange(event) {

    this._contactText = "";
    this.contactValue = event.detail.value[0];

    if (this.accountValue === undefined || this.contactValue !== undefined) {
      const contact = event.detail.payload[this.contactValue];
      this._contactText = `Your contact selected was ${contact.name} and its phone number is  ${contact.phone}`;
    }
  }

  get accountValueEmpty() {
    return !this.accountValue;
  }
}