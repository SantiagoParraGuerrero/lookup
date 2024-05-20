import { LightningElement, api } from "lwc";

export default class LookupValueFormatter extends LightningElement {
  @api typeAttributes;
  @api value;
  @api type;

  get isLightningFormattedNumber() {
    return this.type === "lightning-formatted-number";
  }

  get isLightningFormattedDateTime() {
    return this.type === "lightning-formatted-date-time";
  }

  get isLightningIcon() {
    return this.type === "lightning-icon";
  }

  get isLightningFormattedRichText() {
    return this.type === "lightning-formatted-rich-text";
  }

  get isLightningFormattedText() {
    return this.type === "lightning-formatted-text";
  }
                                                                                                                                                                  
  get isLightningFormattedEmail() {
    return this.type === "lightning-formatted-email";
  }
}
