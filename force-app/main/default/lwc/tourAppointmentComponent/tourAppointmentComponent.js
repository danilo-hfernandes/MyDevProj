import { LightningElement, api, wire, track } from 'lwc';
import createRebookTourAppointment from '@salesforce/apex/TourAppointmentCompController.createRebookTourAppointment';
import getTourAppointment from '@salesforce/apex/TourAppointmentCompController.getTourAppointment';
import getToursByDateTime from '@salesforce/apex/TourAppointmentCompController.getToursByDateTime';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { refreshApex } from '@salesforce/apex';
import getActiveUsers from '@salesforce/apex/TourAppointmentCompController.getActiveUsers';


export default class TourAppointmentComponent extends LightningElement {
    @api recordId; // Opportunity ID
    @track tourAppointment; // Holds the related Tour Appointment record
	@track isActionButtonVisible = true;  // Tracks if the action button is visible
    @track isDisabledButtonVisible = false;  // Tracks if the disabled button is visible
    @track currentRecordId;
    @track columns;
    @track isShowModal = false;
    @track datevalue;
    @track timeValue;
    @track waveValue;
    @track tourData = [];
    @track selectedRows = [];
    @track statusValue = '';
    wiredTourAppointments;
    @track timeOptions = [];

    @track isAgentModalOpen = false;
    @track selectedTeeUpAgent = '';
    @track selectedClosingAgent = '';
    @track agentOptions = [];

    @track allColumns = [

        //{ label: 'Location', fieldName: 'Location__c' },
        //{ label: 'Day', fieldName: 'Day__c' },
        { label: 'Date', fieldName: 'Date__c' },
        {
            label: 'Time', fieldName: 'Tour_Time__c', // Now this will have formatted time only
            type: 'date',
            typeAttributes: {
                timeZone: "GMT",
                hour: "2-digit",
                minute: "2-digit"
            }
        },
        { label: 'Available', fieldName: 'Available_Tours__c' },
        { label: 'Booked', fieldName: 'Booked_Tours__c' }
       // { label: 'Wave', fieldName: 'Wave__c' }

    ]

    // Hardcoded picklist values
    oppStatusOptions = [

        { label: 'Showed', value: 'Showed' },
        { label: 'Booked', value: 'Booked' },
        { label: 'No Show', value: 'No Show' },
        { label: 'NQ', value: 'NQ' },
        { label: 'Rescheduled', value: 'Rescheduled' },
        { label: 'Cancelled', value: 'Cancelled' }

    ];
    connectedCallback() {
        this.columns = [...this.allColumns];
        
        // Fetch active users for combobox
        getActiveUsers()
            .then(result => {
                this.agentOptions = result;
                console.log('Agent options:', JSON.stringify(this.agentOptions));
            })
            .catch(error => {
                console.error('Error fetching users:', error);
            });
        }

    // Call Apex method to fetch the Tour Appointment record
    @wire(getTourAppointment, { opportunityId: '$recordId' })
    wiredTourAppointment(result) {
        this.wiredTourAppointments = result;
        if (result.data) {
            this.tourAppointment = Array.isArray(result.data) ? result.data[0] : result.data;
            if (this.tourAppointment) {
                this.currentRecordId = this.tourAppointment.Id;
                this.statusValue = this.tourAppointment.Opp_Status__c; // Set the combo box value
                console.log('statusValue', this.statusValue);
                console.log('currentRecordId', this.currentRecordId);
                console.log('Tour ID', JSON.stringify(this.tourAppointment));
            }
        } else if (result.error) {
            console.error('Error fetching tours:', JSON.stringify(result.error));
        }
    }
	
// Handle the 'Book Tour' button click
/*    handleBookTour() {
        // Hide the active button and show the disabled button when clicked
        this.isActionButtonVisible = false;
        this.isDisabledButtonVisible = true;

        // Simulate booking logic
        this.saverebook()
            .then(() => {
                // If booking is successful, you can leave the disabled button visible
            })
            .catch(error => {
                // If there's an error, show the valid button again and hide the disabled one
                this.isActionButtonVisible = true;
                this.isDisabledButtonVisible = false;
                this.showErrorToast(error);
            });
    }
    BEFORE Change
*/
        handleBookTour() {
            if (this.selectedRows.length === 0) {
                this.showToast('Error', 'Please select a Tour first.', 'error');
                return;
            }

            // Open Agent Modal
            this.isAgentModalOpen = true;

            // Toggle buttons while modal is open
            this.isActionButtonVisible = false;
            this.isDisabledButtonVisible = true;
        }

	
	    showErrorToast(error) {
        // Optionally, show an error toast message
        const event = new ShowToastEvent({
            title: 'Error',
            message: error.message,
            variant: 'error'
        });
        this.dispatchEvent(event);
    }


