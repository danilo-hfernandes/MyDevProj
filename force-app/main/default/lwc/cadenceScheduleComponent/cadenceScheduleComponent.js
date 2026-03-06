import { LightningElement, wire, track } from 'lwc';
import getObjects from '@salesforce/apex/CadenceScheduleController.getObjects';
import getFields from '@salesforce/apex/CadenceScheduleController.getFields';
import getPicklistValues from '@salesforce/apex/CadenceScheduleController.getPicklistValues';
import getMatchGroups from '@salesforce/apex/CadenceScheduleController.getMatchGroups';
import getCadences from '@salesforce/apex/CadenceScheduleController.getCadences';
import saveCadenceSchedule from '@salesforce/apex/CadenceScheduleController.saveCadenceSchedule';
import { RefreshEvent } from 'lightning/refresh';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class CadenceScheduleComponent extends LightningElement {
    @track objectOptions = [];
    @track objectOptions = [];
    @track fieldOptions = [];
    @track selectedObject;
    @track selectedFields = [];
    @track filters = [{ field: '', operator: '=', value: '' }];
    @track matchGroupOptions = [];
    @track cadenceOptions = [];
    @track selectedMatchGroup;
    @track selectedCadence;
    @track filterLogic = '';

    operatorOptions = [
        { label: '=', value: '=' },
        { label: '!=', value: '!=' },
        { label: '>', value: '>' },
        { label: '<', value: '<' }
    ];

    connectedCallback() {
        if (this.filters.length === 0) {
            this.addFilter();
        }
    }

    @wire(getObjects)
    wiredObjects({ data, error }) {
        if (data) {
            this.objectOptions = data.map(obj => ({ label: obj, value: obj }));
        } else if (error) {
            this.showToast('Error', 'Error fetching objects', 'error');
        }
    }


    handleObjectChange(event) {
        this.selectedObject = event.detail.value;
        getFields({ objectName: this.selectedObject })
            .then(data => {
                this.fieldOptions = data.map(field => ({ label: field.label, value: field.apiName, type: field.type }));
            })
            .catch(error => {
                this.showToast('Error', 'Error fetching fields', 'error');
            });
        //MatchGroup 
        getMatchGroups({ objectName: this.selectedObject })
            .then(data => {
                this.matchGroupOptions = data.map(mg => ({ label: mg.Name, value: mg.Name }));
            })
            .catch(error => {
                this.showToast('Error', 'Error fetching Match Groups', 'error');
            });
        //Cadence
        getCadences({ objectName: this.selectedObject })
            .then(data => {
                    this.cadenceOptions = data.map(c => ({ label: c.Name, value: c.Name }));
            })
            .catch(error => {
                this.showToast('Error', 'Error fetching Cadence', 'error');
            });
    }


    handleFieldChange(event) {
        this.selectedFields = event.detail.value;
    }

    handleFilterChange(event) {
        console.log('>1111>>this.filters>>', JSON.stringify(this.filters));
        console.log('>1111>>this.filters>>'+JSON.stringify(this.filters));
        const index = event.target.dataset.index;
        const name = event.target.name;
        const value = event.detail.value;
        this.filters[index][name] = value;
        console.log('>>handleFilterChange>>'+index+'>>>>'+name+'>>>>'+value);
        if (name === 'field') {
            
            const fieldType = this.fieldOptions.find(field => field.value === value)?.type;
            console.log('>>>fieldType>>'+fieldType);
            this.filters[index].isPicklist = fieldType === 'PICKLIST';
            this.filters[index].isDate = fieldType === 'DATE';
            this.filters[index].isDateTime = fieldType === 'DATETIME';
            
            if (this.filters[index].isPicklist) {
                getPicklistValues({ objectName: this.selectedObject, fieldName: value })
                    .then(data => {
                        this.filters[index].picklistValues = data.map(item => ({ label: item, value: item }));
                    });
            } else {
                this.filters[index].picklistValues = [];
            }
        }
        console.log('>2222>>this.filters>>',JSON.stringify(this.filters));
        console.log('>2222>>this.filters>>'+JSON.stringify(this.filters));
    }

    addFilter() {
        let newFilter = { 
            id: Date.now(), 
            field: '', 
            operator: '=', 
            value: '', 
            isPicklist: false, 
            isDate: false, 
            isDateTime: false, 
            picklistValues: [], 
        };
        this.filters = [...this.filters, newFilter];
        this.updateFilterNumbers();
    }

    removeFilter(event) {
        const index = event.target.dataset.index;
        this.filters.splice(index, 1);
        this.updateFilterNumbers();
    }

    // Function to update numbering for filters dynamically
    updateFilterNumbers() {
        this.filters = this.filters.map((filter, idx) => ({
            ...filter,
            number: idx + 1
        }));
        
    }

    handleFilterLogicChange(event) {
        console.log('>>Filter Logic>>>'+event.detail.value);
        this.filterLogic = event.detail.value;
        console.log('>>>>>>'+this.filterLogic);
    }

    handleMatchGroupChange(event) {
        this.selectedMatchGroup = event.detail.value;
    }

    handleCadenceChange(event) {
        this.selectedCadence = event.detail.value;
    }

    saveConfiguration() {
        let filteredData = this.filters.map(({number, field, operator, value }) => ({
            number,
            field,
            operator,
            value
            }));
            console.log('>>filteredData>>', JSON.stringify(filteredData));
        const config = {
            objectName: this.selectedObject,
            fields: this.selectedFields,
            filters: JSON.stringify(filteredData),
            matchGroupId: this.selectedMatchGroup,
            cadenceId: this.selectedCadence, 
            filterLogic : this.filterLogic
        };
        console.log('>>config>>>', config);
        console.log('>>config>>>', JSON.stringify(config));
        saveCadenceSchedule({ config: JSON.stringify(config) })
            .then(() => {
                this.showToast('Success', 'Cadence schedule saved successfully', 'success');
                this.dispatchEvent(new RefreshEvent());
            })
            .catch(error => {
                this.showToast('Error', 'Error saving cadence schedule', 'error');
            });
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
}