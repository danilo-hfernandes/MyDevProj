// teeUpComponent.js
import { LightningElement, wire, track, api } from 'lwc';
import getAgents from '@salesforce/apex/LeadApiController.getAgents';
import teeUpLead from '@salesforce/apex/LeadApiController.teeUpLead';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class TeeUpComponent extends LightningElement {
    @api recordId; // Lead record ID
    @track agents = [];
    @track selectedAgentId;
    @track selectedAgentName;
    @track isLoading = false;

    // Fetch agent list
    handleGetAgents() {
        this.isLoading = true;
        getAgents()
            .then(result => {
                console.log('>>>>result'+result);
                let data = result;
                this.agents = data.map(agent => ({
                    label: agent.Text,
                    value: agent.Value,
                    name: agent.Text
                }));
            })
            .catch(error => {
                this.showToast('Error', 'Error fetching agents', 'error');
                console.error(error);
            })
            .finally(() => {
                this.isLoading = false;
            });
    }

    // Handle agent selection
    handleAgentChange(event) {
        this.selectedAgentId = event.detail.value;
        const selectedAgent = this.agents.find(agent => agent.value === this.selectedAgentId);
        this.selectedAgentName = selectedAgent ? selectedAgent.label : '';
    }

    // Call Apex method for Tee-Up
    handleApiCall() {
        if (!this.selectedAgentId || !this.selectedAgentName) {
            this.showToast('Error', 'Please select an agent', 'error');
            return;
        }
        this.isLoading = true;
        teeUpLead({ leadId: this.recordId, smtnAgentId: this.selectedAgentId, smtnAgentName: this.selectedAgentName})
            .then(() => {
                this.showToast('Success', 'Tee-Up successful', 'success');
                
            })
            .catch(error => {
                this.showToast('Error', 'Tee-Up failed', 'error');
                console.error(error);
            })
            .finally(() => {
                this.isLoading = false;
                this.agents = [];
                this.selectedAgentId = '';
                this.selectedAgentName ='';
            });
    }

    // Show toast message
    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({
            title,
            message,
            variant
        }));
    }
}