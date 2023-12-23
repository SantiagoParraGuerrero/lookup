import { clone } from "c/utils";
import { reduceErrors } from "c/ldsUtils";
import { flatObjectsInArray } from "c/apexRecordsUtils";
import { LightningElement, api, wire } from "lwc";
import getFieldInformation from "@salesforce/apex/SObjectLookupController.getFieldInformation";
import getDatasetRecords from "@salesforce/apex/SObjectLookupController.getDatasetRecords";
import getRecentlyViewed from "@salesforce/apex/SObjectLookupController.getRecentlyViewed";
import getInitialSelection from "@salesforce/apex/SObjectLookupController.getInitialSelection";

const TYPE_BY_FIELD_TYPE = {
  string: { type: "text" },
  phone: { type: "text" },
  int: { type: "number" },
  long: { type: "number" },
  double: { type: "number" },
  datetime: { type: "number" },
  percent: { type: "percent-fixed" },
  date: { type: "number" },// date-local
  currency: { type: "currency" },
  boolean: { type: "percent-fixed" },
  picklist: { type: "text" },
  number: { type: "number"  }
}

export default class SobjectLookup extends LightningElement {
  @api actions;
  @api messageWhenValueMissing;
  @api fieldLevelText;
  @api isMultiEntry;
  @api label;
  @api minSearchTermLength;
  @api notifyViaAlerts;
  @api placeholder;
  @api required;
  @api scrollAfterNItems;
  @api variant;
  @api useRawInput;

  _searchResults;
  _initialSelection = [];
  _sets = [];
  _value;
  recentlyViewed = [];
  datasets = null;
  _disabled = false;

  @api
  get disabled() {
    return this._disabled;
  }

  set disabled(value) {
    this._disabled = value;
  }

  @api
  get sets() {
    return this._sets;
  }

  set sets(sets) {
    if (Array.isArray(sets) && sets.length) {
      this._sets = sets;
    }
  }

  @api
  get validity() {
    return this.lookupElement?.validity;
  }

  @api
  checkValidity() {
    return this.lookupElement?.checkValidity();
  }

  @api
  reportValidity() {
    return this.lookupElement?.reportValidity();
  }

  @api
  setCustomValidity(message) {
    return this.lookupElement?.setCustomValidity(message);
  }

  @api
  showHelpMessageIfInvalid() {
    this.lookupElement?.reportValidity();
  }

  @api
  get value() {
    return this._value;
  }

  set value(value) {
    this._value = value;
  }

  @api
  focus() {
    this.lookupElement?.focus();
  }

  @api
  blur() {
    this.lookupElement?.blur();
  }

  // sets the initial selection if there is one
  @wire(getInitialSelection, {
    initialSelection: "$value",
    datasets: "$datasets"
  })
  wiredInitialSelection({ error, data }) {
    if (data) {
      this._initialSelection = this.processSearch(data);
      this._disabled = false;
    } else if (error && this.datasets) {
      this.setCustomValidity(reduceErrors(error).join(", "));
      this.reportValidity();
    }
  }

  // gets recentlyViewed that match the each set criteria
  @wire(getRecentlyViewed, { datasets: "$datasets" })
  getRecentlyViewed({ data, error }) {
    if (data) {
      this.recentlyViewed = this.processSearch(data);
    } else if (error && this.datasets) {
      this.setCustomValidity(reduceErrors(error).join(", "));
      this.reportValidity();
    }
  }

  // gets database data that match set criteria, searchTerm and is not already selected
  handleSearch(event) {
    const { rawSearchTerm, searchTerm, selectedIds } = event.detail;

    getDatasetRecords({
      searchTerm: this.useRawInput ? rawSearchTerm : searchTerm,
      selectedIds,
      datasets: this.datasets
    })
      .then((data) => {
        this._searchResults = this.processSearch(data);
      })
      .catch((error) => {
        this.setCustomValidity(reduceErrors(error).join(", "));
        this.reportValidity();
      });
  }

  processSearch(data) {
    const privateData = clone(data);
    const result = [];

    for (let index = 0; index < privateData.length; index++) {
      const { fields, primaryField, icon, name } = this._sets[index];
      // flat inner objects so that {Id: '1', Owner: {Id: '1'}} becomes => {Id: '1', Owner.Id: '1'}
      const setRecords = flatObjectsInArray(privateData[index]);

      for (const record of setRecords) {
        // build the subtitles for each record
        const subtitles = fields
          .filter(({ primary }) => !primary)
          .map(({ label, name: subtitleName, highlightSearchTerm }) => ({
            label,
            value: record[subtitleName],
            highlightSearchTerm
          }));

        result.push({
          id: record.Id + ":set:" + name,
          title: record[primaryField.name],
          icon,
          subtitles
        });
      }
    }

    return result;
  }

  handleChange({ detail }) {
    const valuesBySet = new Map();

    const data = detail.map((record) => {
      const [id, set] = record.split(":set:");

      if (!valuesBySet.has(set)) {
        valuesBySet.set(set, [id]);
      } else {
        valuesBySet.set(set, [...valuesBySet.get(set), id]);
      }

      return { id, set };
    });

    this._value = data.map(({ id }) => id);
    this.dispatchEvent(
      new CustomEvent("change", {
        detail: {
          value: this._value,
          valuesBySet
        }
      })
    );
  }

  handleAction({ detail }) {
    this.dispatchEvent(new CustomEvent("action", { detail }));
  }

  handleFocus() {
    this.dispatchEvent(new CustomEvent("focus"));
  }

  handleBlur() {
    this.dispatchEvent(new CustomEvent("blur"));
  }

  get lookupElement() {
    return this.template.querySelector("c-lookup");
  }

  async connectedCallback() {
    await this.formatSets();

    if (this.value && this._sets.length) {
      this._disabled = true;
    }
  }

  async formatSets() {
    const result = [];
    for (const set of clone(this._sets)) {
      const { fields } = set;

      // set primary if not defined
      let primaryField = fields.find(({ primary }) => primary);

      if (!primaryField) {
        fields[0].primary = true;
        primaryField = fields[0];
      }

      set.primaryField = primaryField;
      set.fields = fields.map(({ name, label }) => ({ name, label }));
      result.push(set);
    }

    const fieldInformation = JSON.parse(await getFieldInformation({ datasets: JSON.stringify(result) }));

    for (const set of result) {
      const setFieldInfo = fieldInformation[set.name];
      set.fields.forEach(field => {
        const fieldInfo = setFieldInfo[field.name];
        if (fieldInfo) {
          const {type} = TYPE_BY_FIELD_TYPE[fieldInfo.type];
          field.type = type;
        }
      });
    }

    this._sets = result;

    this.datasets = JSON.stringify(this._sets);
  }
}
