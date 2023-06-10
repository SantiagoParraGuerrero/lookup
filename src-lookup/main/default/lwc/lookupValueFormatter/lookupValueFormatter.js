import { LightningElement, api } from "lwc";

export default class LookupValueFormatter extends LightningElement {
  @api typeAttributes;
  @api value;
  @api type;

  get isCurrency() {
    return this.type === "currency";
  }

  get isPercent() {
    return this.type === "currency";
  }

  get isBoolean() {
    return this.type === "boolean";
  }

  get isDate() {
    return this.type === "date";
  }

  get isNumber() {
    return this.type === "number";
  }
}