    fetchTours() {
        if (!this.datevalue) {
            console.warn('No date selected.');
            this.tourData = []; // Ensure it's empty
            this.timeOptions = [];
            this.isNoTours = true; // Show message
            return;
        }

        console.log('Fetching tours for date:', this.datevalue);
        console.log('Fetching tours for time:', this.timeValue);


        getToursByDateTime({ selectedDate: this.datevalue, selectedTime: this.timeValue })

            .then(result => {
                console.log('Tours returned from Apex:', JSON.stringify(result, null, 2));

                if (result && result.length > 0) {
                    this.tourData = result;
                    this.isNoTours = false; // Hide message
					this.timeOptions = [
					{ label: '-- All Times --', value: '' }, // 👈 Empty option at the top
					...result.map(time => ({
						label: this.convertMillisecondsToTime(time.Tour_Time__c),
						value: this.convertMillisecondsToTime(time.Tour_Time__c)
					}))
					];
                    /*this.timeOptions = result.map(time => ({

                        label: this.convertMillisecondsToTime(time.Tour_Time__c),
                        value: this.convertMillisecondsToTime(time.Tour_Time__c)
                    }));*/
                    // ✅ Merge new options with existing ones, avoiding duplicates
                    //this.timeOptions = [...new Map([...this.timeOptions, ...newTimeOptions].map(item => [item.value, item])).values()];
                    console.log('Tours returned from 1:', this.timeOptions);
                } else {
                    console.warn('No dates are available for the selected criteria.');
                    this.tourData = []; // Reset table
                    this.isNoTours = true; // Show message
                    this.timeOptions = [];
                }
            })
            .catch(error => {
                console.error('Error fetching tours:', error);
                this.tourData = [];
                this.isNoTours = true;
                this.timeOptions = [];
            });
    }

    fetchToursTimes() {
        if (!this.datevalue) {
            console.warn('No date selected.');
            this.tourData = []; // Ensure it's empty
            this.timeOptions = [];
            this.isNoTours = true; // Show message
            return;
        }

        console.log('Fetching tours for date:', this.datevalue);
        console.log('Fetching tours for time:', this.timeValue);


        getToursByDateTime({ selectedDate: this.datevalue, selectedTime: this.timeValue })
            .then(result => {
                console.log('Tours returned from Apex:', JSON.stringify(result, null, 2));

                if (result && result.length > 0) {
                    this.tourData = result;
                    this.isNoTours = false; // Hide message

                } else {
                    console.warn('No dates are available for the selected criteria.');
                    this.tourData = []; // Reset table
                    this.isNoTours = true; // Show message
                    this.timeOptions = [];
                }
            })
            .catch(error => {
                console.error('Error fetching tours:', error);
                this.tourData = [];
                this.isNoTours = true;
                this.timeOptions = [];
            });
    }


    // Added 
        handleTeeUpChange(event) {
            this.selectedTeeUpAgent = event.target.value;
        }

        handleClosingChange(event) {
            this.selectedClosingAgent = event.target.value;
        }


    handleSuccess(event) {

        // event.preventDefault();
        this.dispatchEvent(new ShowToastEvent({
            title: 'Success!!',
            message: 'Record updated Successfully!!.',
            variant: 'success'
        }));
        this.statusValue = '';

    }

    // Update the tracked value when combobox selection changes
    handleOppStatusChange(event) {
        this.statusValue = event.detail.value;
    }

    handleReset() {
        const inputFields = this.template.querySelectorAll(
            'lightning-input-field'
        );
        if (inputFields) {
            inputFields.forEach(field => {
                field.reset();
            });
        }
    }

    handleSubmit(event) {
        event.preventDefault();
        const fields = event.detail.fields;
        // Map our selected value to the Opp_Sttaus__C API field
        fields.Opp_Status__c = this.statusValue;
        // Submit the form with the updated fields
        this.template.querySelector('lightning-record-edit-form').submit(fields);

        // Refresh the page
        window.location.reload();
        this.statusValue = '';
    }

    handleRebookButton(event) {
        this.isShowModal = true;

    }

    hideModalBox() {
        this.isShowModal = false;
        // Clear tour data
        this.tourData = [];
        // Clear input fields
        this.datevalue = null;
        this.timeValue = null;
        this.waveValue = null;
    }

    // Handle Date Change
    handledatevalue(event) {
        /*this.datevalue = event.target.value;
        console.log('Selected Date:', this.datevalue);
        this.fetchTours();*/
		this.datevalue = event.target.value;
		this.timeValue = null; // 🛠 Reset time when date changes
		console.log('Selected Date:', this.datevalue);
		this.fetchTours(); // fetchTours already checks timeValue
    }

    //Handle Time Change 
    handleTimeValue(event) {
        this.timeValue = event.target.value;
        console.log('Selected Time:', this.timeValue);
        console.log('Data Type of timeValue:', typeof this.timeValue); //  Print data type
        this.fetchToursTimes();
    }
    handleWaveValue(event) {
        let inputValue = event.target.value.toLowerCase(); // Convert to lowercase
        this.waveValue = inputValue.replace(/\b\w/g, (char) => char.toUpperCase()); // Capitalize first letter of each word
        // this.waveValue = event.target.value;
        console.log('Selected wave:', this.waveValue);
        console.log('Data Type of waveValue:', typeof this.waveValue); //  Print data type
        this.fetchTours();
    }

