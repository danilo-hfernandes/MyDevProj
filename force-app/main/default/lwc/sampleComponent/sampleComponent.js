import { LightningElement, track, wire } from 'lwc';
import getObjectList from '@salesforce/apex/ObjectFieldHelper.getObjectList';
import getFieldList from '@salesforce/apex/ObjectFieldHelper.getFieldList';
import createScheduler from '@salesforce/apex/SchedulerController.createScheduler';

export default class sampleComponent extends LightningElement {
    @track objects = ['Account'];
    @track fields = [];
    selectedObject;
    selectedFields = [];
    scheduleTime;

    // Frequency options for daily or monthly
    frequencyOptions = [
        { label: 'Daily', value: 'Daily' },
        { label: 'Monthly', value: 'Monthly' }
    ];
    selectedFrequency = 'Daily';
    isDaily = true;
    isMonthly = false;
    runTime;
    runDate;

    mainObjectFilters = []; // To hold filters for main object
    parentObjectFilters = []; // To hold filters for parent object

    @wire(getObjectList)
    wiredObjects({ error, data }) {
        if (data) {
            this.objects = data;
            console.log('>>>Object>>', data);
            console.log('>>>Object>>'+this.objects);
        } else if (error) {
            console.error(error);
        }
    }

    handleObjectChange(event) {
        this.selectedObject = event.detail.value;
        getFieldList({ objectName: this.selectedObject }).then((result) => {
            this.fields = result;
        }).catch((error) => {
            console.error(error);
        });
    }

    handleFieldChange(event) {
        this.selectedFields = event.detail.value;
    }

    handleScheduleChange(event) {
        this.scheduleTime = event.detail.value;
    }

    addFilter(event) {
        // Add a new filter to mainObjectFilters or parentObjectFilters depending on user choice
    }

    handleGenerateScheduler() {
        createScheduler({ 
            objectName: this.selectedObject,
            fields: this.selectedFields,
            scheduleTime: this.scheduleTime,
            mainObjectFilters: JSON.stringify(this.mainObjectFilters),
            parentObjectFilters: JSON.stringify(this.parentObjectFilters)
        }).then(() => {
            // Show success message
        }).catch((error) => {
            console.error(error);
        });
    }
}