    handleCancel() {
        // Clear input fields
        this.datevalue = null;
        this.timeValue = null;
        this.waveValue = null;

        // Clear tour data
        this.tourData = [];

        // Close the modal
        this.isShowModal = false;

        console.log('Modal closed, fields reset.');
        // Refresh the page
        window.location.reload();
    }

        closeAgentModal() {
        // Close the modal
        this.isAgentModalOpen = false;

        // Reset selected agents so next open is empty
        this.selectedTeeUpAgent = null;
        this.selectedClosingAgent = null;

        // Restore buttons visibility
        this.isActionButtonVisible = true;
        this.isDisabledButtonVisible = false;
    
    }

    handleRowSelection(event) {
        var selectedRows = event.detail.selectedRows;
        this.selectedRows = selectedRows;
        if (selectedRows.length > 1) {
            var el = this.template.querySelector('lightning-datatable');
            selectedRows = el.selectedRows = el.selectedRows.slice(1);
            this.showNotification();
            event.preventDefault();
            return;
        }
    }

    showNotification() {
        this.showToast('Error', 'Only one row can be selected.', 'warning');
    }

    saverebook() {
        console.log('length', this.selectedRows.length);
        if (this.selectedRows.length === 0) {
            this.showToast('Error', 'Please select Tour before Rebook Tour Appointment.', 'error');
			this.isActionButtonVisible = true;
            this.isDisabledButtonVisible = false;
            return;
        }
        console.log('length', this.selectedRows[0].Id);

        if (!this.selectedTeeUpAgent || !this.selectedClosingAgent) {
                this.showToast(
                    'Error',
                    'Please select both Tee Up Agent and Closing Agent.',
                    'error'
                );
                this.isActionButtonVisible = true;
                this.isDisabledButtonVisible = false;
                return;
            }
            const selectedTourId = this.selectedRows[0].Id;

                console.log('Booking Tour Id:', selectedTourId);
                console.log('Tee Up Agent:', this.selectedTeeUpAgent);
                console.log('Closing Agent:', this.selectedClosingAgent);


        createRebookTourAppointment({ oppRecordId: this.recordId, tourRecordId: this.selectedRows[0].Id, teeUpAgentId: this.selectedTeeUpAgent, closingAgentId: this.selectedClosingAgent })
            .then(result => {
                console.log('result', result);
                this.isShowModal = false;
                // Clear tour data

                this.showToast('Success', result, 'Success');
                this.tourData = [];
                this.selectedTeeUpAgent = null;
                this.selectedClosingAgent = null;
                // Clear input fields
                this.datevalue = null;
                this.timeValue = null;
                this.waveValue = null;
				this.isActionButtonVisible = true;
                this.isDisabledButtonVisible = false;


                return refreshApex(this.wiredTourAppointments); //  Refresh data

            })
            .catch(error => {
                console.log('error', error);
				this.isActionButtonVisible = true;
                this.isDisabledButtonVisible = false;
                this.error = error;
                this.tourData = [];
            })
    }
    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title,
            message,
            variant
        });
        this.dispatchEvent(event);
    }

        saveAgentsAndContinue() {
            // Validate agent selection
            if (!this.selectedTeeUpAgent || !this.selectedClosingAgent) {
                this.showToast('Error', 'Please select both agents.', 'error');
                this.isActionButtonVisible = true;
                this.isDisabledButtonVisible = false;
                return;
            }

            // Close agent modal
            this.isAgentModalOpen = false;


            // Call Apex to create the Tour Appointment
            createRebookTourAppointment({
                    oppRecordId: this.recordId,
                    tourRecordId: this.selectedRows[0].Id,
                    teeUpAgentId: this.selectedTeeUpAgent,
                    closingAgentId: this.selectedClosingAgent
                })
            .then(result => {
                this.showToast('Success', result, 'success');

                // Reset modal and form values
                this.isShowModal = false;
                this.tourData = [];
                this.selectedRows = [];
                this.selectedTeeUpAgent = '';
                this.selectedClosingAgent = '';
                this.datevalue = null;
                this.timeValue = null;
                this.waveValue = null;

                // Reset buttons
                this.isActionButtonVisible = true;
                this.isDisabledButtonVisible = false;

                return refreshApex(this.wiredTourAppointments);
            })
            .catch(error => {
                console.error(error);
                this.showToast('Error', error.body ? error.body.message : error.message, 'error');
                this.isActionButtonVisible = true;
                this.isDisabledButtonVisible = false;
            });
         window.location.reload();
        }


    convertMillisecondsToTime(milliseconds) {
        let date = new Date(milliseconds);
        let hours = date.getUTCHours();
        let minutes = date.getUTCMinutes();

        // Format hours and minutes
        let ampm = hours >= 12 ? 'PM' : 'AM';
        hours = hours % 12 || 12; // Convert 24h to 12h format
        let formattedMinutes = minutes < 10 ? '0' + minutes : minutes;

        return `${hours}:${formattedMinutes} ${ampm}`;
    }



}